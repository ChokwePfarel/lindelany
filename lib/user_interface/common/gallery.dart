import 'package:flutter/material.dart';

import '../../Constants/Constants.dart';
import '../../classes/listing_model.dart';
import '../../methods_Funtions/get_listing_images.dart';
import '../landlord/show_atCenter.dart';

class Gallery extends StatefulWidget {
  final Listing_model house;

  const Gallery({super.key, required this.house});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading ? Center(child: CircularProgressIndicator(color: blue900,),)
      : _imageUrls.isEmpty ? Center(
        child: Text('No Images',style: TextStyle(
            color: blue900,
            fontWeight: FontWeight.bold,
            fontSize: 20
        ),),
      )
      :
      Column(
        children: [
          const SizedBox(height: 40),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {

                final imageUrl = _imageUrls[index];

                return
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShowAtCenter(imagesUrl: imageUrl),
                        ),
                      );
                    },
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Center(
                          child: CircularProgressIndicator(color: blue900,strokeWidth: 2,),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, color: Colors.blueAccent),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
