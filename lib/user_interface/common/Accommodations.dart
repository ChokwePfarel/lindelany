import 'package:flutter/cupertino.dart';
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

class _AccomodationsState extends State<Accomodations> {
  final ScrollController _scrollController = ScrollController();
  final Listing _listing = Listing();

  List<Listing_model> _listings = [];
  List<UserModel> _users = [];
  bool _isLoading = false;

  String userInput = '';
  bool isFilteringByUserId = false;
  final TextEditingController _searchController = TextEditingController();
  int selectedButtonIndex = 0;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          isFilteringByUserId = false;
          userInput = _searchController.text.toLowerCase().trim();
        });
      }
    });

    //easy loading
    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreListings();
      }
    });

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          isFilteringByUserId = false;
          userInput = _searchController.text.toLowerCase().trim();
        });
      }
    });
  }

  //Lazy loading
  Future<void> _loadInitialData() async {
    await _loadMoreListings(); // Load first page
    UserProvider().allUsers.listen((users) {
      setState(() {
        _users = users;
      });
    });
  }

  Future<void> _loadMoreListings() async {
    if (_isLoading || !_listing.hasMore) return;
    setState(() => _isLoading = true);

    final newListings = await _listing.fetchListings();
    setState(() {
      _listings.addAll(newListings);
      _isLoading = false;
    });
  }

  List<Tuple2<Listing_model, UserModel>> _combineListingsAndUsers() {
    final userMap = {for (var u in _users) u.userId: u};
    return _listings
        .map((listing) {
          final user = userMap[listing.userId];
          if (user == null) return null;
          return Tuple2(listing, user);
        })
        .whereType<Tuple2<Listing_model, UserModel>>()
        .toList();
  }

  void _filterAccommodations(String input) {
    setState(() {
      userInput = input.toLowerCase().trim();
    });
  }

  void _filterByUserId(String userId) {
    setState(() {
      isFilteringByUserId = true;
      userInput = userId;
      _searchController.clear();
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;

    final theme = Theme.of(context).textTheme;

    final user = context.watch<UserProvider>().user;

    final filteredData = _combineListingsAndUsers().where((tuple) {
      final accommodation = tuple.item1;
      if (isFilteringByUserId) {
        return accommodation.userId == userInput;
      }
      final criteria = AccommodationFilter.extractCriteria(userInput);
      return criteria.matches(accommodation);
    }).toList();

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
              icon: Icon(
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
                    Provider.of<NotificationProvider>(context, listen: false)
                        .setNewMessages(false);
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
                _filterAccommodations;
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
              itemCount: filteredData.length + (_listing.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < filteredData.length) {
                  final tuple = filteredData[index];
                  return CustomGridView(house: tuple.item1, user: tuple.item2);
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
                  _clearSearch();
                  setState(() {
                    selectedButtonIndex = index;
                    userInput = filter['query']!;
                    isFilteringByUserId = false; // Ensure it uses area filter
                    _filterAccommodations(userInput);
                  });
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
  String getGreeting() {
    var hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
