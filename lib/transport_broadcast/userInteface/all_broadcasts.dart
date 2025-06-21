import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/user.dart';
import '../../providers/notification_bell.dart';
import '../../user_interface/Common/chats.dart';
import '../../user_interface/Common/drawer.dart';
import '../broadcast_vehicle_model.dart';
import '../from_firebase/broadcast.dart';
import '../widgets/for_all_brodcast.dart';

// ... (your other imports remain the same)

class AllBroadcast extends StatefulWidget {
  const AllBroadcast({super.key});

  @override
  State<AllBroadcast> createState() => _AllBroadcastState();
}

class _AllBroadcastState extends State<AllBroadcast> {
  final ScrollController _scrollController = ScrollController();
  final broadcast _broadcast = broadcast();
  List<BroadcastModel> _broadcasts = [];
  bool _isLoading = false;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBroadcasts();
    }
  }



  Future<void> _loadInitialData() async {
    final users = await UserProvider().allUsers.first; // wait for users to load
    setState(() {
      _users = users;
    });
    await _loadMoreBroadcasts(); // then load broadcasts
  }



  Future<void> _loadMoreBroadcasts() async {
    if (_isLoading || !_broadcast.hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newBroadcasts = await _broadcast.fetchBroadcasts();
      if (!mounted) return;
      setState(() {
        _broadcasts.addAll(newBroadcasts);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Error loading broadcasts: $e');
    }
  }

  List<Tuple2<UserModel, BroadcastModel>> _combineBroadcastAndUsers() {
    final userMap = {for (var u in _users) u.userId: u};
    return _broadcasts.map((broadcast) {
      final user = userMap[broadcast.userId];
      if (user == null) {
        debugPrint('No user found for broadcast: ${broadcast.postId}');
        return null;
      }
      return Tuple2(user, broadcast);
    }).whereType<Tuple2<UserModel, BroadcastModel>>().toList();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildFilterChips(ValueNotifier<String> currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ValueListenableBuilder<String>(
        valueListenable: currentFilter,
        builder: (context, value, _) {
          return Row(
            children: List.generate(quickFiltersUni.length, (index) {
              final filter = quickFiltersUni[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter['label']!),
                  selected: value == filter['query'],
                  onSelected: (_) => currentFilter.value = filter['query']!,
                  selectedColor: blue900,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: value == filter['query'] ? Colors.white : Colors.black,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context).textTheme;
    final userData = Provider.of<UserProvider>(context).user;
    final ValueNotifier<String> _currentFilter = ValueNotifier('');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,
        title: const Center(child: lindelani(isLindeWhite: true, isLWhite: true)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(CupertinoIcons.list_bullet, size: 30, color: Colors.grey),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
      drawer: const customDrawe(),
      body: StreamBuilder<List<UserModel>>(
        stream: UserProvider().allUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          }

         // _users = snapshot.data!;
          final combinedData = _combineBroadcastAndUsers();

          return Column(
            children: [
              // Header section
              Padding(
                padding: paddingg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text('Hello ${userData?.userName ?? 'User'}!',
                        style: theme.headlineSmall?.copyWith(
                          color: blue900,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(getGreeting(), style: theme.bodyMedium?.copyWith(color: Colors.grey)),
                    SizedBox(height: SizeConfig.screenHeight * 0.012),
                    _buildFilterChips(_currentFilter),
                    SizedBox(height: SizeConfig.screenHeight * 0.012),
                    Text('Broadcast',
                        style: theme.headlineSmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),

              // Broadcast list
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                      _loadMoreBroadcasts();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: combinedData.length + (_broadcast.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < combinedData.length) {
                        final tuple = combinedData[index];

                        return Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 10),
                          child: CustomCardBroadcast(
                            broadcast: tuple.item2,
                            user: tuple.item1,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
