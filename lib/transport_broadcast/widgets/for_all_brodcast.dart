import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lindelany/static/image_caurosel.dart';
import 'package:provider/provider.dart';
import '../../Constants/Constants.dart';
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
  final bool _exist = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(
      () => Provider.of<CreateTransport>(
        context,
        listen: false,
      ).FetchVehicleProfile(),
    );
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

    final date = Provider.of<CreateTransport>(context, listen: true).vehicleProfile!;
    final isExpired = date.paymentExpiryDate.isBefore(DateTime.now());

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
          //--------------------------------------------------Column
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
                Consumer<CreateTransport>(
                  builder: (context, transport, child) {
                    final date = transport.vehicleProfile;
                    if (date == null) return SizedBox.shrink(); // or a disabled button

                    final isExpired = date.paymentExpiryDate.isBefore(DateTime.now());

                    return IconButton(
                      onPressed: () async {
//                         print('Expired Status: $isExpired');
//                         print('Date: ${date.paymentExpiryDate}');
//                         print('Date: ${FirebaseAuth.instance.currentUser!.uid}');
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
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/**/
