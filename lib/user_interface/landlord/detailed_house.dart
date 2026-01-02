import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:lindelany/firebase_Set/set_listing.dart';
import 'package:lindelany/methods_Funtions/ImageUpload.dart';
import 'package:lindelany/payments/plans.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/getVerified.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../create_edit/landlord/edit_accommodation.dart';
import '../../custom_made/for_press/customElevated.dart';
import '../../custom_made/widgets/colums.dart';
import '../../methods_Funtions/expand.dart';
import '../../methods_Funtions/get_listing_images.dart';
import '../../payments/webview.dart';


class DetailedListing extends StatefulWidget {
  final Listing_model house;

  const DetailedListing({super.key, required this.house});

  @override
  State<DetailedListing> createState() => _DetailedListingState();
}

class _DetailedListingState extends State<DetailedListing> {

  final  listingService = Listing();

  final ScrollController _scrollController = ScrollController();

  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();

  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await GetImages().getListingImages(widget.house.accommodationId);
      setState(() {
        _imageUrls = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
//      //       print('Error loading images: $e');
    }
  }


  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  void _paymentsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Chose a Plan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: blue900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ...subscriptionPlans.map((plan) {
                return GestureDetector(
                  onTap: () async {

                    await analytics.logEvent(
                      name: 'payment_click',
                      parameters : {
                        'name': plan.name,
                    'price': plan.price

                    }
                    );
//                    print('Analytics Event Logged: listing_plan_click - ${plan.name}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YocoWebView(
                          plan: plan,
                          collection: 'Accommodation',
                          docId: widget.house.accommodationId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customCard1(
                      colorr: blue900,
                      isPadding: paddingg,
                      widgett: Column(
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'R${plan.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /*Future<List<String>> getListingImages(String accommodationId) async {
    final imageBox = await Hive.openBox('listingImages');
    final cachedImages = imageBox.get(accommodationId)?.cast<String>();

    if (cachedImages != null && cachedImages.isNotEmpty) {
//      //       print('Using cached images');
      return cachedImages;
    }

//    // print('Fetching images from Firestore');
    // Fallback to Firestore if cache is empty
    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .doc(accommodationId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .get();

    final urls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();

    // Cache result
    await imageBox.put(accommodationId, urls);

    return urls;
  }*/

  Future<void> _deleteImage(String imageUrl) async {
    try {
      // Show loading indicator during deletion
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: blue900),
        ),
      );

      // First remove from UI immediately for better UX
      setState(() {
        _imageUrls.remove(imageUrl);
      });

      // Then handle backend cleanup
      await _performImageDeletion(imageUrl);

      // Close loading dialog
      Navigator.of(context).pop();

      CustomSnackbar.show(context, 'Image deleted successfully.');
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Revert UI changes on error
      await _loadImages(); // Reload to restore state

      CustomSnackbar.show(context, 'Failed to delete image.');
    }
  }

// Separate method for the actual deletion logic
  Future<void> _performImageDeletion(String imageUrl) async {
    // Delete from Firebase Storage
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();

    // Also delete from Firestore collection if it exists
    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.house.accommodationId)
        .collection('images')
        .where('imageUrl', isEqualTo: imageUrl)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Remove from Hive cache
    final imageBox = await Hive.openBox('listingImages');
    final cached = imageBox.get(widget.house.accommodationId)?.cast<String>() ?? [];
    cached.remove(imageUrl);
    await imageBox.put(widget.house.accommodationId, cached);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final SizedBox ten = SizedBox(height: SizeConfig.screenHeight * 0.010);
    final SizedBox width10 = SizedBox(width: SizeConfig.screenWidth * 0.010);

    bool isExpired =
        widget.house.paymentExpiryDate?.isBefore(DateTime.now()) ?? false;

    final imageUpload = Provider.of<ImageUploadMethod>(context, listen: false);
    final stream = Listing().currentUserListing(widget.house.accommodationId);
    final styll = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: grey100,
      body:   StreamBuilder(
          stream: stream,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(color: blue900,),
              );
            }

        final houseData = snapshot.data!;

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        // Main background image container
                        Container(
                          height: SizeConfig.screenHeight* 0.3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Fallback color
                          ),
                          child: houseData.pictureUrl.startsWith('http')
                              ? CachedNetworkImage(
                            imageUrl: houseData.pictureUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: blue900,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.home_rounded,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          )
                              : Image.asset(
                            houseData.pictureUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                                  Icons.home_rounded,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                          ),
                        ),

                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: _buildEditButton(
                            icon: CupertinoIcons.photo_camera_solid,
                            onPressed: () async {
                              await imageUpload.updateAccomPicture(
                                context,
                                houseData,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: paddingg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ten,
                          Row(
                            children: [
                              widget.house.isVerified ?
                              Icon(Icons.verified_user_rounded,
                                color: Colors.blue.shade900,
                              ) : Column(),

                              width10,

                              Text(
                                houseData.accommodationName,
                                style: styll.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          /*Text(
                            houseData.address,
                            style: styll.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),*/

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.red,
                              ),

                              width10,

                              Text(
                                houseData.location,
                                style: styll.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              width10,

                              Text(
                                houseData.address,
                                style: styll.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /*houseData.isFull

                                  ? Text(
                                '(Fully Occupied)',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : SizedBox(),*/
                            ],
                          ),

                          ten,

                          isExpired
                              ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _paymentsDialog();
                            },
                            child: Text(
                              'Renew',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              : SizedBox(),

                          SizedBox(height: SizeConfig.screenHeight * 0.010),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customElevated(
                                nextPage: EditAccom(listing: houseData),
                                LabelText: 'Edit Listing',
                              ),
                              widget.house.isVerified ? Column() :
                                  widget.house.verificationStatus == 'waiting' ?
                                      Text('Awaiting') :
                              customElevated(
                                color: Colors.green,
                                nextPage: GetVerified(house: widget.house),
                                LabelText: 'Get Verified',
                              ),
                          ],)

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ten,
              ten,
              ExpandableTextCard(
                title: 'Description',
                text: houseData.aboutAccom,
                trimLength: 100,
                controller: _scrollController,
              ),
              ten,
              ExpandableTextCard(
                title: 'Payments',
                text: houseData.aboutPayment,
                trimLength: 60,
                controller: _scrollController,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            // Simulate upload

                            await imageUpload.uploadImages(context, houseData);

                            // Reload images after upload
                            _loadImages();
                          },
                          child: const Text(
                            'Upload',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                         
                         Divider(height: SizeConfig.screenHeight *  0.018),

                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_imageUrls.isEmpty)
                          const Center(child: Text("No images found."))
                        else
                          GridView.builder(
                            key: ValueKey(_imageUrls.length), // Add this key
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              childAspectRatio: 1,
                            ),
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              final image = _imageUrls[index];

                              return GestureDetector(
                                key: ValueKey(image), // Add unique key for each itemm
                                onTap: () {
                                  // Show image in full screen
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  _showDeleteConfirmation(image); // Extract to separate method
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey[200],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.error),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      })
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: blue900),
        onPressed: onPressed,
      ),
    );
  }


  void _showDeleteConfirmation(String image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Image',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this image?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: blue900,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog first
              _deleteImage(image); // Then delete
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
