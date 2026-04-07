import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';

class ClippingAvailabilityView extends StatelessWidget {
  const ClippingAvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Availability', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: CommonButton(
                text: '+ Add',
                onPressed: () => Get.to(() => const AddAvailabilityBlockView(), arguments: 2),
                width: 90,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleSection(),
              const SizedBox(height: 24),
              const CommonText('Availability Blocks', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              _buildAvailabilityBlock(
                dates: 'Mar 10 - Mar 18, 2026',
                locations: 'Wellington, WEC Ocala',
                maxHorses: 6,
                isFullDay: true,
                notes: 'Prefer mornings. Experience with warmbloods.',
              ),
              const SizedBox(height: 16),
              _buildAvailabilityBlock(
                dates: 'Mar 10 - Mar 18, 2026',
                locations: 'Wellington, WEC Ocala',
                maxHorses: 6,
                isFullDay: true,
                notes: 'Prefer mornings. Experience with warmbloods.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CommonText('Accepting new requests', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                SizedBox(height: 4),
                CommonText('Trainers can send booking requests', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBlock({
    required String dates,
    required String locations,
    required int maxHorses,
    required bool isFullDay,
    required String notes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF8B4444).withOpacity(0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(dates, color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    Row(
                      children: [
                         const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        CommonText(locations, color: Colors.white70, fontSize: AppTextSizes.size12),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showMenuOptions(),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIconLabel(Icons.catching_pokemon, 'Max $maxHorses Horses'),
                    const SizedBox(width: 16),
                    _buildIconLabel(Icons.access_time, isFullDay ? 'Available Full Day' : 'Available Partial'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(child: CommonText(notes, fontSize: AppTextSizes.size14, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textPrimary),
        const SizedBox(width: 4),
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ],
    );
  }

  void _showMenuOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: const CommonText('Edit', fontSize: 16, color: Colors.blue),
              onTap: () {
                Get.to(() => const AddAvailabilityBlockView(), arguments: 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const CommonText('Delete', fontSize: 16, color: Colors.red),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
