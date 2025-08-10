import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/custom_made/for_press/customElevated.dart';
import 'package:lindelany/transport_broadcast/create/create_vehicle.dart';
import 'package:lindelany/transport_broadcast/userInteface/car_profile.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/user.dart';
import '../../methods_Funtions/Navigation.dart';
import '../../methods_Funtions/chatService.dart';
import '../../providers/notification_bell.dart';
import '../../user_interface/Common/chats.dart';
import '../../user_interface/Common/drawer.dart';
import '../broadcast_vehicle_model.dart';
import '../from_firebase/broadcast.dart';
import '../from_firebase/transport.dart';
import '../widgets/for_all_brodcast.dart';

class AllBroadcast extends StatefulWidget {
  const AllBroadcast({super.key});

  @override
  State<AllBroadcast> createState() => _AllBroadcastState();
}

class _AllBroadcastState extends State<AllBroadcast> {
  final ScrollController _scrollController = ScrollController();
  final broadcast _broadcast = broadcast();
  final List<BroadcastModel> _broadcasts = [];

  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isDisposed = false;

  final ValueNotifier<String> currentFilter = ValueNotifier('');
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  StreamSubscription<bool>? _unreadMsgSub;

  bool _exist = false;
  bool _isLoadingInitial = true; // replaces separate _isCheckingDoc and _isLoading at startup


  @override
  void initState() {
    super.initState();
    _initializeUnreadStream();
    _loadStartupData();
    currentFilter.addListener(() => !_isDisposed ? setState(() {}) : null);
    _scrollController.addListener(_scrollListener);
  }

  void _initializeUnreadStream() {
    _unreadMsgSub?.cancel();
    _unreadMsgSub = ChatServices().unreadMessagesStream.listen((hasUnread) {
      if (!_isDisposed) {
        Provider.of<NotificationProvider>(context, listen: false).setNewMessages(hasUnread);
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBroadcasts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _users = await UserProvider().allUsers.firstWhere((u) => u.isNotEmpty, orElse: () => []);
      await _loadMoreBroadcasts();
    } catch (e) {
      debugPrint('Initial load error: $e');
    } finally {
      if (!_isDisposed) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreBroadcasts() async {
    if (_isLoading || !_broadcast.hasMore || _isDisposed) return;
    setState(() => _isLoading = true);

    try {
      final newBroadcasts = await _broadcast.fetchBroadcasts();
      if (!_isDisposed) {
        setState(() => _broadcasts.addAll(newBroadcasts));
      }
    } catch (e) {
      debugPrint('Error loading more broadcasts: $e');
    } finally {
      if (!_isDisposed) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStartupData() async {
    setState(() => _isLoadingInitial = true);

    try {
      // Check vehicle doc
      final bool isExist = await CustomNavigation().getDocumentBool('Vehicle');
      _exist = isExist;

      // If it exists, load the first batch of data
      if (_exist) {
        _users = await UserProvider().allUsers.firstWhere((u) => u.isNotEmpty, orElse: () => []);
        await _loadMoreBroadcasts();
      }
    } catch (e) {
      debugPrint('Startup load error: $e');
    } finally {
      if (!_isDisposed) setState(() => _isLoadingInitial = false);
    }
  }


  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    try {
      _broadcast.resetPagination();
      final users = await UserProvider().allUsers.firstWhere((u) => u.isNotEmpty, orElse: () => []);
      final freshBroadcasts = await _broadcast.fetchBroadcasts(reset: true);
      if (!_isDisposed) {
        setState(() {
          _users = users;
          _broadcasts
            ..clear()
            ..addAll(freshBroadcasts);
        });
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    } finally {
      if (!_isDisposed) setState(() => _isLoading = false);
    }
  }

  List<Tuple2<UserModel, BroadcastModel>> _combinedData(String filter) {
    final userMap = {for (var user in _users) user.userId: user};
    return _broadcasts
        .where((b) => b != null)
        .map((b) {
      final user = userMap[b.userId];
      if (user == null || (filter.isNotEmpty && b.uni != filter)) return null;
      return Tuple2(user, b);
    })
        .whereType<Tuple2<UserModel, BroadcastModel>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final vehicleData = Provider.of<CreateTransport>(context).vehicleProfile;
    final isExpired = vehicleData?.paymentExpiryDate.isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(_exist),
      drawer: const customDrawe(),
      body: _isLoadingInitial ? const Center(child: CircularProgressIndicator()) :
      _exist  ?
      RefreshIndicator(
        key: _refreshKey,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: screenHeight * 0.008)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
              sliver: SliverToBoxAdapter(child: _buildFilterChips()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ValueListenableBuilder<String>(
              valueListenable: currentFilter,
              builder: (_, filter, __) {
                final data = _combinedData(filter);
                if (data.isEmpty && !_isLoading) return _emptySliver(context);
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < data.length) {
                        final tuple = data[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CustomCardBroadcast(
                            broadcast: tuple.item2,
                            user: tuple.item1,
                          ),
                        );
                      }
                      return _broadcast.hasMore
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : const SizedBox.shrink();
                    },
                    childCount: data.length + (_broadcast.hasMore ? 1 : 0),
                  ),
                );
              },
            ),
          ],
        ),
      )
      : Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'You do not have a profile yet',
              style: theme.bodyMedium!.copyWith(color: blue900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.010),
            const customElevated(
              nextPage: Vehicle(),
              LabelText: 'Create',
            ),
          ],
        ),
      )
    );
  }

  AppBar _buildAppBar(bool exist) {
    return AppBar(
      backgroundColor: blue900,
      automaticallyImplyLeading: false,
      title: const Center(child: lindelani(isLindeWhite: true, isLWhite: true)),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child:
          exist ?
          IconButton(
            icon: Icon(CupertinoIcons.person_fill, size: 27, color: blue900),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CarProfile()),
            ),
          ) : Icon(CupertinoIcons.person_fill, size: 27, color: blue900),
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (_, provider, __) => IconButton(
            icon: Icon(
              CupertinoIcons.chat_bubble_fill,
              color: provider.hasNewMessages ? Colors.red : Colors.white,
              size: 27,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllChats()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickFilters
            .where((f) => f['label']?.toLowerCase() != 'nsfas')
            .map((f) {
          final label = f['label'] ?? '';
          final query = f['query'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: currentFilter.value == query,
              onSelected: (_) => currentFilter.value = query,
              selectedColor: blue900,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: currentFilter.value == query ? Colors.white : Colors.black,
              ),
            ),
          );
        })
            .toList(),
      ),
    );
  }

  SliverToBoxAdapter _emptySliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No broadcasts available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    currentFilter.dispose();
    _unreadMsgSub?.cancel();
    super.dispose();
  }
}
