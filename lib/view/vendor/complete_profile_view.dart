import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_complete_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroomCompleteProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Complete Your Profile',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicDetailsSection(controller),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(controller),
                const SizedBox(height: 24),
                _buildHighlightsSection(controller),
                const SizedBox(height: 32),
                CommonButton(
                  text: 'Next',
                  backgroundColor: AppColors.primary,
                  onPressed: controller.submit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicDetailsSection(GroomCompleteProfileController controller) {
    return _buildContainer(
      title: 'Basic Details',
      children: [
        const CommonText('Profile Photo', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              Obx(() => CommonImageView(
                    height: 100,
                    width: 100,
                    shape: BoxShape.circle,
                    file: controller.profileImage.value,
                    isUserImage: true,
                  )),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const CommonText('Banner Image', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.pickBannerImage,
          child: Obx(() => Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMedium, style: BorderStyle.solid), // Should be dashed, using solid for now
                  color: AppColors.lightGray.withOpacity(0.3),
                  image: controller.bannerImage.value != null
                      ? DecorationImage(image: FileImage(controller.bannerImage.value!), fit: BoxFit.cover)
                      : null,
                ),
                child: controller.bannerImage.value == null
                    ? const Center(child: Icon(Icons.add, size: 30, color: Colors.grey))
                    : null,
              )),
        ),
        const SizedBox(height: 24),
        CommonTextField(
          label: 'Full Name',
          controller: controller.fullNameController,
          hintText: 'Enter your full name',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildPhoneField(controller),
        const SizedBox(height: 20),
        CommonTextField(
          label: 'Business Name (optional)',
          controller: controller.businessNameController,
          hintText: 'Enter your business name',
        ),
        const SizedBox(height: 20),
        CommonTextField(
          label: 'About',
          controller: controller.aboutController,
          hintText: 'Write a short bio',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildPhoneField(GroomCompleteProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Phone Number', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CommonText(controller.countryCode.value, fontSize: 15, color: AppColors.textPrimary),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.borderLight),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection(GroomCompleteProfileController controller) {
    return _buildContainer(
      title: 'Payment Methods',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.paymentOptions.length,
          itemBuilder: (context, index) {
            final option = controller.paymentOptions[index];
            return Obx(() {
              final isSelected = controller.selectedPaymentMethods.contains(option['name']);
              return GestureDetector(
                onTap: () => controller.togglePaymentMethod(option['name'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEDF2FF) : Colors.white,
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPaymentIcon(option['icon']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonText(
                          option['name'] as String,
                          fontSize: AppTextSizes.size14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
        const SizedBox(height: 16),
        CommonTextField(
          label: '',
          controller: controller.otherPaymentController,
          hintText: 'Write here...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildPaymentIcon(dynamic icon) {
    if (icon is IconData) {
      return Icon(icon, size: 24, color: AppColors.primary);
    }
    // Handle image assets if paths provided
    return const Icon(Icons.payment, size: 24, color: AppColors.primary);
  }

  Widget _buildHighlightsSection(GroomCompleteProfileController controller) {
    return _buildContainer(
      title: 'Experience Highlights',
      children: [
        CommonTextField(
          label: '',
          controller: controller.highlightInputController,
          hintText: 'Write here...',
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.addHighlight,
          child: const Row(
            children: [
              Icon(Icons.add, color: AppColors.linkBlue, size: 20),
              SizedBox(width: 4),
              CommonText('Add More', color: AppColors.linkBlue, fontWeight: FontWeight.w600),
            ],
          ),
        ),
        Obx(() => Column(
              children: controller.highlights
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildHighlightItem(e.value, () => controller.removeHighlight(e.key)),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildHighlightItem(String text, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: CommonText(text, fontSize: AppTextSizes.size14)),
          GestureDetector(onTap: onDelete, child: const Icon(Icons.close, size: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
