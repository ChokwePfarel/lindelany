
import 'package:flutter/material.dart';
import '../../classes/listing_model.dart';
import '../../classes/user_model.dart';
import '../../user_interface/common/detailedAccommodation.dart';


class CustomGridView extends StatelessWidget {
  final Listing_model house;
  final UserModel user;

  const CustomGridView({
    super.key,
    required this.house,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountTheme = Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.green.shade800);

    return GestureDetector(
      onTap: () {
        if (house.isFull) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not available')),
          );
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
                    Container(
                      width: 140,
                      height: 120,
                      child: ColorFiltered(
                        colorFilter: house.isFull
                            ? const ColorFilter.mode(
                            Colors.grey, BlendMode.saturation)
                            : const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply),
                        child: house.pictureUrl.startsWith('http')
                            ? Image.network(
                          house.pictureUrl,

                          fit: BoxFit.cover,
                        ): Image.asset(
                          house.pictureUrl,

                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            house.location.length > 15 ? house.location.substring(0,15) : house.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NSFAS or Prices
                    house.isNsfas
                        ? Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('NSFAS Accredited',
                            style: amountTheme),
                      ],
                    )
                        : Row(
                      children: [
                        Text(
                          'R${house.singleRoomPrice}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800)
                        ),
                        const Text(' | '),
                        Text(
                          'R${house.doubleRoomPrice}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800
                        ),),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Gender
                    Text(
                      house.genders,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue.shade900,fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    // About Snippet
                    Text(
                      house.aboutAccom.length > 55
                          ? '${house.aboutAccom.substring(0, 55)}...'
                          : house.aboutAccom,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
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
}

