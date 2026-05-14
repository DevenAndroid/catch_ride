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
        _buildExperienceHighlights(),
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
          Obx(() {
            final _ = widget.controller.selectedCountryCode.value;
            return CommonDropdown(
              value: widget.controller.countryController.text,
              hint: 'Select Country',
              options: widget.controller.countries,
              onSelected: (val) => widget.controller.onCountrySelected(val),
            );
          }),
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
      'Local Only',
      'Regional',
      'Nationwide',
      'International',
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
                  final isSelected = widget.controller.selectedTravelData.containsKey(opt);
                  final details = widget.controller.selectedTravelData[opt];

                  String? summary;
                  if (isSelected && details != null) {
                    summary = details['feeType'] ??'No travel fee';

                    print("adsfasddf::::$summary");
                    if (details['price'].toString().isNotEmpty) {
                      summary = '$summary: \$${details['price']}';
                    }
                  }

                  return _buildCheckItem(
                    title: opt,
                    isSelected: isSelected,
                    subTitle: summary,
                    onTap: () {
                      if (isSelected) {
                        widget.controller.selectedTravelData.remove(opt);
                        widget.controller.selectedTravel.remove(opt);
                      } else {
                        _showTravelFeeBottomSheet(context, opt);
                      }
                    },
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
              return _buildRadioItem(
                title: opt,
                isSelected: widget.controller.farrierInsuranceStatus.value == opt,
                onTap: () => widget.controller.farrierInsuranceStatus.value = opt,
              );
            }).toList(),
          )),
          const SizedBox(height: 16),
          Obx(() {
            if (widget.controller.farrierInsuranceStatus.value == 'Carries Insurance') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Current Insurance Document'),
                  if (widget.controller.farrierInsuranceFile.value == null && 
                      widget.controller.farrierExistingInsuranceUrl.value == null)
                    _buildUploadBox(onTap: widget.controller.pickFarrierInsuranceDoc)
                  else
                    _buildFileItem(
                      file: widget.controller.farrierInsuranceFile.value,
                      url: widget.controller.farrierExistingInsuranceUrl.value,
                      fileName: widget.controller.farrierInsuranceFileName.value,
                      onRemove: () {
                        widget.controller.farrierInsuranceFile.value = null;
                        widget.controller.farrierExistingInsuranceUrl.value = null;
                        widget.controller.farrierInsuranceFileName.value = null;
                      },
                    ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Expiration date', isRequired: true),
                  _buildDatePickerTrigger(
                    value: widget.controller.farrierInsuranceExpiry.value != null
                        ? widget.controller.farrierInsuranceExpiry.value!.toString().split(' ').first
                        : 'Select date',
                    onTap: () => widget.controller.selectFarrierInsuranceExpiry(context),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildRadioItem({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
                 color: isSelected ? AppColors.primary : AppColors.borderMedium, size: 20),
            const SizedBox(width: 12),
            CommonText(title, fontSize: AppTextSizes.size14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
            SizedBox(height: 8),
            CommonText('Tap to upload document', fontSize: 14, color: AppColors.textSecondary),
            CommonText('PDF, JPG, PNG (Max 5MB)', fontSize: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem({File? file, String? url, String? fileName, required VoidCallback onRemove}) {
    String displayFileName = fileName ?? 'Document';
    if (file != null) {
      displayFileName = file.path.split('/').last;
    } else if (url != null && (fileName == null || fileName.isEmpty)) {
      displayFileName = url.split('?').first.split('/').last;
    }
    if (displayFileName.isEmpty) displayFileName = 'Document';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: CommonText(displayFileName, fontSize: 14, maxLines: 1)),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          if (isRequired) const CommonText(' *', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildDatePickerTrigger({required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(value, fontSize: 14, color: value == 'Select date' ? Colors.grey : AppColors.textPrimary),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
          ],
        ),
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
            value: widget.controller.cancellationPresetForDropdown,
            hint: 'Select Cancellation Policy',
            onTap: () => _showPickerBottomSheet(
              title: 'Cancellation Policy',
              options: EditVendorProfileController.cancellationPresetOptions,
              onSelected: (val) {
                widget.controller.isCustomCancellation.value = false;
                widget.controller.cancellationPolicy.value = val;
              },
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => Checkbox(
                value: widget.controller.isCustomCancellation.value,
                onChanged: (val) {
                  final v = val ?? false;
                  widget.controller.isCustomCancellation.value = v;
                  if (v) widget.controller.cancellationPolicy.value = null;
                },
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

  void _showTravelFeeBottomSheet(BuildContext context, String option) {
    final existing = widget.controller.selectedTravelData[option] ?? {
      'feeType': 'No travel fee',
      'price': '',
      'disclaimer': '',
    };

    final RxString selectedFeeType = (existing['feeType'] as String).obs;
    final priceController = TextEditingController(text: existing['price']?.toString() ?? '');
    final disclaimerController = TextEditingController(text: existing['disclaimer']?.toString() ?? '');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              CommonText(option, fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),

              ...['No travel fee', 'Flat fee', 'Per-mile', 'Varies by location'].map((type) {
                return Obx(() {
                  bool isSelected = selectedFeeType.value == type;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected && type == 'Varies by location' ? const Color(0xFFF9FAFB) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? const Color(0xFF001149) : AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => selectedFeeType.value = type,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF001149) : Colors.grey),
                                const SizedBox(width: 12),
                                CommonText(type, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected && (type == 'Flat fee' || type == 'Per-mile' || type == 'Varies by location')) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                if (type != 'Varies by location')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: priceController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [PriceInputFormatter()],
                                          decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (type == 'Varies by location') ...[
                                  const SizedBox(height: 12),
                                  CommonTextField(label: '', hintText: 'Disclaimer', controller: disclaimerController, maxLines: 3),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              }).toList(),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      onPressed: () {
                        widget.controller.selectedTravelData[option] = {
                          'type': option,
                          'feeType': selectedFeeType.value,
                          'price': priceController.text,
                          'disclaimer': disclaimerController.text,
                        };
                        if (!widget.controller.selectedTravel.contains(option)) {
                          widget.controller.selectedTravel.add(option);
                        }
                        widget.controller.selectedTravelData.refresh();
                        Get.back();
                      },
                      backgroundColor: const Color(0xFF001149),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
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

  Widget _buildCheckItem({required String title, required bool isSelected, String? subTitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
              size: 20,
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
                  if (isSelected && subTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CommonText(
                        subTitle,
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
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

  Widget _buildExperienceHighlights() {
    return _buildCard(
      title: 'Experience Highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            "Share key experience, programs, or specialties you’d like clients to know",
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: widget.controller.highlightControllers.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: '',
                          hintText: 'Write here...',
                          controller: ctrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => widget.controller.removeHighlight(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.controller.addHighlight,
            child: const CommonText(
              '+ Add More',
              color: AppColors.linkBlue,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
