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
import '../../utility/utility_class.dart';
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

  _checkDoc() async {
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
    SizeConfig.init(context);
    double hightTen = SizeConfig.heightUnit;
    double widthTen = SizeConfig.widthUnit;
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final theme = Theme
        .of(context)
        .textTheme;

    final createdAt = formartedTimeOrDate(widget.broadcast.createdAt.toDate());

    return customCard1(
      colorr: blue900,
      widgett: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customCard1(
            isPadding: EdgeInsets.zero,
            colorr: Colors.white,
            widgett: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.broadcast.images.isNotEmpty
                    ? SharedWidgets.buildImageCarousel(widget.broadcast.images, screenHeight,screenWidth)
                    : const SizedBox(),

                SizedBox(height: hightTen),

                // Broadcast university name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.broadcast.uni,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Broadcast message
          Padding(
            padding: paddingg,
            child: Text(
              widget.broadcast.broadcast,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: hightTen),

          // Row with createdAt text and reply icon
          Padding(
            padding: paddingg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  createdAt,
                  style: theme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}