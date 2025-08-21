import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindelany/firebase_Set/setStudent.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../static/snackbar.dart';
import '../methods/upload.dart';
import '../userInteface/my_broadcast.dart';

class CreateBroadcast extends StatefulWidget {
  final UserModel user;
  final String studentUni;

  const CreateBroadcast({super.key, required this.user, required this.studentUni});

  @override
  State<CreateBroadcast> createState() => _CreateBroadcastState();
}

class _CreateBroadcastState extends State<CreateBroadcast> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'broadcasts',
  );

  String _message = '';
  bool isCompleted = false;
  final Timestamp _createdAt = Timestamp.now();
  List<XFile> _pickedFiles = [];
  late final String postId;

  @override
  void initState() {
    super.initState();
    postId = _reference.doc().id;
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];

    for (final XFile xf in _pickedFiles) {
      try {
        // Original picked image
        final originalFile = File(xf.path);

        // Crop to 1:1 + compress (downscale to 1080px max side; adjust as needed)
        final croppedFile = await cropToSquareJpeg(
          originalFile,
          maxSide: 1080, // or null to keep original resolution
          quality: 85,
        );

        // Use timestamp for uniqueness; you already have postId available
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload cropped file
        final ref = FirebaseStorage.instance.ref().child(
          'posts/$postId/$fileName',
        );
        final task = await ref.putFile(croppedFile);

        // Get download URL
        final url = await task.ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        // Log & continue uploading rest (or break if you prefer)
        print('Image upload failed (${xf.path}): $e');
      }
    }

    return imageUrls;
  }

  Future<void> _createPost() async {
    try {
      final imageUrls = await _uploadImages();

      await _reference.doc(postId).set({
        'postId': postId,
        'userId': widget.user.userId,
        'userName': widget.user.userName,
        'message': _message,
        'imageUrls': imageUrls,
        'institution': widget.studentUni ?? southAfricanUniversities.first,
        'createdAt': _createdAt,
        'completed': isCompleted,
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => myBroadcasts()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Failed to create post: $e');
      CustomSnackbar.show(context, 'Failed to create post.');
    }
  }

  void _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        _pickedFiles = picked.take(4).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('All broadcasts should pertain to the need for transport.'),
              const Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: blue900),
                onPressed: () async {
                  final isConnected = await checkNetworkAndShowSnackbar(
                    context,
                  );
                  if (!isConnected) return;

                  Navigator.of(context).pop(); // close dialog
                  CustomDialog.showLoading(context, 'Creating...');
                  await _createPost();
                },
                child: const Text(
                  'Publish',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;

    String userUni = context.read<StudentProvider>().currentUser!.uni;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.2),

                if (_pickedFiles.isEmpty)
                  const Text(
                    'No images uploaded yet.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pickedFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(file.path),
                              width: 100,
                              height: 100,
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
                    }).toList(),
                  ),

                SizedBox(height: screenHeight * 0.020),

                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Type your broadcast here...',
                  ),
                  onChanged: (value) => _message = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide information';
                    }
                    return null;
                  },
                  maxLines: null,
                  minLines: 1,
                ),

                SizedBox(height: screenHeight * 0.020),

                DropdownButtonFormField(
                  isExpanded: true,
                  value: southAfricanUniversities.contains(userUni)
                      ? userUni
                      : southAfricanUniversities.first,

                  items: southAfricanUniversities.map((String uni) {
                    return DropdownMenuItem(
                      value: uni,
                      child: Text(
                        uni,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => userUni = value!),
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.010),

                TextButton.icon(
                  onPressed: _pickImages,
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

                Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    shape: StadiumBorder(),
                    backgroundColor: blue900,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showConfirmationDialog();
                      }
                    },
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
