import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/custom_made/for_press/customElevated.dart';
import 'package:lindelany/firebase_Set/user.dart';
import 'package:lindelany/transport_broadcast/from_firebase/transport.dart';
import 'package:lindelany/transport_broadcast/userInteface/profile_edit.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../methods_functions/ImageUpload.dart';
import '../../payments/plans.dart';
import '../../payments/webview.dart';
import '../../static/utils.dart';
import '../../user_interface/landlord/show_atCenter.dart';

class CarProfile extends StatefulWidget {
  const CarProfile({super.key});

  @override
  State<CarProfile> createState() => _CarProfileState();
}

class _CarProfileState extends State<CarProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).fetchUser(),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return customCard1(
      colorr: Colors.white,
      widgett: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade900),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _paymentsDialog() {
    showDialog(
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  //await _startPayment();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => YocoWebView(
                        plan: transportPlan,
                        collection: 'Vehicle',
                        docId: _auth.currentUser!.uid,
                      ),
                    ),
                  );
                },
                child: customCard1(
                  colorr: blue900,
                  widgett: Column(
                    children: [
                      Text(
                        transportPlan.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.004),
                      Text(
                        'R${transportPlan.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
    final theme = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: blue900,
      //fontWeight: FontWeight.bold
    );

    final userData = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: CreateTransport().userVehicle(),
        builder: (context, snapshot) {
          if (AsyncUtils.isLoadingOrError(snapshot)) {
            return AsyncUtils.BuildIsloadingOrError(snapshot);
          }

          final vehicleData = snapshot.data!;

          final isExpired = vehicleData.paymentExpiryDate.isBefore(
            DateTime.now(),
          );

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: screenHeight * 0.5,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ShowAtCenter(imagesUrl: userData.profilePictureUrl),
                                    ),
                                  );
                                },
                                child: Text('View Image',style: theme,),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Provider.of<ImageUploadMethod>(
                                    context,
                                    listen: false,
                                  ).updateProfilePicture(context, userData);
                                },
                                child: Text('Edit Image',style: theme,),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: userData.profilePictureUrl.startsWith('http')
                            ? CachedNetworkImageProvider(
                                userData.profilePictureUrl,
                              )
                            : AssetImage(userData.profilePictureUrl)
                                  as ImageProvider<Object>,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              //  Content section - overlaps image slightly
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: screenHeight * 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.010),

                          isExpired
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Expired',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        _paymentsDialog();
                                      },
                                      child: Text(
                                        'Renew',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  userData.userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),

                          SizedBox(height: screenHeight * 0.010),
                          // Vehicle Details
                          _buildDetailCard(
                            context,
                            icon: Icons.directions_car,
                            title: 'Car Name',
                            value: vehicleData.carName,
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          _buildDetailCard(
                            context,
                            icon: Icons.branding_watermark,
                            title: 'Brand',
                            value: vehicleData.brand,
                          ),
                          SizedBox(height: screenHeight * 0.010),
                          _buildDetailCard(
                            context,
                            icon: Icons.confirmation_number,
                            title: 'Number Plate',
                            value: vehicleData.numberPlate,
                          ),
                          SizedBox(height: screenHeight * 0.010),
                          _buildDetailCard(
                            context,
                            icon: Icons.phone,
                            title: 'Contact Number',
                            value: vehicleData.numbers,
                          ),
                          SizedBox(height: screenHeight * 0.030),

                          customElevated(
                            nextPage: EditVehicle(),
                            LabelText: 'Edit Profile',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
