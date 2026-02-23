import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class HorseListingCreateController extends GetxController {
  final horseNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final breedController = TextEditingController();
  final colorController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final usefController = TextEditingController();

  final selectedDiscipline = ''.obs;
  final disciplines = [
    'Hunter',
    'Jumper',
    'Equitation',
    'Dressage',
    'Eventing',
  ];

  final selectedListingType = <String>[].obs;
  final listingTypes = [
    'Sale',
    'Annual Lease',
    'Short Term Lease',
    'Weekly Lease',
  ];

  // Pricing Fields
  final salePriceController = TextEditingController();
  final isSaleInquire = false.obs;

  final annualLeasePriceController = TextEditingController();
  final isAnnualLeaseInquire = false.obs;

  final shortTermLeasePriceController = TextEditingController();
  final isShortTermLeaseInquire = false.obs;

  final weeklyLeasePriceController = TextEditingController();
  final isWeeklyLeaseInquire = false.obs;

  // Program Tags
  final programTags = [
    'Big Equitation',
    'High Performance Hunter (3\'6"+)',
    'High Performance Jumper (1.20m+)',
    'Young Developing Hunter',
    'Young Developing Jumper',
    'Schoolmaster',
    'Prospect',
    'Division Pony',
    'Beginner Friendly',
  ];
  final selectedProgramTags = <String>[].obs;

  // Opportunity Tags
  final opportunityTags = [
    'Open to outside miles',
    'Firesale',
    'Investment Type',
    'Owner Flexible',
    'Open to Paid Trials',
    'Backburner',
  ];
  final selectedOpportunityTags = <String>[].obs;

  // Personality Tags
  final personalityTags = [
    'Jr/Amateur Friendly',
    'Brave / Bold',
    'Sensitive Ride',
    'Forward Ride',
    'Auto Lead Change',
    'Careful',
    'Push Ride',
    'Pro Ride',
  ];
  final selectedPersonalityTags = <String>[].obs;

  // Experience Levels
  final experienceLevels = ['Pony', 'Beginner Friendly', 'Short/Long Stirrup'];
  final selectedExperienceLevels = <String>[].obs;

  // Jump Heights (Imperial)
  final jumpHeightsImperial = [
    'Crossrails',
    '2\'6"',
    '3\'0" – 3\'3"',
    '3\'6"',
    '3\'6"+',
  ];
  final selectedJumpHeightsImperial = <String>[].obs;

  // Jump Heights (Metric)
  final jumpHeightsMetric = [
    '1.0m',
    '1.10m',
    '1.20m',
    '1.30m',
    '1.40m',
    '1.50m',
  ];
  final selectedJumpHeightsMetric = <String>[].obs;

  // Advanced
  final isFEI = false.obs;

  // Show Records (Max 3)
  final showRecords = List.generate(3, (_) => ShowRecordInput());

  // Availability Entries
  final availabilityEntries = <AvailabilityEntry>[AvailabilityEntry()].obs;
  final locationTypes = ['Home City / State', 'Horse Show Venue'];

  void toggleListingType(String type) {
    if (selectedListingType.contains(type)) {
      selectedListingType.remove(type);
    } else {
      selectedListingType.add(type);
    }
  }

  void toggleProgramTag(String tag) {
    if (selectedProgramTags.contains(tag)) {
      selectedProgramTags.remove(tag);
    } else {
      selectedProgramTags.add(tag);
    }
  }

  void toggleOpportunityTag(String tag) {
    if (selectedOpportunityTags.contains(tag)) {
      selectedOpportunityTags.remove(tag);
    } else {
      selectedOpportunityTags.add(tag);
    }
  }

  void togglePersonalityTag(String tag) {
    if (selectedPersonalityTags.contains(tag)) {
      selectedPersonalityTags.remove(tag);
    } else {
      selectedPersonalityTags.add(tag);
    }
  }

  void toggleExperienceLevel(String level) {
    if (selectedExperienceLevels.contains(level)) {
      selectedExperienceLevels.remove(level);
    } else {
      selectedExperienceLevels.add(level);
    }
  }

  void addAvailabilityEntry() {
    availabilityEntries.add(AvailabilityEntry());
  }

  void removeAvailabilityEntry(int index) {
    availabilityEntries[index].dispose();
    availabilityEntries.removeAt(index);
  }

  Future<void> selectDate(
    BuildContext context,
    Rxn<DateTime> dateObs,
    TextEditingController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateObs.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      dateObs.value = picked;
      controller.text = DateFormat.yMMMd().format(picked);
    }
  }

  void toggleImperialHeight(String height) {
    if (selectedJumpHeightsImperial.contains(height)) {
      selectedJumpHeightsImperial.remove(height);
    } else {
      selectedJumpHeightsImperial.add(height);
    }
  }

  void toggleMetricHeight(String height) {
    if (selectedJumpHeightsMetric.contains(height)) {
      selectedJumpHeightsMetric.remove(height);
    } else {
      selectedJumpHeightsMetric.add(height);
    }
  }

  void saveListing() {
    Get.snackbar('Coming Soon', 'Listing creation logic to be implemented');
  }

  @override
  void onClose() {
    horseNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    breedController.dispose();
    colorController.dispose();
    descriptionController.dispose();
    salePriceController.dispose();
    annualLeasePriceController.dispose();
    shortTermLeasePriceController.dispose();
    weeklyLeasePriceController.dispose();
    usefController.dispose();
    for (var record in showRecords) {
      record.dispose();
    }
    for (var entry in availabilityEntries) {
      entry.dispose();
    }
    super.onClose();
  }
}

