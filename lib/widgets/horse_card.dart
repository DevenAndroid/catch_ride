import 'package:cached_network_image/cached_network_image.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:flutter/material.dart';

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
    final show = horse.showAvailability.isNotEmpty
        ? horse.showAvailability.first
        : null;
    final String discipline = horse.displayDiscipline;
    final String venue = (show?.showVenue == null || show!.showVenue!.isEmpty)
        ? 'N/A'
        : show.showVenue!;
    final String datesStr = DateUtil.formatRange(
      show?.startDate,
      show?.endDate,
    );
    final String dates = (datesStr.isEmpty || datesStr.trim() == '-')
        ? 'N/A'
        : datesStr;
    final String location = (horse.location == null || horse.location!.isEmpty)
        ? 'N/A'
        : horse.location!;

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
              child: CachedNetworkImage(
                imageUrl: horse.photo ?? AppConstants.dummyImageUrl,
                width: 100,
                // height: 100,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                            children: [
                              TextSpan(
                                text: horse.name.isEmpty ? 'N/A' : horse.name,
                              ),
                              TextSpan(
                                text: ' - $discipline',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Venue
                  CommonText(
                    'Venue — $venue',
                    fontSize: 14,
                    color: const Color(0xFF667085),
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: const Color(0xFF667085),
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
                  // Dates
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
                                    right: entry.key ==
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
