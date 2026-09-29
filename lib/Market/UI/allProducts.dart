import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Market/customMad/productCard.dart';
import 'package:lindelany/Market/firebaseService/productModel.dart';
import 'package:lindelany/Market/firebaseService/productSet.dart';

import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:provider/provider.dart';

import '../../Constants/constants.dart';
import '../../models/student_model.dart';
import '../../models/user_model.dart';
import 'detailedProduct.dart';

class AllProducts extends StatefulWidget {
  final String? category;

  const AllProducts({super.key, required this.category});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  // Hold products
  final List<ProductModel> _products = [];
  List<UserModel> _users = [];

  // Track loading state
  bool _isLoading = false;
  bool _isFirstLoad = true;

  final ProductSet _dataService = ProductSet();
  late String studentUni;

  // Stream subscription for student data
  late StreamSubscription<StudentModel> _studentSubscription;

  @override
  void initState() {
    super.initState();
    _setupStudentStream(); // Set up stream first
    _loadInitialData(); // Load first batch when widget initializes
  }

  void _setupStudentStream() {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    _studentSubscription = studentProvider.currentStudentDoc().listen((
      student,
    ) {
      if (mounted) {
        final newUniversity = student.uni.trim();

        // Only update if university actually changed
        if (studentUni != newUniversity) {
          setState(() {
            studentUni = newUniversity;
          });
//          debugPrint('University updated via stream: $studentUni');

          // Refresh products with new university
          _loadInitialProducts();
        }
      }
    });
  }

  //Load initial data
  Future<void> _loadInitialData() async {
    final studentInfo = Provider.of<StudentProvider>(
      context,
      listen: false,
    ).currentStudentInfo;
    final String uni =
        studentInfo?.uni.trim() ?? 'University'; // Provide default

    setState(() {
      studentUni = uni;
    });

    // CREATE A GET USER METHOD THAT IS SHARED
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .get();

    //put in a list _users
    _users = userSnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();

    await _loadInitialProducts();
  }

  // Load the first batch of products
  Future<void> _loadInitialProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isFirstLoad = true;
    });

    try {
      // Reset pagination and fetch first batch
      _dataService.resetPagination();
      final newProducts = await _dataService.fetchProducts(
        limit: 10,
        category: widget.category,
        studentUniversity: studentUni,
      );

//      print('UNIVERSITY = $studentUni');

      setState(() {
        _products.clear();
        _products.addAll(newProducts);
      });
    } catch (error) {
//      print('Error loading products: $error');
      // Handle error (show snackbar, etc.)
    } finally {
      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
      });
    }
  }

  // Load more products when user scrolls near the end
  Future<void> _loadMoreProducts() async {
    // Prevent multiple simultaneous loads and check if there's more data
    if (_isLoading || !_dataService.hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProducts = await _dataService.fetchProducts(
        limit: 10,
        category: widget.category,
        studentUniversity: studentUni, // Add university here too
      );

      setState(() {
        _products.addAll(newProducts);
      });
    } catch (error) {
//      print('Error loading more products: $error');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _studentSubscription.cancel(); // Important: cancel the stream subscription
    super.dispose();
  }

  // Check if we need to load more when user scrolls
  void _onScroll() {
    // Create a scroll controller if you want more control over scroll detection
    // For now, we'll use the index-based approach in GridView.builder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.category ?? 'All Products',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ), // Dynamic title based on category
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading indicator on first load
    if (_isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show empty state if no products
    if (_products.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new items',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: blue900),
              onPressed: _loadInitialProducts,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Load more when user scrolls to the bottom
        if (!_isLoading &&
            _dataService.hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMoreProducts();
        }
        return false;
      },
      child: Column(
        children: [
          // Products grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8, // Adjust based on your card design
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: _products.length + (_dataService.hasMore ? 1 : 0),
              // +1 for loading indicator
              itemBuilder: (context, index) {
                // Show loading indicator at the end if there are more items to load
                if (index >= _products.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = _products[index];
                final user = _users.firstWhere(
                  (u) => u.userId == product.sellerId,
                  orElse: () => UserModel(
                    userId: '',
                    userName: '',
                    userType: '',
                    userGender: '',
                    profilePictureUrl: '',
                    isFreeTrial: false,
                  ),
                );
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailedProduct(product: product, owner: user),
                      ),
                    );
                  },
                  child: ProductCard(product: product),
                );
              },
            ),
          ),

          // Bottom loading indicator (alternative approach)
          if (_isLoading && !_isFirstLoad)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // "No more products" message
          if (!_dataService.hasMore && _products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No more products to load',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(AllProducts oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload products if category changes
    if (oldWidget.category != widget.category) {
      _loadInitialProducts();
    }
  }
}
