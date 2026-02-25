import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/view/trainer/trainer_profile_setup_view.dart';
import 'package:get/get.dart';

class SelectRoleView extends StatefulWidget {
  const SelectRoleView({super.key});

  @override
  State<SelectRoleView> createState() => _SelectRoleViewState();
}

class _SelectRoleViewState extends State<SelectRoleView> {
  String _selectedRole = 'Trainer';

  final List<Map<String, String>> _roles = [
    {
      'title': 'Trainer',
      'subtitle': 'List horses and manage your program.',
      'value': 'Trainer',
    },
    {
      'title': 'Service Provider',
      'subtitle': 'Offer services and accept bookings.',
      'value': 'Service Provider',
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
                      AppStrings.helpOtherTrustedProfessionalsConnectWithYouByCompletingYourApplicationBelow,
                      fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                        height: 1.4,
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
              child: CommonButton(
                text: AppStrings.continueText,
                onPressed: () {
                  if (_selectedRole == 'Trainer') {
                    Get.to(() => const TrainerProfileSetupView(),
                    );
                  } else {
                    // Logic for other roles
                  }
                },
              ),
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
