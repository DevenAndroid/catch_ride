import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/validators.dart';

class EditBasicInfoView extends StatefulWidget {
  const EditBasicInfoView({super.key});

  @override
  State<EditBasicInfoView> createState() => _EditBasicInfoViewState();
}

class _EditBasicInfoViewState extends State<EditBasicInfoView> {
  File? _profileImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  final ProfileController _profileController = Get.find<ProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileController.fullName);
    _phoneController = TextEditingController(
      text: _profileController.phone.replaceAll('+1', '').trim(),
    );
    _aboutController = TextEditingController(text: _profileController.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final nameParts = _nameController.text.trim().split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '';

    final Map<String, dynamic> updateData = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': '+1 ${_phoneController.text.trim()}',
      'bio': _aboutController.text.trim(),
    };

    // 1. Update text data
    bool success = await _profileController.updateProfile(updateData);

    // 2. Upload images if picked
    if (success) {
      if (_profileImage != null) {
        await _profileController.uploadImage(_profileImage!.path, 'avatar');
      }
      if (_bannerImage != null) {
        await _profileController.uploadImage(_bannerImage!.path, 'cover');
      }

      // 3. Final refresh and go back
      await _profileController.fetchProfile();
      Get.back();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 85);
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
      backgroundColor: Colors.white,
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
          'Basic info',
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
        child: Column(children: [_buildEditCard(), const SizedBox(height: 32)]),
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
                child: Obx(
                  () => CommonButton(
                    text: 'Save',
                    isLoading: _profileController.isLoading.value,
                    onPressed: () => _saveProfile(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditCard() {
    return Form(
      key: _formKey,
      child: Container(
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
            // Profile Photo
            const CommonText(
              'Profile Photo',
              fontSize: 14,
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
                        color: const Color(0xFFF9FAFB),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Banner Image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  'Banner Image',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
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
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _bannerImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_bannerImage!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(
                            Icons.add,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            CommonTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Phone Number
            const CommonText(
              'Phone Number',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CommonText(
                    '+1',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validations.phoneValidator,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: 'Enter phone number',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About
            CommonTextField(
              controller: _aboutController,
              label: 'About',
              hintText: 'Write a short bio',
              maxLines: 4,
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
    this.borderRadius = 16,
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

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
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
