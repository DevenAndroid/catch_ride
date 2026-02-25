import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/trainer/settings/profile_information_view.dart';
import 'package:catch_ride/view/trainer/settings/saved_view.dart';
import 'package:catch_ride/view/trainer/settings/account_settings_view.dart';
import 'package:catch_ride/view/trainer/settings/notification_settings_view.dart';
import 'package:catch_ride/view/trainer/settings/invite_barn_manager_view.dart';
import 'package:catch_ride/view/trainer/settings/privacy_policy_view.dart';
import 'package:catch_ride/view/trainer/settings/terms_and_conditions_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
          'Settings',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () => Get.to(() => const ProfileInformationView()),
              ),
              _buildSettingsTile(
                icon: Icons.bookmark_outline,
                title: 'Saved',
                onTap: () => Get.to(() => const SavedView()),
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () => Get.to(() => const NotificationSettingsView()),
              ),
              _buildSettingsTile(
                icon: Icons.settings_outlined,
                title: 'Account Settings',
                onTap: () => Get.to(() => const AccountSettingsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Invite'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_add_outlined,
                title: 'Invite Barn Manager',
                onTap: () => Get.to(() => const InviteBarnManagerView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Support'),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Get Help',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.chat_bubble_outline,
                title: 'Feedback',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.article_outlined,
                title: 'Privacy policy',
                onTap: () => Get.to(() => const PrivacyPolicyView()),
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & conditions',
                onTap: () => Get.to(() => const TermsAndConditionsView()),
                showDivider: false,
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: CommonText(
        title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Divider(
                height: 1,
                color: AppColors.border.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 20, color: Color(0xFFD92D20)),
            SizedBox(width: 8),
            CommonText(
              'Logout',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD92D20),
            ),
          ],
        ),
      ),
    );
  }
}
