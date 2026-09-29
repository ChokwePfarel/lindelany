import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Market/UI/myProducts.dart';
import 'package:lindelany/Market/firebaseService/productModel.dart';
import 'package:lindelany/Market/firebaseService/productSet.dart';
import 'package:lindelany/Market/methods/upload.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/static/snackbar.dart';

import '../../Constants/constants.dart';
import '../../Constants/lists.dart';
import '../../custom_made/for_press/confirm_dialog.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../custom_made/widgets/rounded_inputFields.dart';
import '../../methods_functions/check_netwok.dart';
import '../customMad/lists.dart';

class EditProduct extends StatefulWidget {
  final ProductModel product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();

  bool _hasChanges = false;

  late int price;
  late bool isNew;
  late String _selectedUni;
  late String category;

  @override
  void initState() {
    super.initState();

    price = widget.product.price;
    isNew = widget.product.isNew;
    _selectedUni = widget.product.sellerUni;
    category = widget.product.category;
  }

  void _saveProduct() async {
    //  Ensure dialog is closed if this function is called from the dialog.
    if (ModalRoute.of(context)?.isCurrent == false) {
      Navigator.pop(context); // Close the AlertDialog first
    }

    await ProductSet().updateProfile(
      widget.product.productId,
      price,
      isNew,
      _selectedUni,
      category,
    );

    if (mounted) {
      //Use pushReplacement to remove EditProduct from the stack.
      // This makes the back button from MyProducts lead to Accomodations.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyProducts()),
      );

      CustomSnackbar.show(context, 'Saved');
    }
  }

  //-------------------------Delete-----------------------------------------------

  void _deleteProduct() async {
    if (ModalRoute.of(context)?.isCurrent == false) {
      Navigator.pop(context);
    }

    await ImageUploadService().deleteImages(
      folder: 'products',
      docId: widget.product.productId,
    );
  }

  void _markAsDirty() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final screenHeight = SizeConfig.screenHeight;

    final theme = Theme.of(context).textTheme;
    final bStyle = theme.bodyLarge!.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final List<String> images = widget.product.images;

    return PopScope(
      // CRITICAL FIX: canPop is controlled by the _hasChanges flag.
      // If NO changes, canPop is true, and the user goes back to MyProducts normally.
      // If changes EXIST, canPop is false, and we handle the blocked pop in the callback.
      canPop: !_hasChanges,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Pop succeeded (because _hasChanges was false)
        if (!mounted) return;

        // --- Pop was blocked (changes exist) ---

        // 1. Show the confirmation dialog
        final action = await showUnsavedChangesDialog(
          context: context,
          onSave: () => _saveProduct(),
          titleStyle: theme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
          buttonStyle: theme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        );

        // 2. Act based on the user's choice from the dialog
        if (!mounted) return;

        if (action == 'DISCARD') {
          // User chose to discard -> Manually pop the current screen (goes to MyProducts)
          Navigator.of(context).pop();
        } else if (action == 'SAVE') {
          // User chose to save -> Call the save function which uses pushReplacement
          _saveProduct();
        }
        // If action is 'CANCEL' or null, the dialog closes, and the user remains on the EditProduct screen.
      },

      //BASICALLY: In short, you are telling the system: "Don't let this screen pop,
      // but when the user tries to pop it, just replace it with this other screen instead."
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: blue900,
          actions: [
            TextButton(
              onPressed: () async {
                final bool isConnected = await checkNetworkAndShowSnackbar(
                  context,
                );
                if (isConnected) {
                  if (_formKey.currentState!.validate() ?? false) {
                    _saveProduct();
                  }
                } else {
                  return CustomSnackbar.show(context, 'No network connection');
                }
              },
              child: Text(
                'SAVE',
                style: theme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uploads', style: bStyle),

                  SizedBox(height: screenHeight * 0.020),

                  //Images
                  Row(
                    children: images.map((image) {
                      return SizedBox(
                        height: 100,
                        width: 100,
                        child: CachedNetworkImage(imageUrl: image),
                      );
                    }).toList(),
                  ),

                  //Name
                  Text('Product Name', style: bStyle),

                  SizedBox(height: screenHeight * 0.010),

                  Text(
                    widget.product.productName,
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.040),

                  //Description
                  Text('Description', style: bStyle),

                  SizedBox(height: screenHeight * 0.010),

                  Text(
                    widget.product.description,
                    style: theme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.030),

                  Text('Edit', style: bStyle),

                  SizedBox(height: screenHeight * 0.010),

                  InputField(
                    label: 'Price',
                    validationNote: 'Price Required',
                    initialValue: widget.product.price.toString(),
                    onChanged: (val){
                      setState(() {
                        price = int.tryParse(val) ?? 0;
                        _markAsDirty();
                      });
                    },
                  ),

                  /*TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    initialValue: widget.product.price.toString(),

                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter Price(eg. 250)';
                      }
                      if (int.tryParse(val) == null) {
                        //Insures a valid string
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        price = int.tryParse(val) ?? 0;
                        _markAsDirty();
                      });
                    },
                  ),*/

                  SizedBox(height: screenHeight * 0.020),

                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    isExpanded: true,
                    //
                    initialValue: titlesC.contains(category)
                        ? category
                        : titlesC.first,
                    items: titlesC.map((String uni) {
                      return DropdownMenuItem(
                        value: uni,
                        child: Text(uni, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      category = value!;
                      _markAsDirty();
                    }),
                  ),

                  SizedBox(height: screenHeight * 0.020),

                  //University
                  CustomDropdown<String>(
                    labelText: 'Institution',
                    items: southAfricanUniversities,
                    value: southAfricanUniversities.contains(
                      widget.product.sellerUni,
                    )
                        ? widget.product.sellerUni
                        : southAfricanUniversities.first,
                    onChanged: (value) {
                      setState(() {
                        _selectedUni = value!;
                        _markAsDirty();
                      });
                    },
                  ),

                  SizedBox(height: screenHeight * 0.010),

                  //New/Old
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
                      onChanged: (bool value) => setState(() {
                        isNew = value;
                        _markAsDirty();
                      }),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.020),

                  SizedBox(
                    width: SizeConfig.screenWidth * 1,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                'Delete Product',
                                style: theme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this product? This action can not be undone',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'No',
                                    style: theme.bodyMedium!.copyWith(
                                      color: blue900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => Center(
                                        child: CircularProgressIndicator(
                                          color: blue900,
                                        ),
                                      ),
                                    );
                                    _deleteProduct();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Yes',
                                    style: theme.bodyMedium!.copyWith(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                      ),
                      child: Text(
                        'Delete',
                        style: theme.bodyMedium!.copyWith(
                          color: Colors.white,
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
    );
  }
}
