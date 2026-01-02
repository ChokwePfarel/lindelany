import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindelany/firebase_Set/set_student.dart';
import 'package:lindelany/user_interface/common/accommodations.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../Constants/lists.dart';
import '../../Market/methods/upload.dart';
import '../../constants/scale.dart';
import '../../classes/user_model.dart';
import '../../custom_made/widgets/colums.dart';
import '../../custom_made/widgets/custom_dropdown.dart';
import '../../custom_made/widgets/info_card.dart';
import '../../custom_made/widgets/rounded_inputFields.dart';
import '../../methods_Funtions/ImageUpload.dart';
import '../../static/snackbar.dart';

class CreateBroadcast extends StatefulWidget {
  final UserModel user;
  final String studentUni;

  const CreateBroadcast({
    super.key,
    required this.user,
    required this.studentUni,
  });

  @override
  State<CreateBroadcast> createState() => _CreateBroadcastState();
}

class _CreateBroadcastState extends State<CreateBroadcast> {
  final _formKey = GlobalKey<FormState>();

  final CollectionReference _reference = FirebaseFirestore.instance.collection(
    'broadcasts',
  );
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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

  //--------------------------------------create--------------------------------

  Future<void> _createPost() async {
    await analytics.logEvent(name: 'broadcasting');

    try {
      final imageUrls = await ImageUploadService.uploadImages(
        pickedFiles: _pickedFiles,
        folder: 'broadcasts',
        docId: postId,
      );

      await _reference.doc(postId).set({
        'postId': postId,
        'userId': widget.user.userId,
        'userName': widget.user.userName,
        'message': _message,
        'imageUrls': imageUrls,
        'institution': widget.studentUni,
        'createdAt': _createdAt,
        'completed': isCompleted,
      });
    } catch (e) {
      //      //       print('Failed to create post: $e');
      CustomSnackbar.show(context, 'Failed to create post.');
    }
  }

  //---------------------------------------Pick images----------------------------

  void _pickImages() async {
    final hasPermission = await ImageUploadMethod().requestPhotoPermission();

    if (!hasPermission) {
      return;
    }

    final picked = await ImagePicker().pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        _pickedFiles = picked.take(4).toList();
      });
    }
  }

  //------------------------------Remove images-----------------------------------

  void _removeImage(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  bool _isClosed = false;

  void _close() {
    setState(() => _isClosed = true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final theme = Theme.of(context).textTheme;

    String userUni = context.read<StudentProvider>().currentStudentInfo!.uni;

    return SafeArea(
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
                            title: "Create Broadcast",
                            bodyText:
                                "Need transport to help you move your goods ? Create a broadcast "
                                "and keep an eye for any replies from drivers."
                                "All broadcasts should pertain to the need for transport, and should be as detailed as possible.",
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

                  _pickedFiles.isEmpty
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

                  InputField(
                    label: 'Broadcast',
                    validationNote: 'Description required',
                    initialValue: _message.trim(),
                    onChanged: (val) => _message = val,
                  ),

                  SizedBox(height: screenHeight * 0.020),

                  CustomDropdown<String>(
                    labelText: 'Audience',
                    items: southAfricanUniversities,
                    value: southAfricanUniversities.contains(userUni)
                        ? userUni
                        : southAfricanUniversities.first,
                    onChanged: (value) {
                      setState(() {
                        userUni = value!;
                      });
                    },
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          CustomDialog.showLoading(
                            context,
                            'Posting,Please Wait',
                          );
                          await _createPost();
                          Navigator.pop(context);

                          CustomSnackbar.show(context, 'Created');

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Accomodations(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Publish',
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
    );
  }
}
