import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:lindelany/create_edit/landlord/Create_Accommodation.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/lindelani.dart';
import '../../firebase_Set/user.dart';
import '../../firebase_Set/UserAccomList.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/chatService.dart';
import '../../providers/notification_bell.dart';
import '../../static/utils.dart';
import '../../utility/utility_class.dart';
import '../Common/chats.dart';
import 'detailedListing.dart';

class MyListing extends StatefulWidget {
  const MyListing({super.key});

  @override
  State<MyListing> createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {
  late StreamSubscription<bool> _unreadMsgSub;

  @override
  void initState() {
    super.initState();

    // Listen to global unread messages stream
    _unreadMsgSub = ChatServices().unreadMessagesStream.listen((hasUnread) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).setNewMessages(hasUnread);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final theme = TextTheme.of(context);
    final theStyle =  theme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: blue900,
    );

    final stream1 = UserProvider().currentUserData();
    final stream3 = accomStream().userAccommodations;
    final combinedStream =
    Rx.combineLatest2<
        UserModel,
        List<Listing_model>,
        Tuple2<UserModel, List<Listing_model>>
    >(
      stream1,
      stream3,
          (userInfo, UserAccommodations) =>
          Tuple2(userInfo, UserAccommodations),
    );

    return StreamBuilder<Tuple2<UserModel, List<Listing_model>>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (AsyncUtils.isLoadingOrError(snapshot)) {
          return AsyncUtils.BuildIsloadingOrError(snapshot);
        }
        final house = snapshot.data!.item2;
        final user = snapshot.data!.item1;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: blue900,
            automaticallyImplyLeading: false,
            title: lindelani(isLindeWhite: true, isLWhite: true),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  return IconButton(
                    onPressed: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllChats()),
                        ),
                    icon: Icon(
                      size: 27,
                      CupertinoIcons.chat_bubble_fill,
                      color: provider.hasNewMessages ? Colors.red : Colors
                          .white,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight *0.010),
                    Row(
                      children: [
                        Text(
                          'Hi',
                          style: theStyle,
                        ),
                        SizedBox(width: screenWidth *0.010),
                        Text(user.userName,
                          style: theme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),)
                      ],
                    ),
                    Text(
                      utils.getGreeting(),
                      style: theStyle,
                      ),

                    SizedBox(height: screenHeight *0.05),
                    Text(
                      'My Properties',
                      style: theme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // List Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only( bottom: 5),
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: house.length,
                        itemBuilder: (BuildContext context, index) {
                          final accommodation = house[index];
                          bool isExpired = accommodation.paymentExpiryDate
                              ?.isBefore(
                            DateTime.now(),
                          ) ?? false;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                customCard1(
                                  colorr: Colors.grey,
                                  widgett: ListTile(
                                    trailing: Container(
                                      width: screenWidth * 0.23,
                                      height: screenHeight * 0.23,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: accommodation.pictureUrl
                                          .startsWith('http')
                                          ? CachedNetworkImage(
                                        imageUrl: accommodation.pictureUrl,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        accommodation.pictureUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      accommodation.accommodationName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.red,
                                        ),
                                        Text(accommodation.location),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              detailedListing(
                                                house: accommodation,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (isExpired)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'EXPIRED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: screenWidth * 0.05,
                        bottom: screenHeight * 0.05,
                        child: FloatingActionButton(
                          backgroundColor: Colors.blue.shade900,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAcc(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}