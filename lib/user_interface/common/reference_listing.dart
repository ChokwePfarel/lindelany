import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lindelany/Constants/constants.dart';

import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/current_user_doc.dart';
import 'gallery.dart';

class ReferenceListing extends StatelessWidget {
  final String? landlordId;

  const ReferenceListing({super.key, this.landlordId});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final stream = AccomStream().userAccommodations(landlordId!);

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),

          StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: blue900));
              }

              final listing = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  itemCount: listing.length,
                  itemBuilder: (context, index) {
                    final aListing = listing[index];

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
                                child: aListing.pictureUrl.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: aListing.pictureUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        aListing.pictureUrl,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              title: Text(
                                aListing.accommodationName.length < 20
                                    ? aListing.accommodationName
                                    : aListing.accommodationName.substring(
                                        0,
                                        21,
                                      ),
                                style: GoogleFonts.poppins(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.red,
                                ),*/
                                  Text(
                                    aListing.location.length < 20
                                        ? aListing.location
                                        : aListing.location.substring(0, 20),
                                  ),
                                  Text(
                                    aListing.location.length < 20
                                        ? aListing.address
                                        : aListing.address.substring(0, 20),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Gallery(house: aListing),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
