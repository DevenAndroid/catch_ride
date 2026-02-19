import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controller/invite_barn_manager_controller.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class InviteBarnManagerScreen extends StatelessWidget {
  const InviteBarnManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InviteBarnManagerController());

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Barn Manager')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.deepNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Barn Managers can help you manage bookings and availability. They cannot create or delete horse listings.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Contact Information', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Email Address',
              hint: 'manager@example.com',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number (Optional)',
              hint: '(555) 123-4567',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),
            Text('Access Permissions', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),

            _buildPermissionSwitch(
              controller.canManageAvailability,
              'Manage Horse Availability',
              'Update calendar blocks and location for existing horses.',
            ),

            const SizedBox(height: 16),

            _buildPermissionSwitch(
              controller.canBookServices,
              'Request Vendor Bookings',
              'Book services like grooming and farrier on your behalf.',
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Send Invitation',
              onPressed: controller.sendInvite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch(RxBool value, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Switch(
            value: value.value,
            onChanged: (val) => value.value = val,
            activeColor: AppColors.mutedGold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
