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
  final TextEditingController _yearsInIndustryController = TextEditingController();


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
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
                                      color: AppColors.border.withOpacity(0.5),
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
                            errorText: 'Please enter your Full Name'),
                      ),
                      const SizedBox(height: 16),
                      const CommonText(
                        AppStrings.phoneNumber,
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: const [
                                CommonText(
                                  AppStrings.num91,
                                  fontSize: AppTextSizes.size14,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: AppTextSizes.size14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: AppStrings.enterPhoneNumber,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
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
                            'Years in industry',
                            fontSize: AppTextSizes.size14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showSingleSelectBottomSheet(
                              title: 'Years in industry',
                              currentValue: _yearsInIndustryController.text,
                              items: List.generate(51, (index) => index.toString()),
                              onSelected: (val) {
                                setState(() => _yearsInIndustryController.text = val);
                              },
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CommonText(
                                      _yearsInIndustryController.text.isEmpty ? 'Select years' : _yearsInIndustryController.text,
                                      fontSize: 14,
                                      color: _yearsInIndustryController.text.isEmpty
                                          ? AppColors.textSecondary.withOpacity(0.5)
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                                ],
                              ),
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
              child: Obx(() => CommonButton(
                text: AppStrings.continueText,
                isLoading: _authController.isLoading.value,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  // Split Name
                  final nameParts = _fullNameController.text.trim().split(' ');
                  final firstName = nameParts.first;
                  final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ' ';

                  // Handle Image Uploads first if needed
                  String? profileUrl;
                  String? bannerUrl;
                  
                  _authController.isLoading.value = true;
                  try {
                    if (_profileImage != null) {
                      profileUrl = await _profileController.uploadRawFile(_profileImage!.path);
                    }
                    if (_bannerImage != null) {
                      bannerUrl = await _profileController.uploadRawFile(_bannerImage!.path);
                    }

                    final Map<String, dynamic> profileData = {
                      'firstName': firstName,
                      'lastName': lastName,
                      'phone': _phoneController.text.trim(),
                      'bio': _bioController.text.trim(),
                      'yearsInIndustry': _yearsInIndustryController.text.trim(),
                    };

                    if (profileUrl != null) profileData['avatar'] = profileUrl;
                    if (bannerUrl != null) profileData['coverImage'] = bannerUrl;

                    await _authController.completeBarnManagerProfile(profileData);
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

  void _showSingleSelectBottomSheet({
    required String title,
    required String currentValue,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CommonText(title, fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == currentValue;
                      return InkWell(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Center(
                            child: CommonText(
                              item, 
                              fontSize: 16, 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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
