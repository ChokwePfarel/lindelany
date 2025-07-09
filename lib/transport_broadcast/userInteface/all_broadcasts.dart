import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final List<BroadcastModel> _broadcasts = [];
  bool _isLoading = false;
  List<UserModel> _users = [];

  final ValueNotifier<String> currentFilter = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    currentFilter.addListener(() => setState(() {}));

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

  List<Tuple2<UserModel, BroadcastModel>> _combineBroadcastAndUsers(
    String filter,
  ) {
    final userMap = {for (var u in _users) u.userId: u};
    return _broadcasts
        .where((broadcast) => broadcast != null) // Filter out null broadcasts
        .map((broadcast) {
          final user = userMap[broadcast.userId];
          if (user == null) return null;

          // Apply filter if not empty
          if (filter.isNotEmpty &&
              (broadcast.uni == null || broadcast.uni != filter)) {
            return null;
          }

          return Tuple2(user, broadcast);
        })
        .whereType<Tuple2<UserModel, BroadcastModel>>()
        .toList();
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
            children: quickFiltersUni.map((filter) {
              final label = filter['label'] ?? '';
              final query = filter['query'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(label),
                  selected: value == query,
                  onSelected: (_) => currentFilter.value = query,
                  selectedColor: blue900,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: value == query ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,
        title: const Center(
          child: lindelani(isLindeWhite: true, isLWhite: true),
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
            builder: (context, notificationProvider, child) {
              return IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllChats()),
                  );
                  // Reset notification state when opening chats
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
      drawer: const customDrawe(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.screenHeight * 0.012),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFilterChips(currentFilter),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.012),

            // The list view now needs fixed height to prevent unbounded height error
            SizedBox(
              height: SizeConfig.screenHeight * 0.7, // or use MediaQuery
              child: ValueListenableBuilder<String>(
                valueListenable: currentFilter,
                builder: (context, filter, _) {
                  final combinedData = _combineBroadcastAndUsers(filter);

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels ==
                          scrollNotification.metrics.maxScrollExtent) {
                        _loadMoreBroadcasts();
                      }
                      return false;
                    },
                    child: combinedData.isEmpty && !_isLoading
                        ? Center(
                            child: Text(
                              'No broadcasts available',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                combinedData.length +
                                (_broadcast.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < combinedData.length) {
                                final tuple = combinedData[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCardBroadcast(
                                    broadcast: tuple.item2,
                                    user: tuple.item1,
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : const SizedBox.shrink(),
                                  ),
                                );
                              }
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    currentFilter.dispose();

    super.dispose();
  }
}
