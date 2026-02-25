import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Account Settings',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: ListTile(
                onTap: () {
                  // TODO: Implement delete account logic or confirmation dialog
                  _showDeleteAccountDialog(context);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE4E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFD92D20),
                    size: 20,
                  ),
                ),
                title: const CommonText(
                  'Delete you Account',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CommonText('Delete Account', fontWeight: FontWeight.bold),
        content: const CommonText(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CommonText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              // Perform deletion
              Navigator.pop(context);
            },
            child: const CommonText('Delete', color: Color(0xFFD92D20)),
          ),
        ],
      ),
    );
  }
}
