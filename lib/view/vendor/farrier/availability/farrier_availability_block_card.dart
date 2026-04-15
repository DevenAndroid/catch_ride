import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FarrierAvailabilityBlockCard extends StatelessWidget {
  final VendorAvailabilityModel block;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FarrierAvailabilityBlockCard({
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
        color: const Color(0xFFFFF1F1), // Very light pinkish background for the whole card area (based on screenshot)
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B4444), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF631515).withOpacity(0.06),
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
            color: const Color(0xFF8B4444), 
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
                              fontSize: AppTextSizes.size12,
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
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    offset: const Offset(0, 40),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      else if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_calendar_outlined, color: Color(0xFF1570EF), size: 20),
                            const SizedBox(width: 12),
                            const CommonText('Edit', fontSize: 15, fontWeight: FontWeight.w500),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, color: Color(0xFFD92D20), size: 20),
                            const SizedBox(width: 12),
                            CommonText('Delete', fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFFD92D20)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (block.timeBlockType != null) _buildChip(block.timeBlockType!),
                    if (block.availabilityMode != null) _buildChip(block.availabilityMode!),
                    if (block.locationType != null) _buildChip(block.locationType!),
                    ...block.serviceTypes.map((type) => _buildChip(type)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/horse_icon.svg", height: 16,),
                    const SizedBox(width: 8),
                    CommonText('Min ${block.maxBookings} Horses', fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF475467)),
                    const SizedBox(width: 24),
                    const Icon(Icons.access_time, size: 20, color: Color(0xFF475467)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CommonText(
                        block.newClientPolicy ?? 'Accepting new clients', 
                        fontSize: 15, 
                        fontWeight: FontWeight.w600, 
                        color: const Color(0xFF475467),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                if (block.notes != null && block.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: const Icon(LucideIcons.messageSquareMore, size: 18, color: Color(0xFF475467)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(
                          block.notes!,
                          fontSize: 15,
                          color: const Color(0xFF475467),
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

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CommonText(
        label, 
        fontSize: 14,
        fontWeight: FontWeight.w600, 
        color: const Color(0xFF475467),
      ),
    );
  }
}
