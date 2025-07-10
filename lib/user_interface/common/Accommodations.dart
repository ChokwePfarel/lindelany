import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/firebase_Set/setStudent.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart' show Listing_model;
import '../../constants/Lists.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/customInput.dart';
import '../../custom_made/widgets/custom_cardView.dart';
import '../../firebase_Set/user.dart';
import '../../providers/notification_bell.dart';
import 'chats.dart';
import 'drawer.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/houseListing.dart';
import '../../methods_Funtions/accommodationFilter.dart';
import '../../classes/user_model.dart';

class Accomodations extends StatefulWidget {
  const Accomodations({super.key});

  @override
  State<Accomodations> createState() => _AccomodationsState();
}

// Top-level function for filtering (must be static or a top-level function)
List<Map<String, dynamic>> _performFiltering(Map<String, dynamic> args) {
  final List<Map<String, dynamic>> allCombinedDataJson = args['allData'];
  final Map<String, dynamic> criteriaJson = args['criteria'];
  final bool isFilteringByUserId = args['isFilteringByUserId'];
  final String userInput = args['userInput'];
 final String currentUserUniversity =  'university of pretoria';

  final FilterCriteria criteria = FilterCriteria.fromJson(criteriaJson);

  return allCombinedDataJson.where((tupleMap) {
    final accommodation = Listing_model.fromJson(tupleMap['listing']);

    if (isFilteringByUserId) {
      return accommodation.userId == userInput;
    }

    return criteria.matches(
      accommodation,
      currentUserUniversity: currentUserUniversity,
    );
  }).toList();
}

class _AccomodationsState extends State<Accomodations> {
  final ScrollController _scrollController = ScrollController();
  final Listing _listing = Listing();

  final List<Listing_model> _listings = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  Timer? _debounce; // Debounce timer

  String userInput = '';
  bool isFilteringByUserId = false;
  final TextEditingController _searchController = TextEditingController();
  int selectedButtonIndex = 0;

