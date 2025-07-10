import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:lindelany/create_edit/landlord/Create_Accommodation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../firebase_Set/UserAccomList.dart';
import '../../classes/user_model.dart';
import '../../utility/utility_class.dart';
import 'detailedListing.dart';

class MyListing extends StatefulWidget {
  const MyListing({super.key});

  @override
  State<MyListing> createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

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

    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        backgroundColor: blue900,
        automaticallyImplyLeading: false,
        title: Text(
          'My Listing',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<Tuple2<UserModel, List<Listing_model>>>(
            stream: combinedStream,
            builder: (Context, snapshot) {
              if (AsyncUtils.isLoadingOrError(snapshot)) {
                return AsyncUtils.BuildIsloadingOrError(snapshot);
              }

              final house = snapshot.data!.item2;
              print('Current user listings:${house.length}');

              return Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: house.length,
                      itemBuilder: (BuildContext context, index) {
                        final accommodation = house[index];

                        bool isExpired =
                            accommodation.paymentExpiryDate?.isBefore(
                              DateTime.now(),
                            ) ??
                            false;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              customCard1(
                                widgett: ListTile(
                                  trailing: Container(
                                    width: screenWidth * 0.23,
                                    height: screenHeight * 0.23,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        accommodation.pictureUrl.startsWith(
                                          'http',
                                        )
                                        ? CachedNetworkImage(
                                           imageUrl: accommodation.pictureUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            accommodation.pictureUrl,
                                            fit: BoxFit.cover,
                                          ) ,
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
                                        builder: (context) => detailedListing(
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
                      right: 20,
                      bottom: 20,
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue.shade900,
                        onPressed: () {
                          // Get the user from snapshot
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
              );
            },
          ),
        ],
      ),
    );
  }
}
