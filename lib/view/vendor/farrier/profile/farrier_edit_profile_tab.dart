import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';

import 'package:catch_ride/widgets/common_dropdown.dart';
import 'package:catch_ride/widgets/common_suggestion_field.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/common_button.dart';
import '../../../../widgets/common_image_view.dart';

class FarrierEditProfileTab extends StatefulWidget {
  final EditVendorProfileController controller;

  const FarrierEditProfileTab({
    super.key,
    required this.controller,
  });

  @override
  State<FarrierEditProfileTab> createState() => _FarrierEditProfileTabState();
}

class _FarrierEditProfileTabState extends State<FarrierEditProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHomeBaseLocation(),
        const SizedBox(height: 20),
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildDisciplinesSection(),
        const SizedBox(height: 20),
        _buildTypicalLevelSection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildFarrierCertificationsSection(),
        const SizedBox(height: 20),
        _buildScopeOfWorkSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(),
        const SizedBox(height: 20),
        _buildClientIntakeSection(),
        const SizedBox(height: 20),
        _buildInsuranceSection(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHomeBaseLocation() {
    return _buildCard(
      title: 'Home Base Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Country', isRequired: true),
          Obx(() => CommonDropdown(
            value: widget.controller.countryController.text,
            hint: 'Select Country',
            options: widget.controller.countries,
            onSelected: (val) => widget.controller.onCountrySelected(val),
          )),
          const SizedBox(height: 16),
          
          _buildFieldLabel('State / Province', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: widget.controller.stateController,
            hint: 'Select State/Province',
            suggestions: widget.controller.states,
            isLoading: widget.controller.isLoadingStates.value,
            onSelected: (val) => widget.controller.onStateSelected(val),
          )),
          const SizedBox(height: 16),
          
          _buildFieldLabel('City', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: widget.controller.cityController,
            hint: widget.controller.stateController.text.isEmpty ? 'Select state first' : 'Select City',
            suggestions: widget.controller.cities,
            isLoading: widget.controller.isLoadingCities.value,
            onSelected: (val) => widget.controller.onCitySelected(val),
          )),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildCard(
      title: 'Experience',
      child: Obx(() => _buildDropdownTrigger(
        value: widget.controller.experience.value != null ? '${widget.controller.experience.value} Years' : null,
        hint: 'Select Years of Experience',
        onTap: () => _showPickerBottomSheet(
          title: 'Experience (Years)',
          options: widget.controller.experienceOptions.map((e) => '$e Years').toList(),
          onSelected: (val) => widget.controller.experience.value = val.replaceAll(' Years', '')
        ),
      )),
    );
  }

  Widget _buildDisciplinesSection() {
    return _buildCard(
      title: 'Disciplines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the disciplines you most commonly work with.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.disciplineOptions.map((disc) {
              final isSelected = widget.controller.selectedDisciplines.contains(disc);
              return GestureDetector(
                onTap: () => widget.controller.toggleDiscipline(disc),
                child: _buildChoiceChip(disc, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (widget.controller.selectedDisciplines.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: widget.controller.otherDisciplineController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTypicalLevelSection() {
    return _buildCard(
      title: 'Typical Level of Horses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the types of horses you most frequently work with.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.horseLevelOptions.map((level) {
              final isSelected = widget.controller.selectedHorseLevels.contains(level);
              return GestureDetector(
                onTap: () => widget.controller.toggleHorseLevel(level),
                child: _buildChoiceChip(level, isSelected),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildRegionsCoveredSection() {
    return _buildCard(
      title: 'Regions Covered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the regions you work.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          _buildDropdownTrigger(
            hint: 'Select Regions...',
            onTap: () => _showMultiSelectBottomSheet(
              title: 'Select Regions',
              options: widget.controller.regionOptions,
              selectedItems: widget.controller.selectedRegions,
              onToggle: (v) => widget.controller.toggleRegion(v),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: widget.controller.selectedRegions.map((region) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildRemovableTag(region, showRemove: true, onRemove: () => widget.controller.toggleRegion(region)),
            )).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCard(
      title: 'Social Media & Website',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Please include at least one profile for verification.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          CommonTextField(label: 'Facebook', hintText: 'facebook.com/yourpage', controller: widget.controller.facebookController),
          const SizedBox(height: 16),
          CommonTextField(label: 'Instagram', hintText: '@yourusername', controller: widget.controller.instagramController),
        ],
      ),
    );
  }

  Widget _buildFarrierCertificationsSection() {
    return _buildCard(
      title: 'Farrier Certifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select your certifications.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.certificationOptions.map((cert) {
              final isSelected = widget.controller.selectedCertifications.contains(cert);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    widget.controller.selectedCertifications.remove(cert);
                  } else {
                    widget.controller.selectedCertifications.add(cert);
                  }
                },
                child: _buildChoiceChip(cert, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (widget.controller.selectedCertifications.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: widget.controller.otherCertificationController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildScopeOfWorkSection() {
    return _buildCard(
      title: 'Scope of Work',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select your primary focus areas.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.controller.farrierScopeOptions.map((opt) {
              final isSelected = widget.controller.selectedFarrierScope.contains(opt);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    widget.controller.selectedFarrierScope.remove(opt);
                  } else {
                    widget.controller.selectedFarrierScope.add(opt);
                  }
                },
                child: _buildChoiceChip(opt, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (widget.controller.selectedFarrierScope.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: widget.controller.otherFarrierScopeController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFarrierServicesSection() {
    return _buildCard(
      title: 'Farrier Services & Add-ons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Farrier Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildServicesList(widget.controller.farrierServices),
          const SizedBox(height: 24),
          const CommonText('Add-Ons', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildServicesList(widget.controller.farrierAddOns),
        ],
      ),
    );
  }

  Widget _buildServicesList(RxList services) {
    return Obx(() => Column(
      children: services.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;
        final isSelected = service['isSelected'].value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (val) => service['isSelected'].value = val ?? false,
                  activeColor: const Color(0xFF001149),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 100,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                      Expanded(
                        child: TextField(
                          controller: service['price'],
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: '0'),
                          style: const TextStyle(fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [PriceInputFormatter()],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildAddPhotosSection() {
    return _buildCard(
      title: 'Add Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Upload photos to showcase your work and details', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...widget.controller.serviceExistingPhotos['Farrier']!.asMap().entries.map((entry) => _photoBox(
                url: entry.value,
                onRemove: () => widget.controller.removeServiceExistingPhoto('Farrier', entry.key),
              )),
              ...widget.controller.serviceNewPhotos['Farrier']!.asMap().entries.map((entry) => _photoBox(
                file: entry.value,
                onRemove: () => widget.controller.removeServiceNewPhoto('Farrier', entry.key),
              )),
              _addPhotoBox(),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTravelPreferencesSection() {
    final options = [
      {'title': 'Local Only', 'subtitle': 'Varies by location'},
      {'title': 'Regional', 'subtitle': null},
      {'title': 'Nationwide', 'subtitle': null},
      {'title': 'International', 'subtitle': null},
    ];

    return _buildCard(
      title: 'Travel Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select how far you are willing to travel and any applicable fees',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Obx(() => Column(
                children: options.map((opt) {
                  final title = opt['title'] as String;
                  final subtitle = opt['subtitle'] as String?;
                  final isSelected = widget.controller.selectedTravel.contains(title);

                  final feeType = widget.controller.selectedTravelData[title]?['type'] ?? 'No travel fee';

                  return GestureDetector(
                    onTap: () => _showTravelFeeBottomSheet(context, title),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF001149) : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                              ),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  title,
                                  fontSize: AppTextSizes.size14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF001149) : AppColors.textPrimary,
                                ),
                                const SizedBox(height: 2),
                                CommonText(
                                  feeType,
                                  fontSize: AppTextSizes.size12,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildClientIntakeSection() {
    final policyOptions = [
      'Accepting new clients',
      'Limited availability',
      'Referral-only',
      'Not accepting new clients'
    ];

    return _buildCard(
      title: 'Client Intake + Scheduling',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Set your availability and client preferences',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.dividerColor),
          const SizedBox(height: 16),
          const CommonText('New Client Policy', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: policyOptions.map((opt) {
              final isSelected = widget.controller.farrierNewClientPolicy.value == opt;
              return GestureDetector(
                onTap: () => widget.controller.farrierNewClientPolicy.value = opt,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(
                          opt,
                          fontSize: AppTextSizes.size14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF001149) : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 12),
          const Divider(color: AppColors.dividerColor),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Minimum horses per stop', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
              Row(
                children: [
                  _counterButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (widget.controller.farrierMinHorses.value > 1) {
                        widget.controller.farrierMinHorses.value--;
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Obx(() => CommonText(
                    '${widget.controller.farrierMinHorses.value}',
                    fontSize: AppTextSizes.size18,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(width: 16),
                  _counterButton(
                    icon: Icons.add,
                    onTap: () => widget.controller.farrierMinHorses.value++,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.dividerColor),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Emergency Support', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
              Obx(() => Switch(
                value: widget.controller.farrierEmergencySupport.value,
                onChanged: (val) => widget.controller.farrierEmergencySupport.value = val,
                activeColor: const Color(0xFF13CA8B),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection() {
    final options = [
      'Carries Insurance',
      'Insurance available upon request',
      'Not currently insured'
    ];

    return _buildCard(
      title: 'Insurance Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Keep your insurance information up to date to remain active and receive requests',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Obx(() => Column(
            children: options.map((opt) {
              final isSelected = widget.controller.farrierInsuranceStatus.value == opt;
              return GestureDetector(
                onTap: () => widget.controller.farrierInsuranceStatus.value = opt,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(
                          opt,
                          fontSize: AppTextSizes.size14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF001149) : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildCard(
      title: 'Cancellation Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Set your cancellation preferences.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => _buildDropdownTrigger(
            value: widget.controller.cancellationPolicy.value,
            hint: 'Select Cancellation Policy',
            onTap: () => _showPickerBottomSheet(
              title: 'Cancellation Policy',
              options: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'],
              onSelected: (val) => widget.controller.cancellationPolicy.value = val
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => Checkbox(
                value: widget.controller.isCustomCancellation.value,
                onChanged: (val) => widget.controller.isCustomCancellation.value = val ?? false,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              )),
              const CommonText('Custom', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
            ],
          ),
          Obx(() {
            if (widget.controller.isCustomCancellation.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: widget.controller.customCancellationController, maxLines: 4),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _counterButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildChoiceChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E1B4B) : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: CommonText(
        text,
        fontSize: AppTextSizes.size12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? const Color(0xFF1E1B4B) : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdownTrigger({String? value, required String hint, required VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: CommonText(value != null && value.isNotEmpty ? value : hint, fontSize: AppTextSizes.size14, color: value != null && value.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary, overflow: TextOverflow.ellipsis)),
            if (isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
            else
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableTag(String text, {bool showRemove = false, VoidCallback? onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary)),
          if (showRemove) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoBox({String? url, File? file, required VoidCallback onRemove}) {
    return Stack(
      children: [
        CommonImageView(
          url: url,
          file: file,
          width: 80,
          height: 80,
          radius: 12,
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoBox() {
    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.none),
        ),
        child: const Icon(Icons.add, color: AppColors.textSecondary, size: 24),
      ),
    );
  }

  // Bottom Sheets
  void _showPickerBottomSheet({required String title, required List<String> options, required Function(String) onSelected}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  title: CommonText(options[index], textAlign: TextAlign.center),
                  onTap: () {
                    onSelected(options[index]);
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectBottomSheet({required String title, required List<String> options, required List<String> selectedItems, required Function(String) onToggle}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            Flexible(
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = selectedItems.contains(item);
                  return CheckboxListTile(
                    title: CommonText(item),
                    value: isSelected,
                    onChanged: (val) => onToggle(item),
                    activeColor: AppColors.primary,
                  );
                },
              )),
            ),
            const SizedBox(height: 20),
            CommonButton(text: 'Done', onPressed: () => Get.back(), backgroundColor: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showTravelFeeBottomSheet(BuildContext context, String category) {
    final config = widget.controller.selectedTravelData[category] ?? {'type': 'No travel fee', 'price': '', 'disclaimer': ''};
    widget.controller.tempSelectedFeeType.value = config['type'] ?? 'No travel fee';
    widget.controller.travelFeePriceController.text = config['price']?.toString() ?? '';
    widget.controller.travelFeeDisclaimerController.text = config['disclaimer'] ?? '';

    final feeOptions = ['No travel fee', 'Flat fee', 'Per-mile', 'Varies by location'];

    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CommonText(category, fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              const CommonText(
                'Set pricing based on travel distance or location',
                fontSize: AppTextSizes.size14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Obx(() => Column(
                children: feeOptions.map((type) {
                  final isTypeSelected = widget.controller.tempSelectedFeeType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (widget.controller.tempSelectedFeeType.value != type) {
                          widget.controller.travelFeePriceController.clear();
                          widget.controller.travelFeeDisclaimerController.clear();
                        }
                        widget.controller.tempSelectedFeeType.value = type;
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isTypeSelected ? AppColors.tabBackground : AppColors.tabBackground.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTypeSelected ? AppColors.primary : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    isTypeSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isTypeSelected ? const Color(0xFF001149) : AppColors.borderLight,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  CommonText(type, fontSize: AppTextSizes.size14, fontWeight: isTypeSelected ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary),
                                ],
                              ),
                            ),
                            if (isTypeSelected && type != 'No travel fee')
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.borderLight),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 45,
                                            child: const Center(
                                              child: Text(
                                                '\$',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            decoration: const BoxDecoration(
                                              border: Border(right: BorderSide(color: AppColors.borderLight)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: widget.controller.travelFeePriceController,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [PriceInputFormatter()],
                                              decoration: const InputDecoration(
                                                hintText: 'Enter price',
                                                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: widget.controller.travelFeeDisclaimerController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Disclaimer',
                                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.borderLight),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.borderLight),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      child: const CommonText('Cancel', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      backgroundColor: const Color(0xFF001149),
                      onPressed: () {
                        widget.controller.saveFarrierTravelConfig(category);
                        if (widget.controller.tempSelectedFeeType.value != 'No travel fee') {
                          if (!widget.controller.selectedTravel.contains(category)) {
                            widget.controller.selectedTravel.add(category);
                          }
                        } else {
                          widget.controller.selectedTravel.remove(category);
                        }
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonText('Select Image Source', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const CommonText('Gallery'),
              onTap: () {
                widget.controller.addServicePhoto('Farrier');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showLocationBottomSheet({
    required String title,
    required List<Map<String, dynamic>> options,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  return ListTile(
                    title: CommonText(item['name'] ?? ''),
                    onTap: () {
                      onSelected(item);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              color: Colors.red,
              fontSize: AppTextSizes.size14,
            ),
        ],
      ),
    );
  }
}
