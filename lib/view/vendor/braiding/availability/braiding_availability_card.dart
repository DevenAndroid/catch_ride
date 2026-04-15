import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../constant/app_text_sizes.dart';

class BraidingAvailabilityCard extends StatelessWidget {
  final VendorAvailabilityModel availability;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BraidingAvailabilityCard({
    super.key,
    required this.availability,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightPink, // Light pinkish background from design
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.secondary, // Maroon/Brown from design
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          availability.dateDisplay,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CommonText(
                                availability.locationDisplay,
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: CommonText('Edit', fontSize: 14)),
                        const PopupMenuItem(value: 'delete', child: CommonText('Delete', fontSize: 14, color: Colors.red)),
                      ],
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          iconPath: "assets/icons/horse_icon.svg",
                          Icons.catching_pokemon, // Placeholder for horse icon
                          'Max ${availability.maxBookings} Horses',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.calendar_today_outlined,
                          'Max ${availability.maxDays} Days',
                        ),
                      ),
                    ],
                  ),
                  if (availability.notes != null && availability.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      LucideIcons.messageSquareMore,
                      availability.notes!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text,{String? iconPath}) {
    return Row(
      children: [
        iconPath != null
            ? SvgPicture.asset(iconPath, )
            :
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Icon(icon, size: 18, color: const Color(0xFF535862)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            text,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,

          ),
        ),
      ],
    );
  }
}
