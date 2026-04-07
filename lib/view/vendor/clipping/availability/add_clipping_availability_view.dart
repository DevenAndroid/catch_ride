import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClippingAvailabilityView extends StatefulWidget {
  const AddClippingAvailabilityView({super.key});

  @override
  State<AddClippingAvailabilityView> createState() => _AddClippingAvailabilityViewState();
}

class _AddClippingAvailabilityViewState extends State<AddClippingAvailabilityView> {
  final RxInt maxHorses = 6.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Add Availability Block', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBlockCard(),
            const SizedBox(height: 32),
            _buildFooterButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Block 1', fontSize: 16, fontWeight: FontWeight.bold),
              const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Availability'),
          Row(
            children: [
              Expanded(child: _buildDatePickerField('Start Date')),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePickerField('End Date')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Mark Unavailability'),
          Row(
            children: [
              Expanded(child: _buildDatePickerField('Start Date')),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePickerField('End Date')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Location Type'),
          _buildDropdownField('Select a Location Type'),
          const SizedBox(height: 24),
          _buildSectionHeader('Show Venue or City'),
          CommonTextField(label: '', hintText: 'Enter Show Venue or City', controller: TextEditingController()),
          const SizedBox(height: 12),
          _buildChips(),
          const SizedBox(height: 24),
          _buildSectionHeader('Time Block & Capacity'),
          const CommonText('Availability Type', fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildDropdownField('Full Day'),
          const SizedBox(height: 16),
          const CommonText('Capacity', fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildDropdownField('Max horses per day'),
          const SizedBox(height: 16),
          const CommonText('Max Horses', fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildStepperField(),
          const SizedBox(height: 24),
          const CommonText('Notes For Trainers (optional)', fontSize: 14, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CommonText(title, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDatePickerField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 12, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Select Date', fontSize: 14, color: AppColors.textSecondary),
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(value, fontSize: 14, color: AppColors.textPrimary),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStepperField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => maxHorses.value > 0 ? maxHorses.value-- : null, icon: const Icon(Icons.remove, size: 18, color: AppColors.textSecondary)),
          Obx(() => CommonText('${maxHorses.value}', fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => maxHorses.value++, icon: const Icon(Icons.add, size: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildChips() {
    final List<String> locations = ['Bruces Field', 'Highfields', 'Chagrin Valley Farms'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: locations.map((loc) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(loc, fontSize: 12, color: AppColors.textPrimary),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Any specific preference, requirements, or information trainers should know...',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
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
            backgroundColor: AppColors.primary,
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }
}
