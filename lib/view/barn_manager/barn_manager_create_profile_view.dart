import 'dart:io';
import 'dart:ui';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:form_field_validator/form_field_validator.dart';
import '../../utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import 'barn_manager_application_submitted_view.dart';

class BarnManagerCreateProfileView extends StatefulWidget {
  const BarnManagerCreateProfileView({super.key});

  @override
  State<BarnManagerCreateProfileView> createState() =>
      _BarnManagerCreateProfileViewState();
}

class _BarnManagerCreateProfileViewState
    extends State<BarnManagerCreateProfileView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.put(ProfileController());
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsInIndustryController =
      TextEditingController();

  File? _profileImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _yearsInIndustryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isProfile ? 800 : 1600, // Profile is smaller, banner can be wider
        maxHeight: isProfile ? 800 : 1600,
        imageQuality: 85, // Adds native compression
      );
      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else {
            _bannerImage = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

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
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          AppStrings.profileSetup,
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
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          AppStrings.basicDetails,
                          fontSize: AppTextSizes.size18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 24),
                        const CommonText(
                          AppStrings.profilePhoto,
                          fontSize: AppTextSizes.size14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => _pickImage(true),
                            child: Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F4F7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border.withOpacity(0.5),
                                    ),
                                  ),
                                  child: _profileImage != null
                                      ? ClipOval(
                                          child: Image.file(
                                            _profileImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person_outline,
                                          size: 50,
                                          color: AppColors.textSecondary,
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.border.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CommonText(
                          AppStrings.bannerImage,
                          fontSize: AppTextSizes.size14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: CustomPaint(
                            painter: _bannerImage == null
                                ? DashPainter(color: AppColors.border)
                                : null,
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _bannerImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _bannerImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.add,
                                        color: AppColors.textSecondary,
                                        size: 30,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CommonTextField(
                          controller: _fullNameController,
                          label: AppStrings.fullName,
                          hintText: AppStrings.enterYourFullName,
                          isRequired: true,
                          validator: RequiredValidator(
                            errorText: 'Please enter your Full Name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CommonText(
                              'Phone Number',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.borderMedium),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: const [
                                        CommonText(
                                          '+1',
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: AppColors.borderMedium,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                      validator: Validations.phoneValidator,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: 'Enter phone number',
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CommonTextField(
                          controller: _bioController,
                          label: 'About',
                          hintText: 'Write a short bio',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const CommonText(
                              AppStrings.yearsInIndustry,

                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 8),
                             DropdownButtonFormField<String>(
                               value: _yearsInIndustryController.text.isEmpty ? null : _yearsInIndustryController.text,
                               items: ['0-1', '2-4', '5-9', '10+'].map((String value) {
                                 return DropdownMenuItem<String>(
                                   value: value,
                                   child: CommonText(value, fontSize: 14),
                                 );
                               }).toList(),
                               onChanged: (val) {
                                 setState(() => _yearsInIndustryController.text = val ?? '');
                               },
                               decoration: InputDecoration(
                                 hintText: 'Select years',
                                 hintStyle: TextStyle(
                                   color: AppColors.textSecondary.withOpacity(0.5),
                                   fontSize: 14,
                                 ),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                   borderSide: const BorderSide(color: AppColors.primary),
                                 ),
                                 filled: true,
                                 fillColor: Colors.white,
                               ),
                               icon: const Icon(
                                 Icons.keyboard_arrow_down,
                                 color: AppColors.textSecondary,
                                 size: 20,
                               ),
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(
                () => CommonButton(
                  text: AppStrings.continueText,
                  isLoading: _authController.isLoading.value,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    // Split Name
                    final nameParts = _fullNameController.text.trim().split(
                      ' ',
                    );
                    final firstName = nameParts.first;
                    final lastName = nameParts.length > 1
                        ? nameParts.sublist(1).join(' ')
                        : ' ';

                    // Handle Image Uploads first if needed
                    String? profileUrl;
                    String? bannerUrl;

                    _authController.isLoading.value = true;
                    try {
                      if (_profileImage != null) {
                        profileUrl = await _profileController.uploadRawFile(
                          _profileImage!.path,
                          type: 'profile',
                        );
                      }
                      if (_bannerImage != null) {
                        bannerUrl = await _profileController.uploadRawFile(
                          _bannerImage!.path,
                          type: 'profile',
                        );
                      }

                      final Map<String, dynamic> profileData = {
                        'firstName': firstName,
                        'lastName': lastName,
                        'phone': _phoneController.text.trim(),
                        'bio': _bioController.text.trim(),
                        'yearsInIndustry': _yearsInIndustryController.text
                            .trim(),
                      };

                      if (profileUrl != null)
                        profileData['avatar'] = profileUrl;
                      if (bannerUrl != null)
                        profileData['coverImage'] = bannerUrl;

                      await _authController.completeBarnManagerProfile(
                        profileData,
                      );
                    } finally {
                      _authController.isLoading.value = false;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class DashPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashPainter oldDelegate) => false;
}
