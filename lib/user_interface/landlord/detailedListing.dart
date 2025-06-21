import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart';
import '../../constants/scale.dart';
import '../../create_edit/landlord/edit_accommodation.dart';
import '../../custom_made/for_press/customElevated.dart';
import '../../methods_Funtions/ImageUpload.dart';
import '../../methods_Funtions/expand.dart';
import '../Common/Accommodations.dart';
import '../Common/chats.dart';
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
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;
    final hightTen = SizeConfig.heightUnit;
    final widthTen = SizeConfig.widthUnit;
    final SizedBox ten = SizedBox(height: hightTen);
    final SizedBox width10 = SizedBox(width: widthTen);

    final stream = _reference
        .doc(widget.house.accommodationId)
        .collection('uploads')
        .orderBy('uploadedAt', descending: true)
        .snapshots();

    final imageUpload = Provider.of<ImageUploadMethod>(context, listen: false);
    final styll = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: grey100,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ten,
            Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              widget.house.pictureUrl.startsWith('http')
                              ? CachedNetworkImageProvider(
                                  widget.house.pictureUrl,
                                )
                              : AssetImage(widget.house.pictureUrl),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => showAtCenter(
                                imagesUrl: widget.house.pictureUrl,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: IconButton(
                          onPressed: () async {
                            await imageUpload.updateAccomPicture(
                              context,
                              widget.house,
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.photo_camera_solid,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ten,

                  Padding(
                    padding: paddingg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.house.accommodationName, style: styll),
                        ten,
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                            ),
                            width10,
                            Text(widget.house.location, style: styll),
                          ],
                        ),
                        ten,
                        Row(
                          children: [
                            customElevated(
                              nextPage: EditAccom(listing: widget.house),
                              LabelText: 'Edit Listing',
                              widthh: 150,
                            ),
                            width10,
                            const sizedElevatedIcon(
                              nextPag: AllChats(),
                              Widthh: 60,
                              iicon: CupertinoIcons.chat_bubble_fill,
                            ),
                            width10,
                            const sizedElevatedIcon(
                              nextPag: Accomodations(),
                              Widthh: 60,
                              iicon: CupertinoIcons.house_fill,
                            ),
                            boxx2,
                          ],
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

                      StreamBuilder(
                        stream: stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final imageUrls = snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>? ?? {};
                              return data['imageUrl'] as String? ?? '';
                            }).toList();

                            return SizedBox(
                              height: screenHeight * 0.70,
                              width: double.infinity,
                              child: GridView.builder(
                                key: const PageStorageKey('grid'),
                                // preserves scroll state
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs[index];
                                    final data = doc.data() as Map<String, dynamic>? ?? {};
                                    final image = data['imageUrl'] as String? ?? '';
                                    final storagePath = data['path'] as String? ?? '';

                                    if (image.isEmpty) return const SizedBox.shrink();

                                    return GestureDetector(
                                      onTap: () async {
                                        final imageProvider = NetworkImage(image);
                                        await precacheImage(imageProvider, context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => showAtCenter(imagesUrl: image),
                                          ),
                                        );
                                      },
                                      onLongPress: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Delete Image"),
                                            content: const Text("Are you sure you want to delete this image?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await FirebaseStorage.instance.ref(storagePath).delete();
                                            await doc.reference.delete();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Image deleted")),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Error deleting image: $e")),
                                            );
                                          }
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            key: ValueKey(image),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.network(
                                              image,
                                              fit: BoxFit.cover,
                                              gaplessPlayback: true,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Icon(Icons.delete, color: Colors.white.withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

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

  _showDialog(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //CLOSE THE IMAGE WHEN TAPPED
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Stack(
                  children: [
                    Image.network(image, fit: BoxFit.contain),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),

              //CLOSE THE DIALOG AND GO TO A FULL SCREEN
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => showAtCenter(imagesUrl: image),
                    ),
                  );
                },
                child: Text(
                  'FULL SCREEN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: blue900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
