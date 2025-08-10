import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:lindelany/firebase_Set/user.dart';
import 'package:lindelany/methods_Funtions/ImageUpload.dart';
import 'package:lindelany/payments/plans.dart';
import 'package:lindelany/payments/yoco.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:lindelany/user_interface/landlord/myAccommodations.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
import '../../create_edit/landlord/edit_accommodation.dart';
import '../../custom_made/for_press/customElevated.dart';
import '../../custom_made/widgets/colums.dart';
import '../../methods_Funtions/expand.dart';
import '../../payments/webview.dart';
import 'show_atCenter.dart';

class detailedListing extends StatefulWidget {
  final Listing_model house;

  const detailedListing({super.key, required this.house});

  @override
  State<detailedListing> createState() => _detailedListingState();
}

class _detailedListingState extends State<detailedListing> {
  final ScrollController _scrollController = ScrollController();

  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'Accommodation',
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUser(),
    );

  }

  Future<void> _renew(String token, SubscriptionPlan plan) async {
    final isSuccess = await YocoPaymentService.chargeCardToken(token, plan);

    if (isSuccess) {
      final expiaryDate = YocoPaymentService.getExpiryDate(plan.durationMonths);

      await _reference.doc(widget.house.accommodationId).update({
        'plan': plan.name,
        'amount': plan.price,
        'paymentId': token,
        'paymentExpiryDate': Timestamp.fromDate(expiaryDate),
      });
      if (mounted){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MyListing(),
          ), (route) => false,  );
        return CustomSnackbar.show(
          context,
          'Successfully renewed',
        );
      }
    } else {
      return CustomSnackbar.show(context, 'Failed,please try again later');
    }
  }

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YocoWebView(
                          amountInCents: (plan.price * 100).toInt(),
                          publicKey: 'pk_test_ed3c54a6gOol69qa7f45',
                          onSuccess: (token) => _renew(token, plan),
                          onError: (error) {
                            CustomSnackbar.show(
                              context,
                              'Payment error: $error',
                            );
                          },
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

  Future<List<String>> getListingImages(String accommodationId) async {
    final imageBox = await Hive.openBox('listingImages');
    final cachedImages = imageBox.get(accommodationId)?.cast<String>();

    if (cachedImages != null && cachedImages.isNotEmpty) {
      print('Using cached images in not null or empty');
      return cachedImages;
    }

    print('Fetching images from Firestore, cached is null or empty');
    // Fallback to Firestore if cache is empty
    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.house.accommodationId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .get();

    final urls = snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();

    // Cache result
    await imageBox.put(accommodationId, urls);

    return urls;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final SizedBox ten = SizedBox(height: SizeConfig.screenHeight * 0.010);
    final SizedBox width10 = SizedBox(width: SizeConfig.screenWidth * 0.010);

    bool isExpired =
        widget.house.paymentExpiryDate?.isBefore(DateTime.now()) ?? false;

    final stream = FirebaseFirestore.instance
        .collection('listings')
        .doc(widget.house.accommodationId)
        .collection('images')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    final imageUpload = Provider.of<ImageUploadMethod>(context, listen: false);
    final styll = Theme.of(context).textTheme;
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: grey100,
      body: SingleChildScrollView(
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
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Fallback color
                        ),
                        child: widget.house.pictureUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.house.pictureUrl,
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
                                widget.house.pictureUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.home_rounded,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                              ),
                      ),

                      // Edit profile picture button (top-right)
                      Positioned(
                        top: 160,
                        left: 90,
                        child: IconButton(
                          icon: Icon(Icons.edit_rounded, color: blue900),
                          onPressed: () async {
                            await Provider.of<ImageUploadMethod>(
                              context,
                              listen: false,
                            ).updateProfilePicture(context, user!);
                          },
                        ),
                      ),

                      // Profile picture avatar (bottom-left)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildProfileAvatar(user!),
                      ),

                      // Edit accommodation picture button (bottom-right)
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: _buildEditButton(
                          icon: CupertinoIcons.photo_camera_solid,
                          onPressed: () async {
                            await imageUpload.updateAccomPicture(
                              context,
                              widget.house,
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
                        SizedBox(height: 10,),
                        Text(
                          widget.house.accommodationName,
                          style: styll.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                            ),
                            width10,
                            Text(
                              widget.house.location,
                              style: styll.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            widget.house.isFull
                                ? Text(
                                    '(Hidden)',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : SizedBox(),
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

                        SizedBox(height: SizeConfig.screenHeight *0.030,),

                        customElevated(
                          nextPage: EditAccom(listing: widget.house),
                          LabelText: 'Edit Listing',
                        ),
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
              text: widget.house.aboutAccom,
              trimLength: 100,
              controller: _scrollController,
            ),
            ten,
            ExpandableTextCard(
              title: 'Payments',
              text: widget.house.aboutPayment,
              trimLength: 60,
              controller: _scrollController,
            ),
            Padding(
              padding: paddingg,
              child: Container(
                width: double.infinity,
                decoration: border10White,
                child: Padding(
                  padding: paddingg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await imageUpload.uploadImages(context, widget.house);
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
                      divider,

                      FutureBuilder(
                        future: getListingImages(widget.house.accommodationId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (snapshot.hasData) {
                            final imageUrls = snapshot.data as List<String>;

                            if (imageUrls.isEmpty) {
                              return const Center(
                                child: Text("No images found."),
                              );
                            }

                            return SizedBox(
                              height: SizeConfig.screenHeight * 0.70,
                              width: double.infinity,
                              child: GridView.builder(
                                key: const PageStorageKey('grid'),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  final image = imageUrls[index];

                                  return GestureDetector(
                                    onTap: () async {
                                      final imageProvider = NetworkImage(image);
                                      await precacheImage(
                                        imageProvider,
                                        context,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              showAtCenter(imagesUrl: image),
                                        ),
                                      );
                                    },
                                    onLongPress: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text("Delete Image"),
                                          content: const Text(
                                            "Are you sure you want to delete this image?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          // Attempt to delete from Firebase Storage
                                          final ref = FirebaseStorage.instance
                                              .refFromURL(image);
                                          await ref.delete();

                                          // Remove from Hive
                                          final imageBox = await Hive.openBox(
                                            'listingImages',
                                          );
                                          final cached =
                                              imageBox
                                                  .get(
                                                    widget
                                                        .house
                                                        .accommodationId,
                                                  )
                                                  ?.cast<String>() ??
                                              [];
                                          cached.remove(image);
                                          await imageBox.put(
                                            widget.house.accommodationId,
                                            cached,
                                          );
                                          // Rebuild widget
                                          (context as Element).markNeedsBuild();

                                          CustomSnackbar.show(
                                            context,
                                            'Image deleted successfully.',
                                          );
                                        } catch (e) {
                                          CustomSnackbar.show(
                                            context,
                                            'Failed to delete image.',
                                          );
                                        }
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          key: ValueKey(image),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.network(
                                            image,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  );
                                                },
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const Center(child: Text("No images found."));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildProfileAvatar(UserModel user) {
    return GestureDetector(
      onTap: () async {
        try {
          final imageProvider = user.profilePictureUrl.startsWith('http')
              ? NetworkImage(user.profilePictureUrl)
              : AssetImage(user.profilePictureUrl) as ImageProvider;

          await precacheImage(imageProvider, context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  showAtCenter(imagesUrl: user.profilePictureUrl),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load image')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          child: user.profilePictureUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: user.profilePictureUrl,
                  imageBuilder: (context, imageProvider) =>
                      CircleAvatar(radius: 58, backgroundImage: imageProvider),
                  placeholder: (context, url) =>
                      CircularProgressIndicator(color: blue900),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                )
              : CircleAvatar(
                  radius: 58,
                  backgroundImage: AssetImage(user.profilePictureUrl),
                ),
        ),
      ),
    );
  }
}
