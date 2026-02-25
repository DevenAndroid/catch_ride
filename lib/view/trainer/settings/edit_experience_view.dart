import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditExperienceView extends StatefulWidget {
  const EditExperienceView({super.key});

  @override
  State<EditExperienceView> createState() => _EditExperienceViewState();
}

class _EditExperienceViewState extends State<EditExperienceView> {
  final List<String> _specialties = ['Jump', 'Dance'];
  final List<String> _circuits = ['WEC Ocala', 'Tryon'];
  String _selectedYears = 'Select years';

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
                child: CommonButton(text: 'Save', onPressed: () => Get.back()),
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
            'Years in industry',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
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
                  _selectedYears,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
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
          _buildTagsInput(_specialties, 'Well|'),
          const SizedBox(height: 24),

          // Show Circuits
          const CommonText(
            'Show Circuits',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildTagsInput(_circuits, 'Well|'),
        ],
      ),
    );
  }

  Widget _buildTagsInput(List<String> tags, String hint) {
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
                  const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: TextField(
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
