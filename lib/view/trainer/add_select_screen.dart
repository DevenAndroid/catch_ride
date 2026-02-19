import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/list/add_horse_screen.dart';
import 'package:catch_ride/view/trainer/book_service/vendor_search_screen.dart';
import 'package:catch_ride/view/trainer/barn_manager/invite_barn_manager_screen.dart';

class AddSelectScreen extends StatelessWidget {
  const AddSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Create New', style: AppTextStyles.headlineMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildActionCard(
            icon: Icons.inventory_2_outlined,
            title: 'List a Horse',
            subtitle: 'Add a new horse for sale, lease, or trial',
            onTap: () {
              Get.back();
              Get.to(() => const AddHorseScreen());
            },
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            icon: Icons.calendar_today_outlined,
            title: 'Book a Service',
            subtitle: 'Find and request vendor services',
            onTap: () {
              Get.back();
              Get.to(() => const VendorSearchScreen());
            },
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Invite Barn Manager',
            subtitle: 'Give staff access to manage bookings',
            onTap: () {
              Get.back();
              Get.to(() => const InviteBarnManagerScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.deepNavy, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}
