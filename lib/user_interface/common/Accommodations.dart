// Refactored Accommodations Screen with Quick Filters, Jump-to-Top, and NSFAS Support

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/firebase_Set/setStudent.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Constants/Constants.dart';
import '../../constants/Lists.dart';
import '../../constants/scale.dart';
import '../../classes/listing_model.dart';
import '../../classes/user_model.dart';
import '../../custom_made/widgets/customInput.dart';
import '../../custom_made/widgets/custom_cardView.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/houseListing.dart';
import '../../firebase_Set/user.dart';
import '../../methods_Funtions/chatService.dart';
import '../../methods_Funtions/accommodationFilter.dart';
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

  final ValueNotifier<FilterCriteria?> _criteria = ValueNotifier(null);
  bool _isLoading = false;
  bool _showScrollToTop = false;
  late StreamSubscription<bool> _unreadMsgSub;

  bool _isConnected = true;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;


  @override
  void initState() {
    super.initState();

    _checkNetwork();

    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUser(),
    );

    _connectivitySub = Connectivity().onConnectivityChanged.listen((connectivityResults) {
      setState(() {
        _isConnected = !connectivityResults.contains(ConnectivityResult.none);
      });
    });


    _searchController.addListener(() {
      final input = _searchController.text.trim().toLowerCase();
      final studentUni = context.read<StudentProvider>().currentUser?.uni ?? '';

      _criteria.value = input.isEmpty
          ? null
          : AccommodationFilter.extractCriteria(
              input,
              currentStudentUni: studentUni,
            );
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

    _loadInitialData();
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
    _users = usersSnapshot.docs.map((e) => UserModel.fromDocument(e)).toList();
    await _loadMoreListings();
  }

  Future<void> _loadMoreListings() async {
    if (_isLoading || !_listingService.hasMore) return;

    setState(() => _isLoading = true);

    final newListings = await _listingService.fetchListings();

    if (!mounted) return;

    setState(() {
      _listings.addAll(newListings);
      _isLoading = false;
    });
  }



  List<Tuple2<Listing_model, UserModel>> _getFilteredResults() {
    final criteria = _criteria.value;
    final studentUni = context.read<StudentProvider>().currentUser?.uni ?? '';
    final userMap = {for (var u in _users) u.userId: u};

    return _listings
        .map((listing) {
          final user = userMap[listing.userId];
          if (user == null) return null;
          if (criteria != null &&
              !criteria.matches(listing, currentUserUniversity: studentUni)) {
            return null;
          }
          return Tuple2(listing, user);
        })
        .whereType<Tuple2<Listing_model, UserModel>>()
        .toList();
  }

  int selectedButtonIndexx = 0;

  void _applyQuickFilter(String input, int index) {
    _searchController.clear();
    final studentUni = context.read<StudentProvider>().currentUser?.uni ?? '';
    setState(() {
      selectedButtonIndexx = index; // Update the selected index
      _criteria.value = AccommodationFilter.extractCriteria(
        input,
        currentStudentUni: studentUni,
      );
    });
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(quickFilters.length, (index) {
          final filter = quickFilters[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 40),
                backgroundColor: selectedButtonIndexx == index
                    ? blue900
                    : Colors.grey,
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
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    final theme = Theme.of(context).textTheme;

    final user = context.watch<UserProvider>().user;

    return user == null
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
            body: Padding(
              padding: paddingg,
              child: SingleChildScrollView(
                controller: _scrollController,
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
                      HintText: 'search',
                      circular: 20,
                      isPadding: true,
                      enabled: true,
                      lineNumb: 1,
                      onChange: (_) {},
                    ),
                    SizedBox(height: hightTen),

                    _buildQuickFilters(),
                    SizedBox(height: hightTen),
                    Text(
                      'Listing',
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (_isConnected == false) NetworkBanner.noInternet(),

                    ValueListenableBuilder<FilterCriteria?>(
                      valueListenable: _criteria,
                      builder: (context, _, _) {
                        final results = _getFilteredResults();
                        return ListView.builder(
                          itemCount: results.length + (_isLoading ? 1 : 0),
                          shrinkWrap: true,
                          // Important to allow ListView inside Column
                          physics: const NeverScrollableScrollPhysics(),
                          // Prevent nested scrolling
                          itemBuilder: (context, index) {
                            if (index < results.length) {
                              final tuple = results[index];
                              return CustomGridView(
                                house: tuple.item1,
                                user: tuple.item2,
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySub.cancel();
    _searchController.dispose();
    _criteria.dispose();
    _unreadMsgSub.cancel();
    super.dispose();
  }
}
