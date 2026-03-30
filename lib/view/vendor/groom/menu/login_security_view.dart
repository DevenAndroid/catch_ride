import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/view/vendor/groom/menu/change_password_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSecurityView extends StatefulWidget {
  const LoginSecurityView({super.key});

  @override
  State<LoginSecurityView> createState() => _LoginSecurityViewState();
}

class _LoginSecurityViewState extends State<LoginSecurityView> {
  bool _isTwoFactorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Login & Security', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Login'),
            _buildActionCard(
              icon: Icons.person_outline,
              title: 'Change Password',
              trailing: const CommonText('Change', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              onTap: () => Get.to(() => const ChangePasswordView()),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Device History'),
            _buildDeviceHistoryCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Security & Account'),
            _buildSettingsCard([
              _buildSettingItem(
                icon: Icons.shield_outlined,
                title: 'Two-Factor Authentication',
                trailing: CupertinoSwitch(
                  value: _isTwoFactorEnabled,
                  activeColor: AppColors.successPrimary,
                  onChanged: (v) => setState(() => _isTwoFactorEnabled = v),
                ),
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: 'Delete you Account',
                showChevron: true,
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: CommonText(title, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required Widget trailing, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: AppColors.textPrimary, size: 24),
        title: CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w500),
        trailing: trailing,
      ),
    );
  }

  Widget _buildDeviceHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildDeviceItem('Iphone 14 Pro', '12 feb 2026 at 00:59'),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildDeviceItem('Macbook Pro', '12 feb 2026 at 00:59'),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String device, String date) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: const Icon(Icons.smartphone_outlined, color: AppColors.textPrimary, size: 24),
      title: CommonText(device, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
      subtitle: CommonText(date, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
      trailing: TextButton(
        onPressed: () {},
        child: const CommonText('Logout', color: AppColors.accentRed, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, Widget? trailing, bool showChevron = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.textPrimary, size: 24),
      title: CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w500),
      trailing: trailing ?? (showChevron ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null),
    );
  }
}
