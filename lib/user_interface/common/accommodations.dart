// Refactored Accommodations Screen with Quick Filters, Jump-to-Top, and NSFAS Support

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Constants/Constants.dart';
import '../../constants/Lists.dart';
import '../../constants/scale.dart';
import '../../classes/listing_model.dart';
import '../../classes/user_model.dart';
import '../../custom_made/widgets/customInput.dart';
import '../../custom_made/widgets/custom_cardView.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/set_listing.dart';
import '../../firebase_Set/user.dart';
import '../../providers/notification_bell.dart';
import '../../static/banner.dart';
import '../Common/chats.dart';
import '../Common/drawer.dart';

class Accomodations extends StatefulWidget {
  const Accomodations({super.key});

  @override
  State<Accomodations> createState() => _AccomodationsState();
}

class _AccomodationsState extends State<Accomodations> {
  final ScrollController _scrollController = ScrollController();
  final Listing _listingService = Listing();
  final TextEditingController _searchController = TextEditingController();

  final List<Listing_model> _listings = [];
  List<UserModel> _users = [];

  bool _isLoading = false;
  bool _showScrollToTop = false;
  bool _isConnected = true;

  Timer? _debounce;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  String? _currentSearch;
  String? _selectedUniversity;

  int selectedButtonIndexx = 0;

  @override
  void initState() {
    super.initState();
    _checkNetwork();

    // Fetch current user and university
    Future.microtask(() {
      if(mounted){
        final studentProvider = Provider.of<StudentProvider>(
          context,
          listen: false,
        ).currentStudent();
        setState(() {

        });

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUser();
      }

    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      connectivityResults,
    ) {
      setState(() {
        _isConnected = !connectivityResults.contains(ConnectivityResult.none);
      });
    });

    // Debounced search
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _currentSearch = _searchController.text.trim();
        _resetAndFetch();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.offset >= 400 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset < 400 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreListings();
      }
    });

    _initData();
    // _loadInitialData();
  }

  Future<void> _initData() async {
    // Fetch user and student data first
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.fetchUser(); // get logged-in user
    await studentProvider.currentStudent(); // fetch student details

    _selectedUniversity =
        studentProvider.currentStudentInfo?.uni ??
        southAfricanUniversities.first;
    //     print('Selected University: $_selectedUniversity');

    // Now fetch listings and users
    await _loadInitialData();
  }

  Future<void> _checkNetwork() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !connectivityResults.contains(ConnectivityResult.none);
    });
  }

  Future<void> _loadInitialData() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .get();
    _users = usersSnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList(); //e <- doc
    await _loadMoreListings();
  }

  Future<void> _loadMoreListings() async {
    if (_isLoading || !_listingService.hasMore) return;
    setState(() => _isLoading = true);

    final newListings = await _listingService.fetchListings(
      searchText: _currentSearch,
      selectedUniversity: _selectedUniversity,
    );

         print('searchInput : $_currentSearch, _selectedUniversity: $_selectedUniversity');

    if (!mounted) return;
    setState(() {
      _listings.addAll(newListings);
      _isLoading = false;
    });
  }

  void _resetAndFetch() {
    _listingService.resetPagination();
    _listings.clear();
    _loadMoreListings();
  }

  void _applyQuickFilter(String input, int index) {
    _searchController.clear();
    _currentSearch = input; // Pass filter term directly
    setState(() => selectedButtonIndexx = index);
    _resetAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    final theme = Theme.of(context).textTheme;

    final user = context.watch<UserProvider>().user;

    return _selectedUniversity == null || user == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Center(
                child: lindelani(isLindeWhite: false, isLWhite: false),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    CupertinoIcons.list_bullet,
                    size: 30,
                    color: Colors.grey,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                Consumer<NotificationProvider>(
                  builder: (context, provider, _) => IconButton(
                    icon: Icon(
                      CupertinoIcons.chat_bubble_fill,
                      size: 30,
                      color: provider.hasNewMessages ? Colors.red : blue900,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllChats()),
                    ),
                  ),
                ),
              ],
            ),
            drawer: const customDrawe(),
            floatingActionButton: _showScrollToTop
                ? FloatingActionButton(
                    backgroundColor: blue900,
                    onPressed: () => _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  )
                : null,
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 15, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Hi ${user.userName}',
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: blue900,
                          ),
                        ),
                        Text(
                          'Where would',
                          style: theme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'you like to stay',
                          style: theme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: hightTen),
                        SizedBox(height: hightTen),

                        Custominput(
                          Controller: _searchController,
                          HintText: 'search by amount',
                          circular: 20,
                          isPadding: true,
                          enabled: true,
                          lineNumb: 1,
                          onChange: (_) {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: hightTen),

                  //_buildQuickFilters(amountFilter,selectedButtonIndex),
                  _buildQuickFilters(quickFilters, selectedButtonIndexx),

                  SizedBox(height: hightTen),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Listing',
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (!_isConnected) NetworkBanner.noInternet(),
                  ListView.builder(
                    itemCount: _listings.length + (_isLoading ? 1 : 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < _listings.length) {
                        final listing = _listings[index];
                        final owner = _users.firstWhere(
                          (u) => u.userId == listing.userId,
                          orElse: () => UserModel(
                            userId: '',
                            userName: '',
                            userType: '',
                            userGender: '',
                            profilePictureUrl: '',
                            isFreeTrial: false,
                          ),
                        );
                        return CustomGridView(house: listing, user: owner);
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildQuickFilters(List<Map<String, String>> filters, indexx) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                backgroundColor: indexx == index ? blue900 : Colors.grey,
              ),
              onPressed: () => _applyQuickFilter(filter['query']!, index),
              child: Text(
                filter['label']!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }),
      ),
    );
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySub.cancel();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
