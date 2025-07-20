import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Constants/Constants.dart';
import '../../Constants/Lists.dart';
import '../../constants/scale.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/check_netwok.dart';
import '../../static/snackbar.dart';
import '../userInteface/my_broadcast.dart';

class CreateBroadcast extends StatefulWidget {
  final UserModel user;

  const CreateBroadcast({super.key, required this.user});

  @override
  State<CreateBroadcast> createState() => _CreateBroadcastState();
}

class _CreateBroadcastState extends State<CreateBroadcast> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference _reference = FirebaseFirestore.instance.collection('broadcasts');

  String _message = '';
  String _selectedUni = southAfricanUniversities.first;
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
    List<String> imageUrls = [];
    try {
      for (XFile file in _pickedFiles) {
        final uploadFile = File(file.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('posts/$postId/$fileName');
        final task = await ref.putFile(uploadFile);
        final url = await task.ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      print('Image upload failed: $e');
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
        'institution': _selectedUni,
        'createdAt': _createdAt,
        'completed': isCompleted,
      });


    } catch (e) {
      print('Failed to create post: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create broadcast')));
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
              Text('All broadcasts should pertain to the need for goods transport.'),
              const Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: blue900),
                onPressed: () async {
                  final isConnected = await checkNetworkAndShowSnackbar(context);
                  if (!isConnected) return;

                  CustomDialog.showLoading(context, 'Creating...');


                  await _createPost();

                  if (mounted) Navigator.of(context).pop(); // close loading
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) =>  myBroadcasts()),
                          (route) => false,
                    );
                  }
                },
                child: const Text('Publish', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                SizedBox(height: SizeConfig.screenHeight *0.2,),
            
                if (_pickedFiles.isEmpty)
                  const Text('No images uploaded yet.', style: TextStyle(color: Colors.grey))
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
                              child: const Icon(Icons.close, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
            
                SizedBox(height: SizeConfig.screenHeight*0.020),
            
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
            
                 SizedBox(height: SizeConfig.screenHeight *0.020),
            
                DropdownButtonFormField(
                  isExpanded: true,
                  value: southAfricanUniversities.contains(_selectedUni)
                      ? _selectedUni
                      : southAfricanUniversities.first,

                  items: southAfricanUniversities.map((String uni) {
                    return DropdownMenuItem(
                      value: uni,
                      child: Text(uni, overflow: TextOverflow.ellipsis, maxLines: 1),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedUni = value!),
                ),
            
                SizedBox(height: SizeConfig.screenHeight * 0.010),
            
            
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.add_photo_alternate,color: blue900,size: 25,),
                  label: Text('Upload Images',style: TextStyle(color: blue900,fontSize: 16),),
                ),
            
            
                SizedBox(height: SizeConfig.screenHeight * 0.020),
            
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
                    child: const Icon(Icons.send,color: Colors.white,),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


