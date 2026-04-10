import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF9F9F9),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicDetailsSection(controller),
                const SizedBox(height: 20),
                _buildPaymentMethodsSection(controller),
                const SizedBox(height: 20),
                _buildHighlightsSection(controller),
                const SizedBox(height: 20),
                _buildNotesSection(controller),
                const SizedBox(height: 32),
                Obx(() => CommonButton(
                  text: 'Next',
                  isLoading: controller.isLoading.value,
                  backgroundColor: const Color(0xFF001144),
                  onPressed: controller.submit,
                )),
                const SizedBox(height: 40),
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
      subtitle: 'Add your information as it will appear to clients',
      children: [
        const CommonText('Profile Photo', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(() => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                ),
                child: CommonImageView(
                      height: 100,
                      width: 100,
                      shape: BoxShape.circle,
                      file: controller.profileImage.value,
                      isUserImage: true,
                    ),
              )),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const CommonText('Banner Image', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.pickBannerImage,
          child: Obx(() => Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  image: controller.bannerImage.value != null
                      ? DecorationImage(image: FileImage(controller.bannerImage.value!), fit: BoxFit.cover)
                      : null,
                ),
                child: controller.bannerImage.value == null
                    ? CustomPaint(
                        painter: DashPainter(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, size: 24, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            const CommonText('Click to upload image', color: Color(0xFF3366FF), fontWeight: FontWeight.w600),
                            const SizedBox(height: 4),
                            const CommonText('PNG or JPG (max. 800x400px)', color: AppColors.textSecondary, fontSize: 10),
                          ],
                        ),
                      )
                    : null,
              )),
        ),
        const SizedBox(height: 24),
        _buildInputField(
          label: 'Full Name',
          controller: controller.fullNameController,
          hintText: 'Thomas Martin',
          isRequired: true,
          validator: RequiredValidator(errorText: 'Please enter your full name'),
        ),
        const SizedBox(height: 20),
        _buildPhoneField(controller),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Business Name (optional)',
          controller: controller.businessNameController,
          hintText: 'Enter your business name',
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'About',
          controller: controller.aboutController,
          hintText: 'Write a short bio',
          maxLines: 4,
          isRequired: false, 
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            if (isRequired) const CommonText(' *', fontSize: AppTextSizes.size14, color: Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        CommonTextField(
          label: '',
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
          validator: validator,
          fillColor: const Color(0xFFF5F5F5),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(GroomCompleteProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Phone Number', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
              Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.3)),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    counterText: '',
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
      subtitle: 'Select the payment methods you accept:',
      children: [
        Obx(() {
          if (controller.isPaymentLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
                      border: Border.all(color: isSelected ? const Color(0xFF001144) : Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildPaymentIcon(option),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CommonText(
                            option['name'] as String,
                            fontSize: 13.0,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),

                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final isOtherSelected = controller.selectedPaymentMethods.contains('Other');
          if (!isOtherSelected) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText('Specify Other Payment Method', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              CommonTextField(
                label: '',
                controller: controller.otherPaymentController,
                hintText: 'Enter payment details (e.g. Venmo @username)',
                maxLines: 2,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }


  Widget _buildPaymentIcon(Map<String, dynamic> option) {
    final name = option['name'].toString().toLowerCase();
    
    // Custom handling for icons shown in the image
    if (name.contains('venmo')) return const Icon(Icons.payment, color: Colors.blue, size: 28);
    if (name.contains('zelle')) return const Icon(Icons.bolt, color: Colors.purple, size: 24);
    if (name.contains('cash')) return const Icon(Icons.money, color: Colors.green, size: 24);
    if (name.contains('credit card')) return const Icon(Icons.credit_card, color: Color(0xFF001144), size: 24);
    if (name.contains('ach')) return const Icon(Icons.account_balance, color: Color(0xFF795548), size: 24);
    if (name.contains('other')) return const Icon(Icons.add_circle, color: Colors.grey, size: 24);


    if (option['isUrl'] == true && option['icon'] != null && option['icon'].toString().isNotEmpty) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CommonImageView(url: option['icon'], fit: BoxFit.contain),
      );
    }
    return const Icon(Icons.payment, size: 24, color: AppColors.primary);
  }

  Widget _buildHighlightsSection(GroomCompleteProfileController controller) {
    return _buildContainer(
      title: 'Experience Highlights',
      subtitle: 'Share key experience, programs, or specialties you\'d like clients to know:',
      optional: true,
      children: [
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.highlightControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: '',
                        controller: controller.highlightControllers[index],
                        hintText: 'e.g. Specialized in show jumping',
                        maxLines: 1,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                    ),
                    if (controller.highlightControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => controller.removeHighlight(index),
                      ),
                  ],
                );
              },
            )),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.addHighlight,
          child: const Row(
            children: [
              Icon(Icons.add, color: Color(0xFF3366FF), size: 18),
              SizedBox(width: 4),
              CommonText('Add More', color: Color(0xFF3366FF), fontWeight: FontWeight.w600, fontSize: 13),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildNotesSection(GroomCompleteProfileController controller) {
    return _buildContainer(
      title: 'Notes For Trainer',
      subtitle: 'Add any details that would help trainers understand your preferences or availability',
      optional: true,
      children: [
        CommonTextField(
          label: '',
          controller: controller.notesForTrainerController,
          hintText: 'Write here...',
          maxLines: 3,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
      ],
    );
  }

  Widget _buildContainer({
    required String title,
    required List<Widget> children,
    String? subtitle,
    bool optional = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
              if (optional) const CommonText(' (optional)', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            CommonText(subtitle, fontSize: 12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    var path = Path();
    path.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(12)));
    
    double dashWidth = 5, dashSpace = 3;
    double distance = 0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
