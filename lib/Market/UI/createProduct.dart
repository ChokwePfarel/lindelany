import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindelany/Market/UI/myProducts.dart';
import 'package:lindelany/Market/firebaseService/productSet.dart';
import 'package:lindelany/Market/customMad/lists.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/firebase_Set/user.dart';
import 'package:lindelany/payments/webview.dart';
import 'package:lindelany/user_interface/Common/accommodations.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../Constants/lists.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../custom_made/widgets/info_card.dart';
import '../../custom_made/widgets/rounded_inputFields.dart';
import '../../methods_functions/ImageUpload.dart';
import '../../methods_functions/check_netwok.dart';
import '../../payments/plans.dart';
import '../../static/snackbar.dart';
import '../methods/upload.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateproductState();
}

class _CreateproductState extends State<CreateProduct> {
  final FirebaseFirestore _reference = FirebaseFirestore.instance;
  final ProductSet _service = ProductSet();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  late String _productId;
  String sellerId = '';
  String productName = '';
  int price = 0;
  String description = '';
  String category = titlesC.first;
  bool isNew = false;
  String _selectedUni = southAfricanUniversities.first;
  String sellerName = '';
  String status = 'inactive';
  List<XFile> _pickedFiles = [];

  bool _isLoading = false;
  bool _isPickingImages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setUserInfo());
  }

  //--------------------------Set UserInfo--------------------------------------

  void _setUserInfo() {
    final user = context.read<UserProvider>().user!;

    sellerName = user.userName ?? '';
    sellerId = user.userId ?? '';
  }

  //-------------------------------Create Doc-----------------------------------

  Future<void> _create() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    bool isConnected = await checkNetworkAndShowSnackbar(context);
    if (!isConnected) {
      setState(() => _isLoading = false);
      return;
    }

    // Track the id so we can roll back (delete) a half-finished product if
    // image upload fails partway through - we never want a product left
    // behind without its images.
    String productId = '';

    try {
      productId = await _service.createProduct(
        sellerId: sellerId,
        sellerName: sellerName,
        productName: productName,
        price: price,
        description: description,
        status: status,
        sellerUni: _selectedUni.trim(),
        isNew: isNew,
        category: category.trim(),
        images: const [],
      );

      if (productId.isEmpty) {
        throw Exception('Product creation failed');
      }

      if (_pickedFiles.isNotEmpty) {
        final imageUrls = await ImageUploadService.uploadImages(
          pickedFiles: _pickedFiles,
          folder: 'products',
          docId: productId,
        );

        // uploadImages now throws on any individual failure, but this is a
        // belt-and-braces check in case that ever changes.
        if (imageUrls.length != _pickedFiles.length) {
          throw Exception('Some images failed to upload');
        }

        await _service.updateProductImages(
          productId: productId,
          images: imageUrls,
        );
      }

      if (mounted) {
        setState(() {
          _productId = productId;
        });
      }
    } catch (e) {
      // Roll back: don't leave a product live without its images.
      if (productId.isNotEmpty) {
        await ImageUploadService().deleteImages(
          folder: 'products',
          docId: productId,
        );
      }
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to upload images - please try again',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //---------------------------------------Pick images----------------------------

  Future<void> _pickImages() async {
    setState(() => _isPickingImages = true);

    try {
/*
      final hasPermission = await ImageUploadMethod().requestPhotoPermission();

      if(!hasPermission){
        return;
      }*/

      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() => _pickedFiles = picked.take(2).toList());
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, 'Error picking images');
        //
      }
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  //------------------------------Remove images-----------------------------------

  void _removeImage(int index) {
    if (index >= 0 && index < _pickedFiles.length) {
      setState(() => _pickedFiles.removeAt(index));
    }
  }

  //---------------------------------------Close pop up-------------------------

  bool _isClosed = false;

  void _close() {
    setState(() => _isClosed = true);
  }

  //-------------------------------------Payment flow---------------------------

  Future<void> _updateHasFreeTrial() async {
    await _reference.collection('Users').doc(sellerId).update({
      'isFreeTrial': false,
    });
  }

  //--------------------------Check has free trial------------------------------

  bool hasFreeTrial = false;

  Future<bool> _getHasFreeTrial() async {
    final doc = await _reference.collection('Users').doc(sellerId).get();

    setState(() {
      hasFreeTrial = doc.data()!['isFreeTrial'];
    });
//    //     print('current user has free trial ?? $hasFreeTrial');

    return hasFreeTrial;
  }

  //---------------------------Handle is free trial-----------------------------

  Future<void> _paymentDialog() async {
    final plan = productPlan;
    await showDialog<bool>(
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

          content: GestureDetector(
            onTap: () async {

              await analytics.logEvent(name: 'selling',parameters: {
                'price': plan.price
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YocoWebView(
                    plan: plan,
                    collection: 'products',
                    docId: _productId,
                  ),
                ),
              );
            },
            child: customCard1(
              colorr: blue900,
              widgett: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'R10',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.004),

                  Text(
                    'Unlimited Period',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //--------------------------Create Partial------------------------------------

  Future<void> _createPartialProduct(bool hasFreeTrial) async {
    CustomDialog.showLoading(context, 'Saving,please wait...');


    if (hasFreeTrial) {
      status = 'active';
      await _updateHasFreeTrial(); // This creates the document and sets _listingId.
    } else {
      status = 'inactive';
    }

    await _create(); // Creates accommodation doc

    if (mounted) Navigator.of(context).pop(); // Dismiss loading dialog
  }

  //---------------------------------------Build UI-----------------------------

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final theme = Theme.of(context).textTheme;

    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, results){
          if (!didPop) {
            // custom back logic
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Accomodations()),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 30, 8, 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isClosed
                        ? Container()
                        : customCard1(
                      colorr: blue900,
                      widgett: InfoCard(
                        title: "Create Product",
                        bodyText: "Sell your first product on us. "
                            "Note that this product will only be accessed by students within the target market. "
                            "This product will remain until you manually delete it.",
                        onClose: () {
                          // Example: hide the widget, navigate back, or setState
                          _close();
                        },
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    Text(
                      'Upload',
                      style: theme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    _isPickingImages
                        ? SizedBox(
                      height: screenHeight * 0.10,
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                        : _pickedFiles.isEmpty
                        ? const Text(
                      'No images uploaded yet.',
                      style: TextStyle(color: Colors.grey),
                    )
                        : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_pickedFiles.length, (index) {
                        final file = _pickedFiles[index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(file.path),
                                width:
                                screenHeight *
                                    0.10, // 10% of screen height
                                height: screenHeight * 0.10,
                                fit: BoxFit.cover,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: screenHeight * 0.040),
                    TextButton.icon(
                      onPressed: _isPickingImages ? null : _pickImages,
                      icon: Icon(
                        Icons.add_photo_alternate,
                        color: blue900,
                        size: 25,
                      ),
                      label: Text(
                        'Upload Images',
                        style: TextStyle(color: blue900, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.020),
                    Text(
                      'Product Form',
                      style: theme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    InputField(
                      label: 'Product Name',
                      validationNote: 'Name required',
                      initialValue: productName.trim(),
                      onChanged: (val) => productName = val,
                    ),

                    SizedBox(height: screenHeight * 0.020),

                    InputField(
                      label: 'About product',
                      validationNote: 'Description required',
                      initialValue: description.trim(),
                      onChanged: (val) => description = val,
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    InputField(
                      label: 'Price',
                      validationNote: 'Price cannot be empty',
                      initialValue: price == 0 ? '' : price.toString(),
                      onChanged: (val) => price = int.tryParse(val) ?? 0,
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    CustomDropdown<String>(
                      labelText: 'Category',
                      items: titlesC,
                      value: titlesC.contains(category) ? category : titlesC.first,
                      onChanged: (value) {
                        setState(() {
                          category = value!;
                        });
                      },
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    CustomDropdown<String>(
                      labelText: 'Target Market',
                      items: southAfricanUniversities,
                      value: southAfricanUniversities.contains(_selectedUni)
                          ? _selectedUni
                          : southAfricanUniversities.first,
                      onChanged: (value) {
                        setState(() {
                          _selectedUni = value!;
                        });
                      },
                    ),

                    SizedBox(height: screenHeight * 0.010),

                    Container(
                      decoration: border10,
                      child: SwitchListTile(
                        title: const Text(
                          "Is this product New ?",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Toggle on for New and off for Used(off by default)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        value: isNew,
                        onChanged: (bool value) => setState(() => isNew = value),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.020),

                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: (_isLoading || _isPickingImages)
                            ? null
                            : () async {
                          if (_pickedFiles.isEmpty) {
                            return CustomSnackbar.show(
                              context,
                              'Upload at least one image',
                            );
                          } else {
                            if (_formKey.currentState?.validate() ?? false) {
                              final results = await _getHasFreeTrial();

                              await _createPartialProduct(results);

                              if (!mounted) return;

                              if (_productId.isEmpty) {
                                CustomSnackbar.show(
                                  context,
                                  'Failed to initialize listing.',
                                );
                                return;
                              }

                              if (results){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MyProducts()),
                                );

                              } else{
                                await _paymentDialog();
                              }
                            }
                          }
                        },
                        child:  Text(
                          'Sell',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}