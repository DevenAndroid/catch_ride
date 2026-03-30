import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAvailabilityBlockView extends StatefulWidget {
  const AddAvailabilityBlockView({super.key});

  @override
  State<AddAvailabilityBlockView> createState() => _AddAvailabilityBlockViewState();
}

class _AddAvailabilityBlockViewState extends State<AddAvailabilityBlockView> {
  final _maxHorses = 6.obs;
  final _maxDays = 12.obs;

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
        title: const CommonText('Add Availability Block', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CommonText('Block 1', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                  Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   Expanded(child: _buildDateField('Start Date')),
                   const SizedBox(width: 16),
                   Expanded(child: _buildDateField('End Date')),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Show Venue'),
              _buildTextField('Enter show venue'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildVenueTag('Bruces Field'),
                  _buildVenueTag('Highfields'),
                  _buildVenueTag('Chagrin Valley Farms'),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Work Type'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('Show week support', isSelected: false),
                  _buildChip('Daily barn help', isSelected: false),
                  _buildChip('Fill In/ daily show support', isSelected: false),
                  _buildChip('Seasonal / Temporary', isSelected: true),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Additional Services'),
              Wrap(
                spacing: 8,
                children: [
                  _buildChip('Hunter Braiding Mane', isSelected: true),
                  _buildChip('Jumper Braiding', isSelected: false),
                ],
              ),
              const SizedBox(height: 24),
              const CommonText('Capacity (optional)', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter('Max Horses', _maxHorses)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter('Max Days', _maxDays)),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Notes For Trainers (optional)'),
              _buildTextField('Any specific preference, requirements, or information trainers should knoe...', maxLines: 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
                  text: 'Add Block',
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CommonText('Select date', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
              Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: maxLines > 1 ? const Color(0xFFF9FAFB) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
      ),
    );
  }

  Widget _buildVenueTag(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(text, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: CommonText(
        label,
        fontSize: AppTextSizes.size12,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCounter(String label, RxInt value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () => value.value > 0 ? value.value-- : null),
              Obx(() => CommonText('${value.value}', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => value.value++),
            ],
          ),
        ),
      ],
    );
  }
}
