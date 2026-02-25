import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:get/get.dart';

class AddNewListingView extends StatefulWidget {
  const AddNewListingView({super.key});

  @override
  State<AddNewListingView> createState() => _AddNewListingViewState();
}

class _AddNewListingViewState extends State<AddNewListingView> {
  int _currentStep = 1;
  bool _activeStatus = true;
  final List<int> _entries = [1, 2];
  final Set<String> _selectedListingTypes = {'Sale', 'Annual Lease'};

  final Set<String> _selectedProgramTags = {
    'High Performance Jumper (1.20m +)',
    'Young Developing Hunter',
  };
  final Set<String> _selectedOpportunityTags = {
    'Investment Type',
    'Owner Flexible',
  };
  final Set<String> _selectedExperienceTags = {
    'Short/Long Stirrup',
    'Young Developing Hunter',
  };
  final Set<String> _selectedPersonalityTags = {
    'Sensitive Ride',
    'Forward Ride',
  };

  final List<String> _programTags = [
    'Big Equitation',
    'High Performance Hunter (3\'6" +)',
    'High Performance Jumper (1.20m +)',
    'Young Developing Hunter',
    'Young Developing Jumper',
    'Schoolmaster',
    'Prospect',
    'Division Pony',
  ];

  final List<String> _opportunityTags = [
    'Open to outside miles',
    'Firesale',
    'Investment Type',
    'Owner Flexible',
    'Open to Paid Trials',
    'Backburner',
  ];

  final List<String> _experienceTags = [
    'Division Pony',
    'Beginner Friendly',
    'Short/Long Stirrup',
    'Young Developing Hunter',
    'Crossrails',
    '2\'6"',
    '3\'0-3\'3"',
    '3\'6"',
    '3\'6"+',
    '1.0m',
    '1.10m',
    '1.20m',
    '1.30m',
    '1.40m',
    '1.50m',
    'FEI',
  ];

  final List<String> _personalityTags = [
    'Jr/Amateur Friendly',
    'Brave / Bold',
    'Sensitive Ride',
    'Forward Ride',
    'Auto Lead Change',
    'Careful',
    'Push Ride',
    'Pro Ride',
  ];

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
                        'Upload Images and video',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildUploadCard(),
                    ] else if (_currentStep == 2) ...[
                      const CommonText(
                        'Horse Information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildHorseInformationForm(),
                    ] else if (_currentStep == 3) ...[
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
                    ] else if (_currentStep == 4) ...[
                      const CommonText(
                        'Other information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildOtherInformationForm(),
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
                              setState(() {
                                _entries.add(
                                  _entries.isEmpty ? 1 : _entries.last + 1,
                                );
                              });
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
          Row(
            children: [
              _buildImageItem(
                imageUrl: AppConstants.dummyImageUrl,
                isImage: true,
              ),
              const SizedBox(width: 12),
              _buildImageItem(
                imageUrl: AppConstants.dummyImageUrl,
                isImage: false,
              ),
              const SizedBox(width: 12),
              _buildAddButton(),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              text: 'Video link ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: [
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
              children: const [
                Icon(Icons.link, color: AppColors.textSecondary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
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

  Widget _buildImageItem({required String imageUrl, required bool isImage}) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: CommonImageView(url: imageUrl),
          ),
          if (!isImage)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                hintText: 'e.g., Beautiful Hunter for Sale',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Horse Name',
                hintText: 'Enter horse name',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      label: 'Age',
                      hintText: 'e.g., 12 years',
                      isRequired: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      label: 'Height',
                      hintText: 'e.g., 16.2hh',
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Breed',
                hintText: 'Enter horse breed',
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Color',
                hintText: 'Enter horse color',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CommonText(
                      'Select discipline',
                      color: AppColors.textSecondary,
                      fontSize: AppTextSizes.size14,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Description',
                hintText: 'Write here...',
                isRequired: true,
                maxLines: 4,
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
                      child: const TextField(
                        decoration: InputDecoration(
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
                  const SizedBox(width: 12),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE5E7EB,
                      ), // Gray background as design
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.open_in_new,
                      color: AppColors.textPrimary,
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
    return Column(
      children: [
        _buildListingTypeCard('Sale'),
        const SizedBox(height: 12),
        _buildListingTypeCard('Annual Lease'),
        const SizedBox(height: 12),
        _buildListingTypeCard('Short Term or Circuit Lease'),
        const SizedBox(height: 12),
        _buildListingTypeCard('Weekly Lease'),
      ],
    );
  }

  Widget _buildListingTypeCard(String title) {
    final bool isSelected = _selectedListingTypes.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedListingTypes.remove(title);
          } else {
            _selectedListingTypes.add(title);
          }
        });
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              title,
              fontSize: AppTextSizes.size16,
              fontWeight: isSelected
                  ? FontWeight.w500
                  : FontWeight.w500, // Matching the design
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherInformationForm() {
    return Column(
      children: [
        _buildTagSection(
          title: 'Program Tag',
          isOptional: true,
          tags: _programTags,
          selectedTags: _selectedProgramTags,
        ),
        const SizedBox(height: 16),
        _buildTagSection(
          title: 'Opportunity Tag',
          isOptional: true,
          tags: _opportunityTags,
          selectedTags: _selectedOpportunityTags,
        ),
        const SizedBox(height: 16),
        _buildTagSection(
          title: 'Experience',
          isOptional: false,
          tags: _experienceTags,
          selectedTags: _selectedExperienceTags,
        ),
        const SizedBox(height: 16),
        _buildTagSection(
          title: 'Personality Tag',
          isOptional: false,
          tags: _personalityTags,
          selectedTags: _selectedPersonalityTags,
        ),
      ],
    );
  }

  Widget _buildTagSection({
    required String title,
    required bool isOptional,
    required List<String> tags,
    required Set<String> selectedTags,
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
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: isOptional
                  ? [
                      const TextSpan(
                        text: '  (optional)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedTags.remove(tag);
                    } else {
                      selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
              Switch(
                value: _activeStatus,
                onChanged: (val) {
                  setState(() {
                    _activeStatus = val;
                  });
                },
                activeColor: const Color(0xFF047857),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._entries.asMap().entries.map((entry) {
          int index = entry.key;
          int entryNum = entry.value;
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
                        'Entry $entryNum',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _entries.removeAt(index);
                          });
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
                  const CommonTextField(
                    label: 'City/State',
                    hintText: 'e.g., Welling.',
                  ),
                  const SizedBox(height: 16),
                  const CommonTextField(
                    label: 'Show Venue',
                    hintText: 'e.g., Welling.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: CommonTextField(
                          label: 'Start Date',
                          hintText: 'Select date',
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CommonTextField(
                          label: 'End Date',
                          hintText: 'Select date',
                          suffixIcon: Icon(
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
        }).toList(),
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
                if (_currentStep > 1) {
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
                      isLastStep ? 'Preview' : 'Cancel',
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
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  // Final Publish Listing integration API call would happen here
                  Get.back(); // Mock return indicating success
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
                  isLastStep ? 'Publish Listing' : 'Save',
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
}
