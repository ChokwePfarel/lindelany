import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lindelany/static/image_caurosel.dart';
import 'package:provider/provider.dart';
import '../../Constants/constants.dart';
import '../../Providers/chatProvider.dart';
import '../../classes/user_model.dart';
import '../../constants/scale.dart';
import '../../custom_made/widgets/colums.dart';
import '../../static/snackbar.dart';
import '../broadcast_vehicle_model.dart';
import '../from_firebase/transport.dart';

class CustomCardBroadcast extends StatefulWidget {
  final BroadcastModel broadcast;
  final UserModel user;

  const CustomCardBroadcast({
    super.key,
    required this.broadcast,
    required this.user,
  });

  @override
  State<CustomCardBroadcast> createState() => _CustomCardBroadcastState();
}

class _CustomCardBroadcastState extends State<CustomCardBroadcast> {
  @override
  void initState() {
    super.initState();
    // FIXED: Use addPostFrameCallback instead of Future.microtask
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CreateTransport>(context, listen: false).FetchVehicleProfile();
      }
    });
  }

  String formartedTimeOrDate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    return (difference.inHours < 24)
        ? DateFormat('hh:mm a').format(time)
        : DateFormat('dd MMM yyyy').format(time);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final createdAt = formartedTimeOrDate(widget.broadcast.createdAt.toDate());

    // FIXED: Use Consumer to safely handle null state
    return Consumer<CreateTransport>(
      builder: (context, transport, child) {
        final vehicleProfile = transport.vehicleProfile;
        // Show loading state while data is being fetched
        final isExpired = vehicleProfile?.paymentExpiryDate.isBefore(DateTime.now()) ?? false;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customCard1(
                  colorr: grey100,
                  isPadding: EdgeInsets.zero,
                  widgett: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.broadcast.images.isNotEmpty
                          ? SharedWidgets.buildImageCarousel(
                        widget.broadcast.images,
                        screenHeight,
                        screenWidth,
                      )
                          : const SizedBox(),

                      SizedBox(height: screenHeight * 0.010),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.broadcast.uni,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Broadcast text
                Text(widget.broadcast.broadcast),

                SizedBox(height: screenHeight * 0.010),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(createdAt),

                    // FIXED: Handle null state in the IconButton
                    vehicleProfile == null
                        ? const SizedBox(
                      width: 48, // Same width as IconButton for consistent layout
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                        : IconButton(
                      onPressed: () async {
//                        debugPrint('Expired Status: $isExpired');
//                        debugPrint('Date: ${vehicleProfile.paymentExpiryDate}');
//                        //debugPrint('User ID: ${FirebaseAuth.instance.currentUser!.uid}');

                        if (isExpired) {
                          CustomSnackbar.show(context, 'Renew your subscription');
                        } else {
                          Provider.of<chatProvider>(
                            context,
                            listen: false,
                          ).navigateToChat(context, widget.user);
                        }
                      },
                      icon: Icon(
                        CupertinoIcons.reply_thick_solid,
                        color: blue900,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
/**/
