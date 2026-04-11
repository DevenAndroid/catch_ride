import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

class BodyworkAvailabilityBlockCard extends StatelessWidget {
  final VendorAvailabilityModel block;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BodyworkAvailabilityBlockCard({
    super.key,
    required this.block,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CommonText(
                              block.locationDisplay,
                              color: Colors.white70,
                              fontSize: 12,
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
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    offset: const Offset(0, 40),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: CommonText('Edit', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: CommonText(
                          'Delete',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Time Window Chip
                if (block.timeBlockType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: CommonText(
                      block.timeBlockType?.contains('Window') == true ? block.timeBlockType! : '${block.timeBlockType} Window',
                      fontSize: AppTextSizes.size12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),

                const SizedBox(height: 16),

                // 2. Capacity & Buffer
                Row(
                  children: [
                    const Icon(Icons.pie_chart_outline, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText(
                      'Daily Sessions: ${block.maxBookings}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText(
                      'Buffer Time: ${block.bufferTime ?? '15 min'}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                // 3. Notes
                if (block.notes != null && block.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonText(
                          block.notes!,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
