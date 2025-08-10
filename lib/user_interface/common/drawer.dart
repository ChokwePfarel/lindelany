import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/transport_broadcast/create/create_vehicle.dart';
import 'package:lindelany/transport_broadcast/userInteface/car_profile.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
import '../../constants/scale.dart';
import '../../create_edit/student/Create_student.dart';
import '../../custom_made/widgets/colums.dart';
import '../../firebase_Set/user.dart';
import '../../classes/user_model.dart';
import '../../methods_Funtions/ImageUpload.dart';
import '../../methods_Funtions/Navigation.dart';
import '../../static/snackbar.dart';
import '../../transport_broadcast/userInteface/my_broadcast.dart';
import '../../custom_made/for_press/aListTile.dart';
import '../landlord/show_atCenter.dart';
import 'chats.dart';

class customDrawe extends StatefulWidget {
  const customDrawe({
    super.key,
  });

  @override
  State<customDrawe> createState() => _customDraweState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _customDraweState extends State<customDrawe> {

  bool exist = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserProvider>(context, listen: false).fetchUser());
    _checkDoc();
  }

  UserModel currentUser = UserModel(userId: '',
      userName: 'No internet',
      userType: 'connection',
      userGender: '',
      profilePictureUrl: '',
      isFreeTrial: true);


  Future<void> _checkDoc() async {
    final bool found = await CustomNavigation().getDocumentBool('Vehicle');

    setState(() {
      exist = found;
    });
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;

    return SafeArea(
      child: Drawer(
          backgroundColor: Colors.white,
          child:
          Consumer<UserProvider>(builder: (context, UserProvider, child) {
            final currentUser = UserProvider.user;
            if (currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 10, bottom: 8.0, right: 8.0),
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildUserHeader(currentUser, widthTen),
                          SizedBox(height: SizeConfig.screenHeight * 0.040,),
                          getDrawerTile(currentUser.userType, exist, hightTen)

                        ],
                      ),
                    ),
                    Column(
                      children: [
                        customCard1(
                          colorr: Colors.grey,
                          widgett: ListTile(
                            leading: Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                            ),
                            title: Text(
                              'LOG OUT',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            onTap: () {
                              LoggingOut.showLogout(context);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                )
            );
          })
      ),
    ); //
  }

  Widget _buildUserHeader(UserModel userData, widthh) {
    return customCardForTextInput(
      someWidget: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final imageProvider = NetworkImage(userData.profilePictureUrl);

              // Preload image before navigation
              await precacheImage(imageProvider, context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          showAtCenter(imagesUrl: userData.profilePictureUrl)));
            },
            child: CircleAvatar(
              radius: MediaQuery
                  .of(context)
                  .size
                  .width * 0.08,
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
                Text(userData.userName ?? "Student",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(userData.userType,
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.photo, color: Colors.white),
            onPressed: () async {
              await Provider.of<ImageUploadMethod>(context, listen: false)
                  .updateProfilePicture(context, userData);
            },
          ),
        ],
      ),
    );
  }

  Widget getDrawerTile(String userType, bool exist, double height) {
    final user = userType.toLowerCase();
    print('USER TYPE : $userType');
    final userId = _auth.currentUser?.uid;
    print(userId);

    switch (user) {
      case 'student':
        return Column(
          children: [
            drawerTile(
              text: 'Profile',
              lead: Icon(CupertinoIcons.person_alt, color: blue900),
              navigate: CreateStudentProfile(),
            ),

            SizedBox(height: height,),

            drawerTile(
                text: 'My broadcast',
                lead: Icon(
                  CupertinoIcons.waveform_circle_fill,
                  color: blue900,
                ),
                navigate: myBroadcasts()),
          ],
        );

      case 'transportation':
        return Column(
          children: [
            exist
                ? drawerTile(
              text: 'Profile',
              lead: Icon(CupertinoIcons.house_fill, color: blue900),
              navigate: CarProfile(),
            )
                : drawerTile(
              text: 'Create Profile',
              lead: Icon(CupertinoIcons.doc, color: blue900),
              navigate: Vehicle(),
            ),

            SizedBox(height: height),
            drawerTile(
                text: 'Chats',
                lead: Icon(
                  CupertinoIcons.chat_bubble_fill,
                  color: blue900,
                ),
                navigate: AllChats()),

          ],
        );

      default:
        return SizedBox.shrink(); // Prevents null from being returned
    }
  }
}
