import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/add_new_listing_controller.dart';
import 'package:catch_ride/view/trainer/list/listing_preview_view.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddNewListingView extends StatefulWidget {
  const AddNewListingView({super.key});

  @override
  State<AddNewListingView> createState() => _AddNewListingViewState();
}

class _AddNewListingViewState extends State<AddNewListingView> {
  final AddNewListingController controller = Get.put(AddNewListingController());
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;

  Future<void> _selectDateTime(BuildContext context, TextEditingController textController) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        textController.text = DateFormat('dd MMM yyyy').format(finalDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Add new listing',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    if (_currentStep == 1) ...[
                      const CommonText(
                        'Horse Information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: _buildHorseInformationForm(),
                      ),
                    ] else if (_currentStep == 2) ...[
                      const CommonText(
                        'Listing Type',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      const CommonText(
                        'Select one or more types',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      _buildListingTypeSelection(),
                    ] else if (_currentStep == 3) ...[
                      const CommonText(
                        'Other information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildOtherInformationForm(),
                    ] else if (_currentStep == 4) ...[
                      const CommonText(
                        'Upload Images and video',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildUploadCard(),
                    ] else if (_currentStep == 5) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            'Availability',
                            fontSize: AppTextSizes.size18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.addEntry();
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.add, color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                CommonText(
                                  'Add Entry',
                                  color: Colors.blue,
                                  fontSize: AppTextSizes.size14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildAvailabilityForm(),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == _currentStep;
        final isCompleted = stepNumber < _currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF047857)
                      : Colors.white, // Green for completed
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF047857)
                        : (isActive ? AppColors.textPrimary : AppColors.border),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : CommonText(
                        '$stepNumber',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
              ),
              if (index < 4)
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Upload ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...controller.localImages.asMap().entries.map((entry) {
                int index = entry.key;
                File file = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => controller.removeLocalImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              GestureDetector(
                onTap: controller.pickImage,
                child: _buildAddButton(),
              ),
            ],
          )),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              text: 'Video link ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: ' (optional)',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.videoLinkController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: 'https://url.com',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddButton() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        color: const Color(0xFFFAFAFA),
      ),
      child: const Center(
        child: Icon(Icons.add, color: AppColors.textSecondary, size: 24),
      ),
    );
  }

  Widget _buildHorseInformationForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                label: 'Listing Title',
                controller: controller.listingTitleController,
                hintText: 'Children\'s Hunter',
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter the listing title';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Horse\'s Registered Name',
                controller: controller.horseNameController,
                hintText: 'Enter name',
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter the horse name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Location',
                controller: controller.locationController,
                hintText: 'Enter horse\'s location',
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter the location';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      label: 'Age',
                      controller: controller.ageController,
                      hintText: 'Enter age',
                      isRequired: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      label: 'Height',
                      controller: controller.heightController,
                      hintText: 'Enter height',
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Breed',
                controller: controller.breedController,
                hintText: 'Enter breed',
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter the breed';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Color',
                controller: controller.colorController,
                hintText: 'Enter color',
                isRequired: false,
              ),
              const SizedBox(height: 16),

              // Discipline Dropdown Stub
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: const CommonText(
                  'Discipline',
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() => GestureDetector(
                onTap: () => _showSingleSelectBottomSheet(
                  title: 'Select Discipline',
                  currentValue: controller.selectedDiscipline.value,
                  items: ['Hunter', 'Jumper', 'Equitation'],
                  onSelected: (val) {
                    controller.selectedDiscipline.value = val;
                    controller.disciplineController.text = val;
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        controller.selectedDiscipline.value.isEmpty 
                            ? 'Select discipline' 
                            : controller.selectedDiscipline.value,
                        color: controller.selectedDiscipline.value.isEmpty 
                            ? AppColors.textSecondary 
                            : AppColors.textPrimary,
                        fontSize: AppTextSizes.size14,
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Description',
                controller: controller.descriptionController,
                hintText: 'Write here...',
                isRequired: true,
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter the description';
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Horse USEF number ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: ' (optional)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: controller.usefNumberController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter USEF number',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppTextSizes.size14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypeSelection() {
    return Obx(
      () => Column(
        children: [
          _buildListingTypeCard(
            title: 'Sale',
            isSelected: controller.selectedListingTypes.contains('Sale'),
            onTap: () => controller.toggleListingType('Sale'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Annual Lease',
            isSelected: controller.selectedListingTypes.contains('Annual Lease'),
            onTap: () => controller.toggleListingType('Annual Lease'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Short Term or Circuit Lease',
            isSelected: controller.selectedListingTypes.contains('Short Term or Circuit Lease'),
            onTap: () => controller.toggleListingType('Short Term or Circuit Lease'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Weekly Lease',
            isSelected: controller.selectedListingTypes.contains('Weekly Lease'),
            onTap: () => controller.toggleListingType('Weekly Lease'),
          ),
        ],
      ),
    );
  }

  Widget _buildListingTypeCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isInquire = controller.inquireForPrice[title] ?? false;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE9F0FF) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF00084D) : const Color(0xFFD1D5DB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    title,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF00084D) : const Color(0xFF475467),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.inquireForPrice[title] = !isInquire;
                      controller.inquireForPrice.refresh();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isInquire ? const Color(0xFF00084D) : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isInquire ? const Color(0xFF00084D) : const Color(0xFFD0D5DD),
                            ),
                          ),
                          child: isInquire
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const CommonText(
                          'Inquire for price',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  if (!isInquire) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                'Min Price',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                              const SizedBox(height: 8),
                              _buildPriceTextField(
                                controller: controller.minPriceControllers[title]!,
                                hintText: 'Enter min price',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                'Max Price',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                              const SizedBox(height: 8),
                              _buildPriceTextField(
                                controller: controller.maxPriceControllers[title]!,
                                hintText: 'Enter max price',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF667085),
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00084D), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildOtherInformationForm() {
    return Obx(() {
      if (controller.isTagsLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (controller.tagTypes.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(child: CommonText('No tags available', color: AppColors.textSecondary)),
        );
      }

      return Column(
        children: controller.tagTypes.map((type) {
          final String typeName = type['name'] ?? 'Tag';
          final List values = type['values'] ?? [];
          final List<String> tagNames = values.map((v) => v['name'].toString()).toList();
          final Map<String, String> nameToId = {
            for (var v in values) v['name'].toString(): v['_id'].toString()
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDynamicTagSection(
              title: typeName,
              tagNames: tagNames,
              nameToId: nameToId,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDynamicTagSection({
    required String title,
    required List<String> tagNames,
    required Map<String, String> nameToId,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              children: [
                if (title.toLowerCase().contains('optional') || title == 'Opportunity Tag')
                  const TextSpan(
                    text: ' (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 12,
              children: tagNames.map((name) {
                final id = nameToId[name]!;
                final isSelected = controller.selectedTags.contains(id);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.selectedTags.remove(id);
                    } else {
                      controller.selectedTags.add(id);
                    }
                  },
                  child: _buildTagChip(name, isSelected),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00084D) : const Color(0xFFE5E7EB),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CommonText(
        label,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? const Color(0xFF00084D) : AppColors.textPrimary,
      ),
    );
  }


  Widget _buildAvailabilityForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CommonText(
                    'Active Status',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4),
                  CommonText(
                    'Make listing visible to others',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Obx(
                () => Switch(
                  value: controller.activeStatus.value,
                  onChanged: (val) {
                    controller.activeStatus.value = val;
                  },
                  activeThumbColor: const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              ...controller.availabilityEntries.asMap().entries.map((entry) {
                int index = entry.key;
                AvailabilityEntry availabilityEntry = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              'Entry ${availabilityEntry.id}',
                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.removeEntry(index);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CommonTextField(
                          label: 'City/State',
                          controller: availabilityEntry.cityStateController,
                          hintText: 'e.g., Welling.',
                        ),
                        const SizedBox(height: 16),
                        CommonTextField(
                          label: 'Show Venue',
                          controller: availabilityEntry.showVenueController,
                          hintText: 'e.g., Welling.',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                label: 'Start Date',
                                controller:
                                    availabilityEntry.startDateController,
                                hintText: 'Select date',
                                readOnly: true,
                                onTap: () => _selectDateTime(context, availabilityEntry.startDateController),
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                label: 'End Date',
                                controller: availabilityEntry.endDateController,
                                hintText: 'Select date',
                                readOnly: true,
                                onTap: () => _selectDateTime(context, availabilityEntry.endDateController),
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: controller.addEntry,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CommonText(
                      'Add another entry',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final bool isLastStep = _currentStep == 5;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isLastStep) {
                  Get.to(() => const ListingPreviewView());
                } else if (_currentStep > 1) {
                  setState(() {
                    _currentStep--;
                  });
                } else {
                  Get.back();
                }
              },
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLastStep) ...[
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    CommonText(
                      isLastStep ? 'Preview' : (_currentStep > 1 ? 'Back' : 'Cancel'),
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentStep < 5) {
                  if (_currentStep == 1) {
                    if (!_formKey.currentState!.validate()) return;
                    if (controller.selectedDiscipline.value.isEmpty) {
                      Get.snackbar('Required', 'Please select a discipline',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white);
                      return;
                    }
                  } else if (_currentStep == 2) {
                    if (!controller.validateStep2()) return;
                  }
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  controller.publishListing();
                }
              },
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CommonText(
                  isLastStep ? 'Publish Listing' : 'Next',
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
                          child: Row(
                            children: [
                              Expanded(child: CommonText(item, fontSize: 15)),
                              if (isSelected) const Icon(Icons.check, color: AppColors.primary, size: 20),
                            ],
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
