import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_textfield.dart';

class ServicesRatesView extends StatefulWidget {
  const ServicesRatesView({super.key});

  @override
  State<ServicesRatesView> createState() => _ServicesRatesViewState();
}

class _ServicesRatesViewState extends State<ServicesRatesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Services & Rates', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBraidingServicesCard(),
            const SizedBox(height: 20),
            _buildRateCard(),
            const SizedBox(height: 20),
            _buildAdditionalServicesCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildBraidingServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Braiding Services', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          const CommonText('Select your braiding skills', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSkillChip('Hunter Mane', true),
              _buildSkillChip('Hunter Tail', true),
              _buildSkillChip('Jumper Braid', false),
              _buildSkillChip('Dressage Braid', false),
              _buildSkillChip('Button Braids', false),
            ],
          ),
          const SizedBox(height: 16),
          _buildAddSkillButton(),
        ],
      ),
    );
  }

  Widget _buildRateCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Rate', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          _buildRateInput('Daily Rate'),
          const SizedBox(height: 20),
          _buildRateInput('Weekly Rate', showLengthToggle: true),
          const SizedBox(height: 20),
          _buildRateInput('Monthly Rate', showLengthToggle: true),
        ],
      ),
    );
  }

  Widget _buildRateInput(String label, {bool showLengthToggle = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppColors.borderLight)),
                    ),
                    child: const CommonText('\$50', fontSize: AppTextSizes.size18, color: AppColors.textPrimary),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showLengthToggle) ...[
            const SizedBox(height: 16),
            const CommonText('Choose your week length', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLengthToggle('5 days week', true),
                const SizedBox(width: 8),
                _buildLengthToggle('6 days week', false),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Additional Services', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          _buildServiceItem('Hunter Braiding Mane', 'Per horse', '40', true),
          const SizedBox(height: 12),
          _buildServiceItem('Jumper Braiding', 'Per horse', '0', false),
          const SizedBox(height: 12),
          _buildServiceItem('Dressage Braiding', 'Per horse', '0', false),
          const SizedBox(height: 16),
          _buildAddSkillButton(),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : AppColors.borderLight),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size12, color: isSelected ? const Color(0xFF000B48) : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildLengthToggle(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B4444) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size14, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildServiceItem(String title, String subtitle, String price, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Checkbox(value: isSelected, onChanged: (v) {}, activeColor: const Color(0xFF000B48)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                CommonText(subtitle, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CommonText('\$ $price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.textPrimary : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillButton() {
    return TextButton.icon(
      onPressed: () => _showAddSkillBS(),
      icon: const Icon(Icons.add, size: 18, color: AppColors.linkBlue),
      label: const CommonText('Add Skill', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }

  void _showAddSkillBS() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const CommonText('Add Skill', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonTextField(label: 'Skill', hintText: 'Enter your skill'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText('Price per horse', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.borderLight)),
                          ),
                          child: const CommonText('\$30', fontSize: AppTextSizes.size18, color: AppColors.textPrimary),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              decoration: InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: 'Cancel',
                    backgroundColor: Colors.white,
                    textColor: AppColors.textPrimary,
                    borderColor: AppColors.borderLight,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                text: 'Cancel',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.borderLight,
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonButton(
                text: 'Save',
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
