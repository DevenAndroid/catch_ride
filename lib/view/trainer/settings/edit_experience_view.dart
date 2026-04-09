import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/app_strings.dart';

class EditExperienceView extends StatefulWidget {
  const EditExperienceView({super.key});

  @override
  State<EditExperienceView> createState() => _EditExperienceViewState();
}

class _EditExperienceViewState extends State<EditExperienceView> {
  final ProfileController _profileController = Get.find<ProfileController>();
  late List<String> _specialties;
  late List<String> _circuits;
  late String _selectedYears;
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _circuitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _specialties = List<String>.from(
      _profileController.userData['programTags'] ?? [],
    );
    _circuits = List<String>.from(
      _profileController.userData['showCircuits'] ?? [],
    );
    _selectedYears =
        _profileController.userData['yearsExperience']?.toString() ??
        _profileController.userData['experience']?.toString() ??
        'Select years';
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    _circuitController.dispose();
    super.dispose();
  }

  Future<void> _saveExperience() async {
    final Map<String, dynamic> updateData = {
      'yearsExperience': _selectedYears,
      'programTags': _specialties,
      'showCircuits': _circuits,
    };

    final success = await _profileController.updateProfile(updateData);
    if (success) {
      await _profileController.fetchProfile();
      Get.back();

      Get.snackbar(
        'Success',
        'Experience updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to update experience',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
          'Experience',
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
                    onPressed: () => _saveExperience(),
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
          // Years in industry
          const CommonText(
            AppStrings.yearsInIndustry,

            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: ['0-1', '2-4', '5-9', '10+'].contains(_selectedYears)
                ? _selectedYears
                : null,
            items: ['0-1', '2-4', '5-9', '10+'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: CommonText(value, fontSize: 14),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedYears = val ?? 'Select years');
            },
            decoration: InputDecoration(
              hintText: 'Select years',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: 24),

          // Specialties
          const CommonText(
            'Specialties',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildTagsInput(_specialties, 'Add specialty', _specialtyController),
          const SizedBox(height: 24),

          // Show Circuits
          const CommonText(
            'Show Circuits',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildTagsInput(_circuits, 'Add circuit', _circuitController),
        ],
      ),
    );
  }

  Widget _buildTagsInput(
    List<String> tags,
    String hint,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...tags.map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(tag, fontSize: 13, color: AppColors.textPrimary),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tags.remove(tag);
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    tags.add(value.trim());
                    controller.clear();
                  });
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
