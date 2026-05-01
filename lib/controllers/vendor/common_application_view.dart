import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/common_application_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_dropdown.dart';
import 'package:catch_ride/widgets/common_suggestion_field.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/form_utils.dart';

class CommonApplicationView extends StatelessWidget {
  const CommonApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommonApplicationController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const CommonText(
            'Application Profile',
            fontSize: AppTextSizes.size22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupedSection(
                  'Full Name',
                  isRequired: true,
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.fullNameController,
                      hintText: 'Enter your full name',
                      validator: (value) {
                         if (value == null || value.isEmpty) return "Please enter your full name";
                         return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildGroupedSection(
                  'Why Join Our Community?',
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.joinCommunityController,
                      hintText: 'Tell us about your experience, the type of horses you’ve worked with, and what kind of opportunities you’re looking for.',
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildGroupedSection(
                  'Home Base Location',
                  children: [
                    _buildSectionHeader('Country', isRequired: true),
                    Obx(() {
                      final _ = controller.selectedCountryCode.value;
                      return CommonDropdown(
                        value: controller.countryController.text,
                        hint: 'Select Country',
                        options: controller.countries,
                        onSelected: (val) => controller.onCountrySelected(val),
                        validator: (value) => (value == null || value.isEmpty) ? 'Please select country' : null,
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildSectionHeader('State/Province', isRequired: true),
                    Obx(() => CommonSuggestionField(
                      controller: controller.stateController,
                      hint: 'Select State/Province',
                      suggestions: controller.states,
                      isLoading: controller.isLoadingStates.value,
                      onSelected: (val) => controller.onStateSelected(val),
                      validator: (value) => controller.selectedState.value == null ? 'Please select state' : null,
                    )),
                    const SizedBox(height: 16),
                    _buildSectionHeader('City', isRequired: true),
                    Obx(() => CommonSuggestionField(
                      controller: controller.cityController,
                      hint: controller.selectedState.value == null
                          ? 'Select state first'
                          : 'Select city',
                      suggestions: controller.cities,
                      isLoading: controller.isLoadingCities.value,
                      onSelected: (val) => controller.onCitySelected(val),
                      validator: (value) => controller.selectedCity.value == null ? 'Please select city' : null,
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfessionalReferences(controller),
                const SizedBox(height: 24),
                _buildCheckboxes(controller),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: CommonButton(
                    text: 'Next',
                    onPressed: () {
                      if (controller.formKey.currentState?.validate() ?? false) {
                        controller.next();
                      } else {
                        FormUtility.scrollToFirstError(context);
                      }
                    },
                    height: 56,
                    backgroundColor: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              fontSize: AppTextSizes.size18,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(String title, {String? description, bool isRequired = false, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, isRequired: isRequired),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfessionalReferences(CommonApplicationController controller) {
    return _buildGroupedSection(
      'Professional References',
      description: "Provide references who can speak to your experience, professionalism, and reliability",
      children: [
        _buildReferenceInputs(controller, 1),
        const SizedBox(height: 24),
        _buildReferenceInputs(controller, 2),
      ],
    );
  }

  Widget _buildReferenceInputs(CommonApplicationController controller, int number) {
    final nameCtrl = number == 1 ? controller.ref1FullNameController : controller.ref2FullNameController;
    final busCtrl = number == 1 ? controller.ref1BusinessNameController : controller.ref2BusinessNameController;
    final relCtrl = number == 1 ? controller.ref1RelationshipController : controller.ref2RelationshipController;
    final phoneCtrl = number == 1 ? controller.ref1PhoneController : controller.ref2PhoneController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText('Trainer Reference $number', color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
        const SizedBox(height: 12),
        CommonTextField(
          label: 'Full Name',
          controller: nameCtrl,
          hintText: 'Enter Full Name',
          isRequired: number == 1,
          validator: number == 1 ? RequiredValidator(errorText: "Please enter reference full name").call : null,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          label: 'Business Name',
          controller: busCtrl,
          hintText: 'Enter Business Name',
          isRequired: number == 1,
          validator: number == 1 ? RequiredValidator(errorText: "Please enter business name").call : null,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          label: 'Relationship',
          controller: relCtrl,
          hintText: 'Enter Relationship Name',
          isRequired: number == 1,
          validator: number == 1 ? RequiredValidator(errorText: "Please enter relationship").call : null,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          label: 'Phone Number',
          controller: phoneCtrl,
          hintText: 'Enter phone number',
          keyboardType: TextInputType.phone,
          isRequired: number == 1,
          validator: number == 1 ? RequiredValidator(errorText: "Please enter phone no").call : null,
        ),
      ],
    );
  }

  Widget _buildCheckboxes(CommonApplicationController controller) {
    return Column(
      children: [
        Obx(() => _buildCheckboxTile(
          'I confirm that I am at least 18 years or older',
          controller.is18OrOlder.value,
          (val) => controller.is18OrOlder.value = val!,
        )),
        Obx(() => _buildCheckboxTile(
          'I agree to the Terms of Service and Privacy Policy',
          controller.agreeToTerms.value,
          (val) => controller.agreeToTerms.value = val!,
        )),
        Obx(() => _buildCheckboxTile(
          'I understand that my professional references may be contacted regarding my history, competence, and reliability',
          controller.confirmReferences.value,
          (val) => controller.confirmReferences.value = val!,
        )),
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: CommonText(title, fontSize: AppTextSizes.size12),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.greenColor,
    );
  }
}
