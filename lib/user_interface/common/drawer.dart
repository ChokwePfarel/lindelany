import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Market/UI/category.dart';
import 'package:lindelany/Market/UI/createProduct.dart';
import 'package:lindelany/Market/UI/myProducts.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../constants/scale.dart';
import '../../create_edit/student/create_student.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/ImageUpload.dart';
import '../../transport_broadcast/userInteface/my_broadcast.dart';
import '../../custom_made/for_press/aListTile.dart';
import '../landlord/show_atCenter.dart';

class customDrawe extends StatefulWidget {
  const customDrawe({super.key});

  @override
  State<customDrawe> createState() => _customDraweState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _customDraweState extends State<customDrawe> {

  UserModel currentUser = UserModel(
    userId: '',
    userName: 'No internet',
    userType: 'connection',
    userGender: '',
    profilePictureUrl: '',
    isFreeTrial: true,
  );

  void exampleUsage() async {
//    //     print('Attempting to get App Check token...');
    // Call the static method

    try {
      final token = await FirebaseAppCheck.instance.getToken();
//      //       print('App Check token obtained successfully: ${token?.substring(0, 20)}...');
    } catch (e) {
//      //       print('App Check token error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;
    final theme = Theme.of(context).textTheme;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,

        child: Consumer<UserProvider>(
          builder: (context, UserProvider, child) {
            final currentUser = UserProvider.user;
            if (currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                top: 25,
                bottom: 8.0,
                right: 8.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildUserHeader(currentUser, widthTen),
                        SizedBox(height: SizeConfig.screenHeight * 0.040),
                        getDrawerTile(currentUser.userType, hightTen),
                
                      ],
                    ),
                
                
                
                    SizedBox(height: SizeConfig.screenHeight * 0.4),
                
                
                    Column(
                      children: [
                        drawerTile(
                          text: 'Sell',
                          lead: Icon(Icons.sell_rounded, color: blue900,
                            size: MediaQuery.of(context).size.height*0.04,),
                          navigate: CreateProduct(),
                        ),
                
                        SizedBox(height: SizeConfig.screenHeight*0.010),
                
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Market()),
                            );
                          },
                          child: customCardForTextInput(
                            someWidget: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 40,
                                  color: blue900,
                                ),
                
                                SizedBox(width: widthTen),
                
                                Text(
                                  'MarketPlace',
                                  style: theme.bodyLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ); //
  }

  Widget _buildUserHeader(UserModel userData, widthh) {
    return customCardForTextInput(
      someWidget: Row(
        children: [
          GestureDetector(
            onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShowAtCenter(imagesUrl: userData.profilePictureUrl),
                  ),
                );
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.08,
              backgroundImage: userData.profilePictureUrl.startsWith('http')
                  ? CachedNetworkImageProvider(userData.profilePictureUrl)
                  : AssetImage(userData.profilePictureUrl) as ImageProvider,
            ),
          ),

          SizedBox(width: widthh),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.userName ?? "Student",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData.userType,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.camera_fill, color: Colors.white),
            onPressed: () async {
              await Provider.of<ImageUploadMethod>(
                context,
                listen: false,
              ).updateProfilePicture(context, userData);
            },
          ),
        ],
      ),
    );
  }

  Widget getDrawerTile(String userType, double height) {
    return Column(
      children: [
        drawerTile(
          text: 'Profile',
          lead: Icon(CupertinoIcons.person_alt, color: blue900),
          navigate: CreateStudentProfile(),
        ),

        SizedBox(height: SizeConfig.screenHeight*0.010),

        drawerTile(
          text: 'My broadcast',
          lead: Icon(CupertinoIcons.waveform_circle_fill, color: blue900),
          navigate: myBroadcasts(),
        ),

        SizedBox(height: SizeConfig.screenHeight*0.010),

        drawerTile(
          text: 'My Products',
          lead: Icon(CupertinoIcons.archivebox_fill, color: blue900),
          navigate: MyProducts(),
        ),
      ],
    );
  }
}
