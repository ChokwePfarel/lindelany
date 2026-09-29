import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lindelany/Constants/constants.dart';
import 'package:lindelany/static/snackbar.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/scale.dart';
import '../../models/listing_model.dart';
import '../../models/user_model.dart';
import '../../user_interface/common/detailed_accommodation.dart';

class CustomGridView extends StatelessWidget {
  final Listing_model house;
  final UserModel user;

  const CustomGridView({super.key, required this.house, required this.user});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final screenHeight = SizeConfig.screenHeight;
    final screenWidth = SizeConfig.screenWidth;

    final theme = Theme.of(context);
    final amountTheme = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.green.shade800,
    );

    return GestureDetector(
      onTap: () {
        if (house.isFull) {
          CustomSnackbar.show(context, 'Fully Occupied');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnAccommodation(house: house, user: user),
            ),
          );
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    SizedBox(
                      width: SizeConfig.screenHeight * 0.2,
                      height: SizeConfig.screenHeight * 0.150,
                      child: ColorFiltered(
                        colorFilter: house.isFull
                            ? const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              )
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                        child: house.pictureUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: house.pictureUrl,

                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                house.pictureUrl,

                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            house.location.length > 15
                                ? house.location.substring(0, 15)
                                : house.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: screenWidth * 0.010),

              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    house.isNsfas
                        ?

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('NSFAS Accredited', style: amountTheme),
                                  house.isVerified ?
                                  Icon(Icons.verified_user_rounded,color: blue900,) : SizedBox.shrink()
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.004),

                              // Gender
                              Text(
                                house.genders,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                'Sharing(2):R${house.doubleRoomPrice}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.010),
                              Text(
                                'Single:R${house.singleRoomPrice}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _price(context, house.singleRoomPrice),
                              const Text(' | '),
                              _price(context, house.doubleRoomPrice),
                            ],
                          ),

                    SizedBox(width: screenWidth * 0.010),

                    if (house.isWalkable)
                      Text(
                        'walking distance',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                    SizedBox(width: screenWidth * 0.010),

                    /*Text(
                      house.aboutPayment.length > 55
                          ? '${house.aboutPayment.substring(0, 55).trim()}...'
                          : house.aboutPayment.trim(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),*/
                    Wrap(
                      spacing: 4.0, // Space between elements
                      runSpacing: 4.0, // Space between lines
                      children: [
                        if (house.isWifi) _Icon(CupertinoIcons.wifi),
                        if (house.isParking) _Icon(Icons.local_parking_rounded),
                        if (house.laundry)
                          _Icon(Icons.local_laundry_service_rounded),
                        if (house.security)
                          _Icon(CupertinoIcons.lightbulb_fill),
                        if (house.bed) _Icon(CupertinoIcons.bed_double_fill),
                        if (house.tv) _Icon(CupertinoIcons.book_fill),
                        if (house.shower) _Icon(Icons.water_drop_rounded),

                        if (house.kitchen) _Icon(Icons.kitchen),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Icon(IconData iccon) {
    return Icon(iccon, color: blue900, size: 21);
  }

  Widget _price(BuildContext context, price) {
    return Text(
      'R$price',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.green.shade800,
      ),
    );
  }
}
