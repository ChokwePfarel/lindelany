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
import '../../methods_Funtions/Navigation.dart';
import '../broadcast_vehicle_model.dart';

class CustomCardBroadcast extends StatefulWidget {
  final BroadcastModel broadcast;
  final UserModel user;

  const CustomCardBroadcast(
      {super.key, required this.broadcast, required this.user});

  @override
  State<CustomCardBroadcast> createState() => _CustomCardBroadcastState();
}

class _CustomCardBroadcastState extends State<CustomCardBroadcast> {

  bool _exist = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkDoc();
  }

  Future<void> _checkDoc() async {
    final bool found = await CustomNavigation().getDocumentBool('Vehicle');

    setState(() {
      _exist = found;
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

    final createdAt = formartedTimeOrDate(widget.broadcast.createdAt.toDate());

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
                    SizeConfig.screenHeight,
                    SizeConfig.screenWidth,
                  )
                      : const SizedBox(),

                  SizedBox(height: SizeConfig.screenHeight*0.010),

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
            Text(
              widget.broadcast.broadcast,

            ),

            SizedBox(height: SizeConfig.screenHeight*0.010),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(createdAt),
                IconButton(
                  onPressed: () async {

                    if (_exist) {
                      Provider.of<chatProvider>(context, listen: false)
                          .navigateToChat(context, widget.user);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Create a profile')),
                      );
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
  }}

/**/