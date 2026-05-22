import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/explore_controller.dart';
import 'common_image_view.dart';

class HorseCard extends StatelessWidget {
  final HorseModel horse;
  final VoidCallback onTap;
  final bool isRequested;
  final Widget? trailing;

  const HorseCard({
    super.key,
    required this.horse,
    required this.onTap,
    this.isRequested = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    var barnName = horse.trainerBarnName ?? "";
    String dates = "";
    String  location = (horse.location == null || horse.location!.isEmpty) ? 'N/A' : horse.location!;
    final ExploreController controller = Get.put(ExploreController());

    final availabilityRows = horse.displayAvailability;

    if (controller.locationType.value == "Show Venue") {
      final searchedVenue = controller.showVenue.value.trim().toLowerCase();

      if (searchedVenue.isNotEmpty && availabilityRows.isNotEmpty) {
        final show = availabilityRows.firstWhereOrNull(
          (s) => s.showVenue.trim().toLowerCase().contains(searchedVenue),
        );

        if (show != null) {
          final String datesStr = DateUtil.formatRange(
            show.startDate,
            show.endDate,
          );
          dates = (datesStr.isEmpty || datesStr.trim() == '-')
              ? 'N/A'
              : datesStr;
          barnName = show.showVenue;
          location = show.cityState;
        }
      }
    } else {
      final String searchedLocation =
          controller.location.value.trim().toLowerCase();

      if (searchedLocation.isNotEmpty && availabilityRows.isNotEmpty) {
        final show = availabilityRows.first;

        final String datesStr = DateUtil.formatRange(
          show.startDate,
          show.endDate,
        );
        dates = (datesStr.isEmpty || datesStr.trim() == '-')
            ? 'N/A'
            : datesStr;
        barnName = show.showVenue;
        location = show.cityState;
      }
    }



    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CommonImageView(
                url: horse.images.isNotEmpty ? horse.images[0] : horse.photo,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                            children: [
                              TextSpan(text: horse.listingTitle ?? horse.name),
                              // TextSpan(
                              //   text: ' - $discipline',
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.w400,
                              //     color: Color(0xFF667085),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Venue
                  if (barnName != '') ...[
                    CommonText(
                      barnName,
                      fontSize: 14,
                      color: const Color(0xFF667085),
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Location
                  if (location != 'N/A') ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: const Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: CommonText(
                            location,
                            fontSize: 14,
                            color: const Color(0xFF667085),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  if (dates != null && dates != '') ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: const Color(0xFF667085),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: CommonText(
                            dates,
                            fontSize: 14,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else
                    const SizedBox(height: 6),
                  // Tags/Badges
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (isRequested)
                          _buildTag(
                            'Requested',
                            const Color(0xFFF9F5FF),
                            const Color(0xFF7F56D9),
                          )
                        else
                          ...horse.listingTypes
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        entry.key ==
                                            horse.listingTypes.length - 1
                                        ? 0
                                        : 8,
                                  ),
                                  child: _buildTag(
                                    entry.value,
                                    const Color(0xFF713B34),
                                    Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: CommonText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
