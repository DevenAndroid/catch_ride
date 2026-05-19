import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/settings_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shown immediately after the first login when the server returns
/// `isFirstLogin: true`.
///
/// [currentPassword] is the password the user typed on the login screen —
/// it is passed silently to the API so the user only has to enter their
/// new password (no "current password" field shown).
///
/// After a successful change [onPasswordChanged] is called so the normal
/// role-based navigation can continue.
class ForceChangePasswordView extends StatefulWidget {
  final VoidCallback onPasswordChanged;

  /// The temporary/current password used at login — forwarded to the API.
  final String currentPassword;

  const ForceChangePasswordView({
    super.key,
    required this.onPasswordChanged,
    required this.currentPassword,
  });

  @override
  State<ForceChangePasswordView> createState() =>
      _ForceChangePasswordViewState();
}

class _ForceChangePasswordViewState extends State<ForceChangePasswordView> {
  late final SettingsController _controller;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // currentPassword comes from the login form — not shown to the user.
    final success = await _controller.changePassword(
      widget.currentPassword,
      _newPasswordController.text,
    );

    if (success) {
      // Clear both persisted flags so this screen is not shown again on reopen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLogin', false);
      await prefs.remove('tempLoginPassword');
      await Future.delayed(const Duration(milliseconds: 1200));
      widget.onPasswordChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // User must change password before proceeding.
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const CommonText(
            'Change Password',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.border.withOpacity(0.5),
              height: 1,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 8),
                    // ── Info banner ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: CommonText(
                              'For your security, please set a new password. It must be at least 6 characters long and include one uppercase letter and one special character.',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── New Password ──────────────────────────────────
                    _buildPasswordField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Password must have at least one uppercase letter';
                        }
                        if (!RegExp(r'[!@#\$&*~?_+\-=/\\|:;()\[\]{}<>,.]').hasMatch(value)) {
                          return 'Password must have at least one special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Confirm Password ──────────────────────────────
                    _buildPasswordField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: '••••••',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(
        () => GestureDetector(
          onTap: _controller.isLoading.value ? null : _submit,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF000B48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const CommonText(
                      'Change Password',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
