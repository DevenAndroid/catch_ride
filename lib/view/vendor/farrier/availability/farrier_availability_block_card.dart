import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

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
                        fontSize: AppTextSizes.size18,
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    else if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: CommonText('Edit', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: CommonText('Delete', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
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
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.catching_pokemon, size: 20, color: Color(0xFF475467)),
                    const SizedBox(width: 8),
                    CommonText('Min ${block.maxBookings} Horses', fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF475467)),
                    const SizedBox(width: 24),
                    const Icon(Icons.access_time, size: 20, color: Color(0xFF475467)),
                    const SizedBox(width: 8),
                    CommonText(block.newClientPolicy ?? 'Accepting new clients', fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF475467)),
                  ],
                ),
                if (block.notes != null && block.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF475467)),
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
        fontSize: 15, 
        fontWeight: FontWeight.w600, 
        color: const Color(0xFF475467),
      ),
    );
  }
}
