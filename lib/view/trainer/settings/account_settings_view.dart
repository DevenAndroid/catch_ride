import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/view/trainer/settings/change_password_view.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/settings_controller.dart';

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final SettingsController controller = Get.put(SettingsController());
  final AuthController authController = Get.find<AuthController>();
  bool _is2FAEnabled = false;

  @override
  void initState() {
    super.initState();
    _is2FAEnabled = authController.currentUser.value?.twoFactorEnabled ?? false;
  }

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
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Login & Security',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Login'),
                    _buildSettingsCard([
                      _buildActionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Change Password',
                        actionText: 'Change',
                        actionColor: const Color(0xFF2E90FA),
                        onTap: () => Get.to(() => const ChangePasswordView()),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Social Account'),
                    _buildSettingsCard([
                      _buildActionTile(
                        icon: Icons.g_mobiledata_rounded,
                        title: 'Google',
                        actionText: 'Connect',
                        actionColor: const Color(0xFF17B26A),
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Google connection is coming soon',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.facebook_outlined,
                        title: 'Facebook',
                        actionText: 'Connect',
                        actionColor: const Color(0xFF17B26A),
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Facebook connection is coming soon',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    if (controller.activeSessions.isNotEmpty) ...[
                      _buildSectionHeader('Device History'),
                      _buildSettingsCard(
                        controller.activeSessions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final session = entry.value;
                          return _buildDeviceTile(
                            icon:
                                (session['deviceType']
                                            ?.toString()
                                            .toLowerCase() ==
                                        'ios' ||
                                    session['deviceType']
                                            ?.toString()
                                            .toLowerCase() ==
                                        'android')
                                ? Icons.smartphone_rounded
                                : Icons.laptop_mac_rounded,
                            title: session['deviceName'] ?? 'Unknown Device',
                            subtitle: session['lastUsed'] ?? 'Just now',
                            onLogout: () async {
                              final success = await controller.terminateSession(
                                session['token'] ?? '',
                              );
                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  'Session terminated',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            showDivider:
                                index < controller.activeSessions.length - 1,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    _buildSectionHeader('Security & Account'),
                    _buildSettingsCard([
                      _buildToggleTile(
                        icon: Icons.shield_outlined,
                        title: 'Two-Factor Authentication',
                        value: _is2FAEnabled,
                        onChanged: (val) async {
                          final success = await controller.toggle2FA(val);
                          if (success) {
                            setState(() => _is2FAEnabled = val);
                          }
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete you Account',
                        trailIcon: Icons.arrow_forward_ios_rounded,
                        onTap: () => _showDeleteAccountDialog(context),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: CommonText(
        title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? actionText,
    Color? actionColor,
    IconData? trailIcon,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonText(
                    title,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (actionText != null)
                  TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: CommonText(
                      actionText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: actionColor ?? AppColors.primary,
                    ),
                  ),
                if (trailIcon != null)
                  Icon(trailIcon, size: 16, color: AppColors.textPrimary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ),
      ],
    );
  }

  Widget _buildDeviceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onLogout,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      title,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    CommonText(
                      subtitle,
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onLogout,
                child: const CommonText(
                  'Logout',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD92D20),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ),
      ],
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: CommonText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF17B26A),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFD92D20),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const CommonText(
                'Delete Account',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CommonText(
                'Are you sure you want to delete your account? All your profile information, listings, and photos will be permanently removed. This action cannot be undone.',
                fontSize: 14,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: const CommonText(
                        'Cancel',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final userId = authController.currentUser.value?.id ?? '';
                        if (userId.isEmpty) {
                          Get.snackbar('Error', 'User ID not found');
                          return;
                        }

                        // Close dialog before starting process
                        Get.back();
                        
                        // Show a global loading indicator or use controller state
                        final success = await controller.deleteAccount(userId);
                        
                        if (success) {
                          Get.snackbar(
                            'Account Deleted',
                            'Your account and data have been removed.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          // Small delay to let the toast be seen
                          await Future.delayed(const Duration(seconds: 1));
                          authController.logout();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to delete account. Please contact support.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD92D20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const CommonText(
                        'Delete',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
