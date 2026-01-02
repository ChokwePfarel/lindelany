import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lindelany/Constants/Constants.dart';
import 'package:lindelany/constants/scale.dart';
import 'package:lindelany/methods_Funtions/ImageUpload.dart';
import 'dart:io';

import '../../classes/verifications/listing_verification.dart';
import '../../static/snackbar.dart';

class GetVerified extends StatefulWidget {
  final dynamic house;

  const GetVerified({super.key, required this.house});

  @override
  State<GetVerified> createState() => _GetVerifiedState();
}

class _GetVerifiedState extends State<GetVerified> {
  final CollectionReference _reference =
  FirebaseFirestore.instance.collection('awaitVerification');
  final CollectionReference _listingReference = FirebaseFirestore.instance.collection('Accommodation');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _pickedFile;
  bool _isLoading = false;
  bool _isClosed = false;


 /* Future<void> _pickImage() async {
    try {

      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress image
      );

      if (picked != null) {
        setState(() => _pickedFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        _showError('Error picking image: $e');
      }
    }
  }

  Future<void> _createDocument() async {
    // Validation
    if (_pickedFile == null) {
      _showError('Please select a proof image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create document and get ID
      final docRef = _reference.doc();
      _requestId = docRef.id;

      // Set initial data
      await docRef.set({
        'accommodationId': widget.house.accommodationId,
        'userId': widget.house.userId,
        'userEmail': _auth.currentUser?.email ?? '',
        'accommodationName': widget.house.accommodationName,
        'address': widget.house.address,
        'city': widget.house.city,
        'postalCode': widget.house.postalCode,
        'submittedAt': FieldValue.serverTimestamp(),
        'proofImage': '', // Placeholder
      });

      await _listingReference.doc(widget.house.accommodationId).update({
        'verificationStatus': 'waiting'
      });

      // Upload image
      if (_pickedFile != null) {
        final imageUrl = await _uploadImage(_requestId, _pickedFile!);

        // Update document with image URL
        await _updateRequest(_requestId, imageUrl);

        if (mounted) {
          _showSuccess('Verification request submitted successfully!');
          Navigator.of(context).pop(); // Close screen
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to submit verification: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadImage(String requestId, File imageFile) async {
    try {

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('proofs/${widget.house.userId}_proof.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> _updateRequest(String requestId, String imageUrl) async {
    await _reference.doc(requestId).update({
      'proofImage': imageUrl,
    });
  }

  void _removeImage() {
    setState(() => _pickedFile = null);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }*/


  final VerificationService _verificationService = VerificationService();

  Future<void> _pickImage() async {
    final file = await ImageUploadMethod.pickFromGallery();

    if (file == null) {
      AppSnackbar.showError(context, 'Image selection cancelled');
      return;
    }

    setState(() => _pickedFile = file);
  }

  Future<void> _submit() async {
    if (_pickedFile == null) {
      AppSnackbar.showError(context, 'Please select a proof image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _verificationService.submitVerification(
        accommodationId: widget.house.accommodationId,
        accommodationName: widget.house.accommodationName,
        address: widget.house.address,
        city: widget.house.city,
        postalCode: widget.house.postalCode,
        userId: widget.house.userId,
        proofImage: _pickedFile!,
      );

      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Verification request submitted successfully',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Submission failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() => _pickedFile = null);
  }

  void _close() {
    setState(() => _isClosed = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    if (_isClosed) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accommodation Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.012),

                    Text('Name: ${widget.house.accommodationName}'),
                    Text('Address: ${widget.house.address}'),
                    Text('City: ${widget.house.city}'),
                    Text('Postal Code: ${widget.house.postalCode}'),
                  ],
                ),
              ),
            ),

           SizedBox(height: screenHeight *0.020),

            // Instructions
            Card(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: screenWidth * 0.08),
                        const Text(
                          'Verification Requirements',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight *0.08),

                    const Text(
                      'Please upload proof of ownership (e.g., title deed, lease agreement, utility bill)'
                      'Your document is used only for ownership verification and will be deleted after approval.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight *0.020),

            // Image Picker
            if (_pickedFile == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: screenHeight *0.0200,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                      SizedBox(height: screenHeight *0.08),
                      const Text('Tap to upload proof of ownership'),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _pickedFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: _removeImage,
                    ),
                  ),
                ],
              ),

           SizedBox(height: screenHeight *0.030),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: blue900,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? SizedBox(
                height: screenHeight *0.020,
                width: screenWidth *0.020,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Submit for Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
