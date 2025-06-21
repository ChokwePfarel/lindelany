import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:lindelany/user_interface/landlord/to_moreInfo_OrCreateAcc.dart';
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

class accomList extends StatefulWidget {
  const accomList({super.key});

  @override
  State<accomList> createState() => _accomListState();
}

class _accomListState extends State<accomList> {
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

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: customCard1(
                            widgett: ListTile(
                              trailing: Container(
                                width: screenWidth * 0.23,
                                height: screenHeight * 0.23,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ColorFiltered(
                                  colorFilter: accommodation.isFull
                                      ? ColorFilter.mode(
                                          Colors.red.withOpacity(0.5),
                                          BlendMode.srcOver,
                                        )
                                      : ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.srcOver,
                                        ),
                                  child:
                                      accommodation.pictureUrl.startsWith(
                                        'http',
                                      )
                                      ? Image.network(
                                          accommodation.pictureUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          accommodation.pictureUrl,
                                          fit: BoxFit.cover,
                                        ),
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
                                        detailedListing(house: accommodation),
                                  ),
                                );
                              },
                            ),
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
                              builder: (context) => createOrCollect(),
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
