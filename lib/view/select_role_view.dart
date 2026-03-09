import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/trainer/trainer_profile_setup_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';

class SelectRoleView extends StatefulWidget {
  const SelectRoleView({super.key});

  @override
  State<SelectRoleView> createState() => _SelectRoleViewState();
}

class _SelectRoleViewState extends State<SelectRoleView> {
  final AuthController _authController = Get.find<AuthController>();
  String _selectedRole = 'Trainer';

  final List<Map<String, String>> _roles = [
    {
      'title': AppStrings.trainer,
      'subtitle': AppStrings.trainersAndServiceProviders,
      'value': AppStrings.trainer,
      'backendValue': 'trainer',
    },
    {
      'title': AppStrings.serviceProvider,
      'subtitle': AppStrings.offerServicesAndAcceptBookings,
      'value': AppStrings.serviceProvider,
      'backendValue': 'service_provider',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const CommonText(
          AppStrings.selectYourRole,
          color: AppColors.textPrimary,
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonText(
                      AppStrings.chooseHowYouWillUseCatchRide,
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 32),
                    ..._roles.map(
                      (role) => _buildRoleCard(
                        title: role['title']!,
                        subtitle: role['subtitle']!,
                        value: role['value']!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() => CommonButton(
                text: AppStrings.continueText,
                isLoading: _authController.isLoading.value,
                onPressed: () async {
                  // Store selected role
                  final roleData = _roles.firstWhere((r) => r['value'] == _selectedRole);
                  final backendRole = roleData['backendValue']!;
                  _authController.selectedRole.value = backendRole;

                  // Update role via profile API
                  final apiService = Get.find<ApiService>();
                  try {
                    _authController.isLoading.value = true;
                    final response = await apiService.putRequest(
                      AppUrls.updateRole,
                      {'role': backendRole},
                    );
                    if (response.statusCode == 200) {
                      // Save role locally
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('role', backendRole);

                      // Navigate based on role
                      if (backendRole == 'trainer') {
                        Get.to(() => const TrainerProfileSetupView());
                      } else {
                        // Service Provider — go to submitted screen
                        _authController.navigateAfterRoleSet();
                      }
                    } else {
                      Get.snackbar(AppStrings.error, AppStrings.failedToSetRole,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    }
                  } finally {
                    _authController.isLoading.value = false;
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    title,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    subtitle,
                    fontSize: AppTextSizes.size14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 6 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
