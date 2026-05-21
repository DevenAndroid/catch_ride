import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/vendor/availability_venues_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClippingAvailabilityBlockCard extends StatelessWidget {
  final VendorAvailabilityModel block;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClippingAvailabilityBlockCard({
    super.key,
    required this.block,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPink,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 8, top: 16, bottom: 16),
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        block.dateDisplay,
                        color: Colors.white,
                        fontSize: AppTextSizes.size16,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildIconRow(Icons.catching_pokemon, 'Max ${block.maxBookings} Horses',iconPath:  "assets/icons/horse_icon.svg")),
                    Expanded(child: _buildIconRow(Icons.access_time_filled, block.timeBlockType ?? 'Available')),
                  ],
                ),
                const SizedBox(height: 14),

                if (block.notes != null && block.notes!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildIconRow(Icons.chat_bubble_outline, block.notes!, isNotes: true),
                ],
                AvailabilityVenuesSection(block: block, topSpacing: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, {bool isNotes = false, String? iconPath }) {
    return Row(
      crossAxisAlignment: isNotes ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isNotes ? 2 : 0),
          child: iconPath != null ? SvgPicture.asset(iconPath,) : Icon(
            icon,
            size: 20,
            color: isNotes ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CommonText(
            label,
            fontSize: isNotes ? AppTextSizes.size14 : AppTextSizes.size16,
            fontWeight: isNotes ? FontWeight.w400 : FontWeight.w600,
            color: isNotes ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
