import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Color baseColor = Colors.grey.shade300;
    Color highlightColor = Colors.grey.shade100;

    Widget shimmerBox({
      double? height,
      double? width,
      BorderRadius? borderRadius,
      ShapeBorder? shape,
    }) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: height,
          width: width,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: shape ??
                RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            /// TOP BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shimmerBox(
                  height: 35,
                  width: 35,
                  borderRadius: BorderRadius.circular(8),
                ),
                shimmerBox(
                  height: 45,
                  width: 140,
                  borderRadius: BorderRadius.circular(10),
                ),
                shimmerBox(
                  height: 40,
                  width: 40,
                  shape: const CircleBorder(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// GREETING
            shimmerBox(height: 35, width: 180),
            const SizedBox(height: 12),
            shimmerBox(height: 22, width: 220),
            const SizedBox(height: 8),
            shimmerBox(height: 22, width: 170),

            const SizedBox(height: 40),

            /// SEARCH BAR
            shimmerBox(
              height: 65,
              width: MediaQuery.of(context).size.width,
              borderRadius: BorderRadius.circular(40),
            ),

            const SizedBox(height: 25),

            /// FILTER BUTTONS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  4,
                      (index) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: shimmerBox(
                      height: 55,
                      width: 115,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            /// LISTING TITLE
            shimmerBox(height: 35, width: 130),

            const SizedBox(height: 25),

            /// LISTINGS
            Column(
              children: List.generate(
                4,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// IMAGE
                        shimmerBox(
                          height: 110,
                          width: 120,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        const SizedBox(width: 14),

                        /// DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: shimmerBox(
                                      height: 24,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  shimmerBox(
                                    height: 24,
                                    width: 24,
                                    shape: const CircleBorder(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              shimmerBox(height: 20, width: 90),
                              const SizedBox(height: 10),
                              shimmerBox(height: 18, width: 140),
                              const SizedBox(height: 8),
                              shimmerBox(height: 18, width: 120),
                              const SizedBox(height: 8),
                              shimmerBox(height: 18, width: 100),
                              const SizedBox(height: 16),

                              Row(
                                children: List.generate(
                                  5,
                                      (index) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: shimmerBox(
                                      height: 20,
                                      width: 20,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
