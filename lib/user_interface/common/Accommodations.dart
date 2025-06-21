import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  final FilterCriteria criteria = FilterCriteria.fromJson(criteriaJson);

  return allCombinedDataJson.where((tupleMap) {
    final accommodation = Listing_model.fromJson(tupleMap['listing']);
    // final user = UserModel.fromJson(tupleMap['user']); // User model is not used in filtering logic, only for display

    if (isFilteringByUserId) {
      return accommodation.userId == userInput;
    }
    return criteria.matches(accommodation);
  }).toList();
}

class _AccomodationsState extends State<Accomodations> {
  final ScrollController _scrollController = ScrollController();
  final Listing _listing = Listing();

  List<Listing_model> _listings = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  Timer? _debounce; // Debounce timer

  String userInput = '';
  bool isFilteringByUserId = false;
  final TextEditingController _searchController = TextEditingController();
  int selectedButtonIndex = 0;

  FilterCriteria? _currentFilterCriteria; // Cached filter criteria
  List<Tuple2<Listing_model, UserModel>> _filteredResults = []; // Store filtered results

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () { // Debounce for 300ms
        if (_searchController.text.isNotEmpty) {
          setState(() {
            isFilteringByUserId = false;
            userInput = _searchController.text.toLowerCase().trim();
            _currentFilterCriteria = AccommodationFilter.extractCriteria(userInput);
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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreListings();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer when widget is disposed
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //Lazy loading
  Future<void> _loadInitialData() async {
    await _loadMoreListings(); // Load first page
    UserProvider().allUsers.listen((users) {
      setState(() {
        _users = users;
      });
      _applyFilterAsync(); // Apply filter after users are loaded
    });
    _applyFilterAsync(); // Apply filter after initial listings are loaded
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
    final userMap = {for (var u in _users) u.userId: u.toJson()}; // Serialize UserModel
    return _listings
        .map((listing) {
      final userJson = userMap[listing.userId];
      if (userJson == null) return null;
      return {
        'listing': listing.toJson(), // Serialize Listing_model
        'user': userJson,
      };
    })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _applyFilterAsync() async {
    if (_isLoading) return; // Don't filter while loading more listings

    setState(() => _isLoading = true); // Indicate filtering in progress

    final allCombinedDataJson = _combineListingsAndUsersJson();
    final currentCriteriaJson = _currentFilterCriteria?.toJson(); // Convert FilterCriteria to JSON

    if (currentCriteriaJson == null && !isFilteringByUserId) {
      setState(() {
        _filteredResults = allCombinedDataJson.map((map) => Tuple2(Listing_model.fromJson(map['listing']), UserModel.fromJson(map['user']))).toList();
        _isLoading = false;
      });
      return;
    }

    // Pass serialized data to the isolate
    final resultJson = await compute(_performFiltering, {
      'allData': allCombinedDataJson,
      'criteria': currentCriteriaJson ?? {}, // Pass an empty map if no criteria
      'isFilteringByUserId': isFilteringByUserId,
      'userInput': userInput,
    });

    setState(() {
      // Deserialize the results back into Tuple2<Listing_model, UserModel>
      _filteredResults = resultJson.map((map) => Tuple2(Listing_model.fromJson(map['listing']), UserModel.fromJson(map['user']))).toList();
      _isLoading = false;
    });
  }

  void _filterAccommodations(String input) {
    setState(() {
      userInput = input.toLowerCase().trim();
      _currentFilterCriteria = AccommodationFilter.extractCriteria(userInput); // Update cached criteria
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
                  Provider.of<NotificationProvider>(context, listen: false).setNewMessages(false);
                },
                icon: Icon(
                  CupertinoIcons.bell_solid,
                  color: notificationProvider.hasNewMessages
                      ? Colors.red // or any color for active notifications
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
              'Hi ${user!.userName ?? ''}',
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
              itemCount: displayData.length + (_isLoading ? 1 : 0), // Show loading indicator
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
                    _currentFilterCriteria = AccommodationFilter.extractCriteria(userInput); // Update cached criteria
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
  }}