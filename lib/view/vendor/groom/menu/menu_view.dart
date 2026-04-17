import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/trainer/settings/notifications_view.dart';

import 'package:catch_ride/view/vendor/groom/menu/past_clients_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/personal_info_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/services_rates_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/upcoming_clients_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/edit_vendor_profile_view.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../constant/app_colors.dart';
import '../../../../constant/app_text_sizes.dart';
import '../../../barn_manager/settings/account_settings_view.dart';
import '../../../barn_manager/settings/feedback_view.dart';
import '../../../barn_manager/settings/get_help_view.dart';
import '../../../barn_manager/settings/notification_settings_view.dart';
import '../../../barn_manager/settings/privacy_policy_view.dart';
import '../../../barn_manager/settings/profile_information_view.dart';
import '../../../barn_manager/settings/terms_and_conditions_view.dart';
import '../../../trainer/settings/account_settings_view.dart';
import '../../../trainer/settings/feedback_view.dart';
import '../../../trainer/settings/get_help_view.dart';
import '../../../trainer/settings/notification_settings_view.dart';
import '../../../trainer/settings/privacy_policy_view.dart';
import '../../../trainer/settings/profile_information_view.dart';
import '../../../trainer/settings/refer_new_member_view.dart';
import '../../../trainer/settings/terms_and_conditions_view.dart';
import '../availability/availability_view.dart';
import '../profile/groom_view_profile.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Menu', fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
        actions: [
          InkWell(
            onTap: ()=> Get.to(() => const NotificationsView()),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.borderLight)),
                child: const Icon(Icons.notifications_none, color: Colors.black, size: 24),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Account Settings'),
            _buildMenuCard([
              _buildMenuItem(Icons.person_outline, 'Personal Information', onTap: () => Get.to(() => const ProfileInformationView())),
              _buildMenuItem(Icons.edit_note, 'Edit Profile', onTap: () => Get.to(() =>  EditVendorProfileView())),
              _buildMenuItem(Icons.bookmark_border, 'Login & Security', onTap: () => Get.to(() => const AccountSettingsView())),
              _buildMenuItem(Icons.notifications_outlined, 'Notifications', onTap: () => Get.to(() => const NotificationSettingsView())),
            /*  _buildMenuItem(Icons.settings_outlined, 'Privacy and sharing'),*/
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Services'),
            _buildMenuCard([
              _buildMenuItem(Icons.room_service_outlined, 'Services & Rates', onTap: () => Get.to(() => const ServicesRatesView())),
              _buildMenuItem(Icons.history, 'Past Clients', onTap: () => Get.to(() => const PastClientsView())),
              _buildMenuItem(Icons.people_outline, 'Upcoming Clients', onTap: () => Get.to(() => const UpcomingClientsView())),
              _buildMenuItem(Icons.calendar_month_outlined, 'Calendar & Availability', onTap: () => Get.to(() => const AvailabilityView())),
              if (_hasRole(['farrier']))
                _buildMenuItem(iconPath: "assets/icons/operations.svg", Icons.fact_check_outlined, 'Operations & Compliance', onTap: () {
                  // Navigate to Operations & Compliance view
                }),

              if (_hasRole(['bodywork']))
                _buildMenuItem(iconPath: "assets/icons/insurance.svg", Icons.fact_check_outlined, 'Insurance', onTap: () {
                  // Navigate to Operations & Compliance view
                }),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Referrals'),
            _buildMenuCard([
              _buildMenuItem(Icons.group_add_outlined, 'Refer a New Member', onTap: () => Get.to(() => const ReferNewMemberView())),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Support'),
            _buildMenuCard([
              _buildMenuItem(Icons.help_outline, 'Get Help', onTap: () => Get.to(() => const GetHelpView())),
              _buildMenuItem(Icons.message_outlined, 'Share your feedback', onTap: () => Get.to(() => const FeedbackView())),
              _buildMenuItem(Icons.article_outlined, 'Privacy policy', onTap: () => Get.to(() => const PrivacyPolicyView())),
              _buildMenuItem(Icons.description_outlined, 'Terms & conditions', onTap: () => Get.to(() => const TermsAndConditionsView())),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const AvailabilityView()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            SvgPicture.asset("assets/images/logo.svg", width: 40, height: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CommonText('Add Your Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                  CommonText('Manage your availability blocks', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap,String? iconPath }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            iconPath != null ? SvgPicture.asset(iconPath) :Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: CommonText(title, fontSize: AppTextSizes.size16, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutDialog(Get.context!),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: AppColors.accentRed, size: 20),
            SizedBox(width: 8),
            CommonText('Logout', color: AppColors.accentRed, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          ],
        ),
      ),
    );
  }

  bool _hasRole(List<String> targetRoles) {
    final user = Get.find<AuthController>().currentUser.value;
    if (user == null) return false;

    final targetLower = targetRoles.map((e) => e.toLowerCase()).toList();

    // 1. Check primary role
    if (targetLower.contains(user.role.toLowerCase())) return true;

    // 2. Check roles list
    if (user.roles.any((r) => targetLower.contains(r.toLowerCase()))) return true;

    // 3. Check assigned services (vendorServices)
    return user.vendorServices.any((s) => targetLower.contains(s.toLowerCase()));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFFFF1F1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFD92D20), size: 28),
              ),
              const SizedBox(height: 20),
              const CommonText('Are you sure you want to logout?', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: 'Logout',
                      backgroundColor: const Color(0xFFD92D20),
                      textColor: Colors.white,
                      onPressed: () {
                        Get.back();
                        Get.put(AuthController()).logout();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