  FilterCriteria? _currentFilterCriteria; // Cached filter criteria
  List<Tuple2<Listing_model, UserModel>> _filteredResults =
      []; // Store filtered results

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUser(),
    );

    Future.microtask(() =>
        Provider.of<StudentProvider>(context, listen: false).currentStudent());

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        // Debounce for 300ms
        if (_searchController.text.isNotEmpty) {
          setState(() {
            isFilteringByUserId = false;
            userInput = _searchController.text.toLowerCase().trim();
            _currentFilterCriteria = AccommodationFilter.extractCriteria(
              userInput,
            );
          });
        } else {
          // Handle clearing the search
          setState(() {
            isFilteringByUserId = false;
            userInput = '';
            _currentFilterCriteria = null;
          });
        }
        _applyFilterAsync(); // Trigger async filter after debounce
      });
    });

    _loadInitialData(); // Lazy loading

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreListings();
      }
    });
  }



  //Lazy loading
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final newListings = await _listing.fetchListings();

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .get();
    final users = usersSnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();

    setState(() {
      _listings.addAll(newListings);
      _users = users;
      _isLoading = false;
    });

    _applyFilterAsync();
  }

  Future<void> _loadMoreListings() async {
    if (_isLoading || !_listing.hasMore) return;
    setState(() => _isLoading = true);

    final newListings = await _listing.fetchListings();
    setState(() {
      _listings.addAll(newListings);
      _isLoading = false;
    });
    _applyFilterAsync(); // Apply filter after more listings are loaded
  }

  List<Map<String, dynamic>> _combineListingsAndUsersJson() {
    final userMap = {for (var u in _users) u.userId: u.toJson()};

    final combined = _listings
        .map((listing) {
          final userJson = userMap[listing.userId];
          if (userJson == null) {
            print('User not found for listing: ${listing.userId}');
            return null;
          }
          return {'listing': listing.toJson(), 'user': userJson};
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    print('Combined user-listing pairs: ${combined.length}');
    return combined;
  }

  Future<void> _applyFilterAsync() async {
    if (_isLoading) return;

    final allCombinedDataJson = _combineListingsAndUsersJson();
    if (allCombinedDataJson.isEmpty) {
      setState(() {
        _filteredResults = [];
        _isLoading = false;
      });
      print('No matching user-listing pairs found.');
      return;
    }

    setState(() => _isLoading = true);

    final currentCriteriaJson = _currentFilterCriteria?.toJson();

    if (currentCriteriaJson == null && !isFilteringByUserId) {
      setState(() {
        _filteredResults = allCombinedDataJson
            .map(
              (map) => Tuple2(
                Listing_model.fromJson(map['listing']),
                UserModel.fromJson(map['user']),
              ),
            )
            .toList();
        _isLoading = false;
      });
      return;
    }

    final resultJson = await compute(_performFiltering, {
      'allData': allCombinedDataJson,
      'criteria': currentCriteriaJson ?? {},
      'isFilteringByUserId': isFilteringByUserId,
      'userInput': userInput,
      //'currentUserUniversity': Provider.of<StudentProvider>(context,listen false).currentUser?.uni ?? ''
    });

    setState(() {
      _filteredResults = resultJson
          .map(
            (map) => Tuple2(
              Listing_model.fromJson(map['listing']),
              UserModel.fromJson(map['user']),
            ),
          )
          .toList();
      print('Data from results: ${resultJson}');
      _isLoading = false;
    });
  }

  void _filterAccommodations(String input) {
    setState(() {
      userInput = input.toLowerCase().trim();
      _currentFilterCriteria = AccommodationFilter.extractCriteria(
        userInput,
      ); // Update cached criteria
    });
    _applyFilterAsync(); // Trigger async filter immediately on quick filter press
  }

  void _filterByUserId(String userId) {
    setState(() {
      isFilteringByUserId = true;
      userInput = userId;
      _searchController.clear();
      _currentFilterCriteria = null; // Clear criteria when filtering by user ID
    });
    _applyFilterAsync();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      userInput = '';
      isFilteringByUserId = false;
      _currentFilterCriteria = null; // Clear criteria
      selectedButtonIndex = 0; // Reset selected quick filter
    });
    _applyFilterAsync(); // Apply filter to show all data
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;

    final theme = Theme.of(context).textTheme;

    final user = context.watch<UserProvider>().user;
    final studentUni = context.watch<StudentProvider>().currentUser?.uni ?? '';


    // Use _filteredResults directly
    final displayData = _filteredResults;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const customDrawe(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(child: lindelani(isLindeWhite: false, isLWhite: false)),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              icon: const Icon(
                CupertinoIcons.list_bullet,
                size: 30,
                color: Colors.grey,
              ),
            );
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllChats()),
                  );
                  // Reset notification state when opening chats
                  // ignore: use_build_context_synchronously
                  Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  ).setNewMessages(false);
                },
                icon: Icon(
                  CupertinoIcons.bell_solid,
                  color: notificationProvider.hasNewMessages
                      ? Colors
                            .red // or any color for active notifications
                      : Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: hightTen),
            Text(
              'Hi ${user!.userName}',
              style: theme.headlineSmall?.copyWith(
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
              onChange: (String) {
                // _filterAccommodations is now handled by the debounced listener
              },
            ),

            SizedBox(height: hightTen),
            singleChildScroll(),
            SizedBox(height: hightTen),
            Text(
              'Listing',
              style: theme.headlineSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayData.length + (_isLoading ? 1 : 0),
              // Show loading indicator
              itemBuilder: (context, index) {
                if (index < displayData.length) {
                  final tuple = displayData[index];
                  return CustomGridView(house: tuple.item1, user: tuple.item2);
                } else if (_isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink(); // Should not happen
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer when widget is disposed
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget singleChildScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(quickFilters.length, (index) {
          final filter = quickFilters[index];
          return Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 40),
                  backgroundColor: selectedButtonIndex == index
                      ? blue900
                      : Colors.grey,
                ),
                onPressed: () {
                  _clearSearch(); // Clear search and reset filter state
                  setState(() {
                    selectedButtonIndex = index;
                    userInput = filter['query']!;
                    isFilteringByUserId = false;
                    _currentFilterCriteria =
                        AccommodationFilter.extractCriteria(
                          userInput,
                        ); // Update cached criteria
                  });
                  _applyFilterAsync(); // Trigger async filter immediately
                },
                child: Text(
                  filter['label']!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (index < quickFilters.length - 1) boxx2,
            ],
          );
        }),
      ),
    );
  }
}
