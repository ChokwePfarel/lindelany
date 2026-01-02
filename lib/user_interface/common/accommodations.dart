import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Constants/constants.dart';
import '../../classes/student_model.dart';
import '../../constants/lists.dart';
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
  final Listing _listingService = Listing();

  final List<Listing_model> _listings = [];
  List<UserModel> _users = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _showScrollToTop = false;
  bool _isConnected = true;

  Timer? _debounce;

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  late StreamSubscription<StudentModel> _studentSubscription;

  String? _currentSearch;
  String? _selectedUniversity;

  int selectedButtonIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkNetwork();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      connectivityResults,
    ) {
      setState(() {
        _isConnected = !connectivityResults.contains(ConnectivityResult.none);
      });
    });

    _setupStudentStream();

    _debounceSerach();

    _showFloat();

    _initData();
  }


  // Debounced search
  void _debounceSerach(){
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _currentSearch = _searchController.text.trim();
        _resetAndFetch();
      });
    });
  }

  //Student Stream
  void _setupStudentStream() {

    final studentProvider = Provider.of<StudentProvider>(
      context, listen: false,);

    _studentSubscription = studentProvider.currentStudentDoc().listen((
      student,) {
      if (mounted) {

        final newUniversity = student.uni ?? southAfricanUniversities.first;

        // Only update if university actually changed
        if (_selectedUniversity != newUniversity) {
          setState(() {
            _selectedUniversity = newUniversity;
          });
          _resetAndFetch();
        }
      }
    });
  }


  void _showFloat(){
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset < 400 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadListings();
      }
    });
  }

  Future<void> _initData() async {
    final studentProvider = Provider.of<StudentProvider>(
      context, listen: false,);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if data is already loaded
    if (studentProvider.currentStudentInfo == null ||
        userProvider.user == null) {
      //      debugPrint('Data not preloaded, fetching...');
      await Future.wait([
        userProvider.fetchUser(),
        studentProvider.currentStudent(),
      ]);
    }

    // Use the student's university or default (stream will handle updates)
    _selectedUniversity = studentProvider
        .currentStudentInfo
        ?.uni ;

    // Now fetch listings
    await _loadInitialData();
  }

  @override
  void dispose() {
    _studentSubscription.cancel();
    _scrollController.dispose();
    _connectivitySub.cancel();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _checkNetwork() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = !connectivityResults.contains(ConnectivityResult.none);
    });
  }

  Future<void> _loadInitialData() async {

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('Users').get();

    if(mounted){
      _users = Provider.of<UserProvider>(context,listen: false).helper(usersSnapshot);
    }

    await _loadListings();
  }

  Future<void> _loadListings() async {
    if (_isLoading || !_listingService.hasMore) return;
    setState(() => _isLoading = true);

    final newListings = await _listingService.fetchListings(
      searchText: _currentSearch,
      selectedUniversity: _selectedUniversity,
    );

    if (!mounted) return;
    setState(() {
      _listings.addAll(newListings);
      _isLoading = false;
    });
  }

  void _resetAndFetch() {
    _listingService.resetPagination();
    _listings.clear();
    _loadListings();
  }

  void _applyQuickFilter(String input, int index) {
    _searchController.clear();
    _currentSearch = input;
    setState(() => selectedButtonIndex = index);
    _resetAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;

    final theme = Theme.of(context).textTheme;

    final user = Provider.of<UserProvider>(context).user;

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
                          user.userName.length < 20
                              ? 'Hi ${user.userName}'
                              : 'Hi ${user.userName.substring(0, 20)}..',
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

                        //------------------------------------------------------------------SEARCH INPUT
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

                  //----------------------------------------------------------------FILTER BUTTONS
                  _buildQuickFilters(quickFilters, selectedButtonIndex),

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
                  //------------------------------------------------------------------------BANNER
                  if (!_isConnected) NetworkBanner.noInternet(),

                  //---------------------------------------------------------------------LISTVIEW
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

                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(color: blue900,)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

//---------------------------------------------------------------FLOATING BUTTON
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
}
