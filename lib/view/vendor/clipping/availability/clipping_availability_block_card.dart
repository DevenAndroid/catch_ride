import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF631515).withOpacity(0.04),
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
            color: const Color(0xFF915C56),
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
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CommonText(
                              block.locationDisplay.toUpperCase(),
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                _buildIconRow(Icons.catching_pokemon, 'Max ${block.maxBookings} Horses'),
                const SizedBox(height: 14),
                _buildIconRow(Icons.access_time_filled, block.timeBlockType ?? 'Available'),
                if (block.notes != null && block.notes!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildIconRow(Icons.chat_bubble_outline, block.notes!, isNotes: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, {bool isNotes = false}) {
    return Row(
      crossAxisAlignment: isNotes ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isNotes ? 2 : 0),
          child: Icon(
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
