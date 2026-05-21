import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/show_venue_location.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

/// Venues list for availability cards — shown in the body (after notes), not the header.
class AvailabilityVenuesSection extends StatelessWidget {
  final VendorAvailabilityModel block;
  final double topSpacing;

  const AvailabilityVenuesSection({
    super.key,
    required this.block,
    this.topSpacing = 12,
  });

  List<ShowVenueLocation> get _venues {
    if (block.showVenues.isNotEmpty) return block.showVenues;
    if (block.location != null) {
      final loc = block.location!;
      final locationLine = ShowVenueLocation.buildLocationLine(
        city: loc.city,
        state: loc.state,
        country: loc.country ?? '',
      );
      if (locationLine.isNotEmpty) {
        return [ShowVenueLocation(name: loc.city, location: locationLine)];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final venues = _venues;
    if (venues.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: venues.map(_venueRow).toList(),
      ),
    );
  }

  Widget _venueRow(ShowVenueLocation venue) {
    final subtitle = venue.displaySubtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  venue.displayLabel,
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  CommonText(
                    subtitle,
                    fontSize: AppTextSizes.size12,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
