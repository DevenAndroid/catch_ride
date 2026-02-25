import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInformationView extends StatefulWidget {
  const ProfileInformationView({super.key});

  @override
  State<ProfileInformationView> createState() => _ProfileInformationViewState();
}

class _ProfileInformationViewState extends State<ProfileInformationView> {
  String _selectedFederation = 'USEF (United States)';

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
          'Profile Information',
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
          children: [
            _buildFederationCard(),
            const SizedBox(height: 16),
            _buildSocialCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText(
                      'Cancel',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonButton(text: 'Save', onPressed: () => Get.back()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFederationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Federation Information',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),
          // Dropdown Mock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  _selectedFederation,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: 'Federation ID Number',
            hintText: 'ID Number',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CommonText(
            'Social Media & Website',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 16),
          CommonTextField(
            label: 'Facebook',
            hintText: 'facebook.com/yourpage',
            isRequired: true,
          ),
          SizedBox(height: 16),
          CommonTextField(
            label: 'Website URL',
            hintText: 'https://yourwebsite.com',
            prefixIcon: Icon(
              Icons.link,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          CommonTextField(label: 'Instagram', hintText: '@yourusername'),
        ],
      ),
    );
  }
}