class HorseListingCreateScreen extends StatelessWidget {
  const HorseListingCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HorseListingCreateController());

    // _buildPricingRow removed

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Horse Listing'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Section
            Text('Media (Required)', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Photos & Videos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Horse Info
            Text('Horse Info', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Horse Name *',
              controller: controller.horseNameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Age',
                    controller: controller.ageController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Height (hh)',
                    controller: controller.heightController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Breed',
                    controller: controller.breedController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Color',
                    controller: controller.colorController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text('Listing Type *', style: AppTextStyles.labelLarge),
            Obx(
              () => Wrap(
                spacing: 8,
                children: controller.listingTypes
                    .map(
                      (type) => FilterChip(
                        label: Text(type),
                        selected: controller.selectedListingType.contains(type),
                        onSelected: (_) => controller.toggleListingType(type),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color: controller.selectedListingType.contains(type)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),
            Text('Discipline', style: AppTextStyles.labelLarge),
            // Mock Dropdown for Discipline
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedDiscipline.value.isEmpty
                    ? null
                    : controller.selectedDiscipline.value,
                items: controller.disciplines
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) =>
                    controller.selectedDiscipline.value = val ?? '',
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select Discipline'),
                style: AppTextStyles.bodyLarge,
              ),
            ),

            const SizedBox(height: 24),
            CustomTextField(
              label: 'Description *',
              controller: controller.descriptionController,
              minLines: 4,
              maxLines: 10,
              hint: 'Describe the horse\'s capabilities, temperament, etc.',
            ),

            const SizedBox(height: 24),
            Text('Program Tags', style: AppTextStyles.labelLarge),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.programTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: controller.selectedProgramTags.contains(tag),
                        onSelected: (_) => controller.toggleProgramTag(tag),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color: controller.selectedProgramTags.contains(tag)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Opportunity Tags (Optional)',
              style: AppTextStyles.labelLarge,
            ),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.opportunityTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: controller.selectedOpportunityTags.contains(
                          tag,
                        ),
                        onSelected: (_) => controller.toggleOpportunityTag(tag),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedOpportunityTags.contains(tag)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text('Personality Tags', style: AppTextStyles.labelLarge),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.personalityTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: controller.selectedPersonalityTags.contains(
                          tag,
                        ),
                        onSelected: (_) => controller.togglePersonalityTag(tag),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedPersonalityTags.contains(tag)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Experience Division / Typical Level',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pony & Beginner Levels',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.experienceLevels
                    .map(
                      (level) => FilterChip(
                        label: Text(level),
                        selected: controller.selectedExperienceLevels.contains(
                          level,
                        ),
                        onSelected: (_) =>
                            controller.toggleExperienceLevel(level),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedExperienceLevels.contains(
                                level,
                              )
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text('Jump Heights (Imperial)', style: AppTextStyles.labelLarge),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.jumpHeightsImperial
                    .map(
                      (height) => FilterChip(
                        label: Text(height),
                        selected: controller.selectedJumpHeightsImperial
                            .contains(height),
                        onSelected: (_) =>
                            controller.toggleImperialHeight(height),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedJumpHeightsImperial.contains(
                                height,
                              )
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text('Jump Heights (Metric)', style: AppTextStyles.labelLarge),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.jumpHeightsMetric
                    .map(
                      (height) => FilterChip(
                        label: Text(height),
                        selected: controller.selectedJumpHeightsMetric.contains(
                          height,
                        ),
                        onSelected: (_) =>
                            controller.toggleMetricHeight(height),
                        selectedColor: AppColors.deepNavy,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedJumpHeightsMetric.contains(
                                height,
                              )
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        checkmarkColor: Colors.white,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),
            Obx(
              () => CheckboxListTile(
                title: const Text('Advanced / International (FEI Experience)'),
                value: controller.isFEI.value,
                onChanged: (val) => controller.isFEI.value = val ?? false,
                activeColor: AppColors.deepNavy,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 24),
            CustomTextField(
              label: 'USEF Number (Optional)',
              controller: controller.usefController,
            ),

            const SizedBox(height: 32),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Open USEF search
              },
              child: const Text(
                'Go to USEF Search',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Show Record (Optional)', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Highlight up to 3 recent accomplishments.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              final record = controller.showRecords[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: index == 0 ? 'Placing' : '',
                        hint: '1st',
                        controller: record.place,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: index == 0 ? 'Location / Show' : '',
                        hint: 'WEF 3',
                        controller: record.location,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: index == 0 ? 'Date' : '',
                        hint: 'Jan 2025',
                        controller: record.date,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),
            Text(
              'Availability & Location',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Availability calendar supports multiple entries per horse (repeatable rows), each with location + date range.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            // Availability List
            Obx(
              () => Column(
                children: [
                  ...controller.availabilityEntries.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Entry #${index + 1}',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                              if (controller.availabilityEntries.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.softRed,
                                  ),
                                  onPressed: () =>
                                      controller.removeAvailabilityEntry(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Type',
                                style: AppTextStyles.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => DropdownButtonFormField<String>(
                                  value: item.locationType.value,
                                  items: controller.locationTypes
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      item.locationType.value = val!,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Venue / City',
                            controller: item.locationController,
                            hint: 'Enter location name',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Start Date',
                                  hint: 'Select Date',
                                  controller: item.startDateController,
                                  readOnly: true,
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.grey500,
                                  ),
                                  onTap: () => controller.selectDate(
                                    context,
                                    item.startDate,
                                    item.startDateController,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  label: 'End Date',
                                  hint: 'Select Date',
                                  controller: item.endDateController,
                                  readOnly: true,
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.grey500,
                                  ),
                                  onTap: () => controller.selectDate(
                                    context,
                                    item.endDate,
                                    item.endDateController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: controller.addAvailabilityEntry,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.deepNavy,
                      ),
                      label: const Text(
                        'Add Another Availability Range',
                        style: TextStyle(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Publish Listing',
              onPressed: controller.saveListing,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ShowRecordInput {
  final place = TextEditingController();
  final location = TextEditingController();
  final date = TextEditingController();

  void dispose() {
    place.dispose();
    location.dispose();
    date.dispose();
  }
}

class AvailabilityEntry {
  final locationType = 'Home City / State'.obs;
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  void dispose() {
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
