import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Constants/Constants.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../methods_Funtions/expand.dart';
import '../../classes/user_model.dart';

class AnAccommodation extends StatefulWidget {
  final Listing_model house;
  final UserModel user;

  const AnAccommodation({
    super.key,
    required this.house,
    required this.user,
    //this.student,
  });

  @override
  State<AnAccommodation> createState() => _AnAccommodationState();
}

class _AnAccommodationState extends State<AnAccommodation> {
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );
  final ScrollController _scrollController = ScrollController();

  Future<void> openDialpad(String phone) async {
    final Uri phoneNum = Uri(scheme: 'tel', path: widget.house.phoneNumbers);
    if (await canLaunchUrl(phoneNum)) {
      await launchUrl(phoneNum);
    } else {
      throw 'Failed to launch dial pad with ${widget.house.phoneNumbers}';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Fetch current user
    Provider.of<UserProvider>(context, listen: false).fetchUser();

    //The page initialy is at the bottom and suddenly jumps up, fixe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;
    final screenWidth = SizeConfig.screenWidth;
    final screenHight = SizeConfig.screenHeight;

    final stream = FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.house.accommodationId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    final UserProviderr = Provider.of<UserProvider>(context).user;
    final bool isStudent = UserProviderr?.userType == 'Student';
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: grey100,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
             // const SizedBox(height: 20),

              Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    //Optimized the stream to avaoid double loading
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height:
                              MediaQuery.of(context).size.height * (270 / MediaQuery.of(context).size.height),
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          height:
                              MediaQuery.of(context).size.height *
                              (300 / MediaQuery.of(context).size.height),
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.error)),
                        );
                      }

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final imagesUrls = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['imageUrl'] as String;
                        }).toList();

                        // Replace your current CarouselSlider implementation with this:
                        return CarouselSlider(
                          options: CarouselOptions(
                            height:
                                MediaQuery.of(context).size.height *
                                (400 / MediaQuery.of(context).size.height),
                            autoPlay: true,
                            //enlargeCenterPage: true, showing next images on the edges
                            aspectRatio: 16 / 9,
                            viewportFraction: 1.0,
                            // Prevents showing adjacent images
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration: const Duration(
                              milliseconds: 1200,
                            ),
                            // Slower transition
                            autoPlayCurve: Curves.easeInOut,
                            // More relaxed slide effect
                            pauseAutoPlayOnTouch: true,
                          ),
                          items: imagesUrls.map((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  // Rounded corners
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,

                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      }

                      final a = screenHight * 0.30;
                      final b = screenHight * 0.30;
                      final ab = a + b;

                      // Fallback if no images
                      return Container(
                        height: ab,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(CupertinoIcons.camera_fill, size: 40),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.house.accommodationName,
                          style: theme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            //backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                       // boxx,
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: widthTen),
                            Text(
                              widget.house.location,
                              style: theme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                //backgroundColor: Colors.black.withOpacity(0.5),

                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: widthTen),

              //Texts----------------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.house.isNsfas
                            ? Icons.verified_outlined
                            : Icons.money,
                        color: Colors.green.shade800,
                      ),
                      SizedBox(width: widthTen),
                      Text(
                        widget.house.isNsfas ? "NSFAS accredited" : "Cash",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: hightTen),
                  customCard1(
                    widgett: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prices',
                          style: theme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: hightTen),
                        Text(
                          'Available space | ${widget.house.availableRooms}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: hightTen),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customColums(
                              textt: 'Single',
                              text: 'R${widget.house.singleRoomPrice}',
                            ),
                            customColums(
                              textt: 'Sharing(2)',
                              text: 'R${widget.house.doubleRoomPrice}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: widthTen),
                  customCard1(
                    widgett: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amenities',
                          style: theme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: hightTen),
                        Text(
                          'Available ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: hightTen),

                        Wrap(
                          spacing: 8.0, // Space between elements
                          runSpacing: 4.0, // Space between lines
                          children: [
                            if (widget.house.isWifi)
                              iconBox(
                                IIcon: CupertinoIcons.wifi,
                                textt: 'Wifi',
                              ),
                            if (widget.house.isParking)
                              iconBox(
                                IIcon: Icons.local_parking_rounded,
                                textt: 'Parking',
                              ),
                            if (widget.house.laundry)
                              iconBox(
                                IIcon: Icons.local_laundry_service_rounded,
                                textt: 'Laundry machine',
                              ),
                            if (widget.house.security)
                              iconBox(
                                IIcon: CupertinoIcons.lightbulb_fill,
                                textt: 'Electricity included',
                              ),
                            if (widget.house.bed)
                              iconBox(
                                IIcon: CupertinoIcons.bed_double_fill,
                                textt: 'Bed provided',
                              ),
                            if (widget.house.tv)
                              iconBox(
                                IIcon: CupertinoIcons.book_fill,
                                textt: 'Study area',
                              ),
                            if (widget.house.shower)
                              iconBox(
                                IIcon: Icons.water_drop_rounded,
                                textt: 'Water included',
                              ),
                            if (widget.house.kitchen)
                              iconBox(IIcon: Icons.kitchen, textt: 'Kitchen'),
                          ],
                        ),

                        SizedBox(height: 5),
                        Text(
                          'Hold icon for details',
                          style: theme.bodySmall?.copyWith(color: blue900),
                        ),
                        boxx,
                      ],
                    ),
                  ),
                  SizedBox(height: widthTen),
                  ExpandableTextCard(
                    title: 'Description',
                    text: widget.house.aboutAccom,
                    trimLength: 100,
                    controller: _scrollController,
                  ),
                  SizedBox(height: hightTen),
                  ExpandableTextCard(
                    title: 'Payments',
                    text: widget.house.aboutPayment,
                    trimLength: 60,
                    controller: _scrollController,
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.020),
                  isStudent ? getRow(screenWidth, hightTen) : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getRow(screenWidth, hightten) {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.26,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                openDialpad(widget.house.phoneNumbers);
              },
              child: Icon(Icons.call, color: Colors.blue.shade900, size: 20),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: screenWidth * 0.64, //height 250
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Provider.of<chatProvider>(
                  context,
                  listen: false,
                ).navigateToChat(context, widget.user);
              },
              child: Text(
                'Message',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

