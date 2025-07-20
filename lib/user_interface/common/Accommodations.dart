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
  final String currentUserUniversity = args['currentUserUniversity'];

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
  Timer? _debounce;
  String userInput = '';
  bool isFilteringByUserId = false;
  final TextEditingController _searchController = TextEditingController();
  int selectedButtonIndex = 0;
  FilterCriteria? _currentFilterCriteria;
  List<Tuple2<Listing_model, UserModel>> _filteredResults = [];

  // New variables for added functionality
  bool _showScrollToTopButton = false;

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
        if (_searchController.text.isNotEmpty) {
          setState(() {
            isFilteringByUserId = false;
            userInput = _searchController.text.toLowerCase().trim();
            _currentFilterCriteria = AccommodationFilter.extractCriteria(
              userInput,
            );
          });
        } else {
          setState(() {
            isFilteringByUserId = false;
            userInput = '';
            _currentFilterCriteria = null;
          });
        }
        _applyFilterAsync();
      });
    });

    _loadInitialData();

    _scrollController.addListener(() {
      // Show/hide scroll-to-top button
      if (_scrollController.offset >= 400 && !_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      } else if (_scrollController.offset < 400 && _showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }

      // Existing lazy loading
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreListings();
      }
    });
  }

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
    _applyFilterAsync();
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

    return combined;
  }

  Future<void> _applyFilterAsync() async {
    final studentUni = Provider.of<StudentProvider>(context, listen: false).currentUser?.uni ?? '';

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
      'currentUserUniversity': studentUni,
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
      print('Data from results: $resultJson');
      _isLoading = false;
    });
  }

  void _filterAccommodations(String input) {
    setState(() {
      userInput = input.toLowerCase().trim();
      _currentFilterCriteria = AccommodationFilter.extractCriteria(
        userInput,
      );
    });
    _applyFilterAsync();
  }

  void _filterByUserId(String userId) {
    setState(() {
      isFilteringByUserId = true;
      userInput = userId;
      _searchController.clear();
      _currentFilterCriteria = null;
    });
    _applyFilterAsync();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      userInput = '';
      isFilteringByUserId = false;
      _currentFilterCriteria = null;
      selectedButtonIndex = 0;
    });
    _applyFilterAsync();
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;

    final theme = Theme.of(context).textTheme;
    final user = context.watch<UserProvider>().user;
    final studentUni = context.watch<StudentProvider>().currentUser?.uni ?? '';
    final displayData = _filteredResults;

    return user != null ? Scaffold(
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
                  Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  ).setNewMessages(false);
                },
                icon: Icon(
                  CupertinoIcons.bell_solid,
                  color: notificationProvider.hasNewMessages
                      ? Colors.red
                      : Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
        backgroundColor: blue900,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      )
          : null,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: hightTen),
            Text(
              'Hi ${user.userName}',
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
              onChange: (String) {},
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
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    ) : const Center(child: CircularProgressIndicator());
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
                  // Only clear if selecting a different button
                  if (selectedButtonIndex != index) {
                    _clearSearch();
                  }

                  setState(() {
                    // Toggle if same button pressed
                    if (selectedButtonIndex == index) {
                      selectedButtonIndex =0 ; // Deselect
                      userInput = '';
                      _currentFilterCriteria = null;
                    } else {
                      selectedButtonIndex = index;
                      userInput = filter['query']!;
                      _currentFilterCriteria =
                          AccommodationFilter.extractCriteria(userInput);
                    }
                    isFilteringByUserId = false;
                  });
                  _applyFilterAsync();
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
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
