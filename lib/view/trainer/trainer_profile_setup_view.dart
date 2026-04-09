import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/trainer/trainer_application_submitted_view.dart';
import 'package:catch_ride/view/trainer/trainer_complete_profile_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';

class TrainerProfileSetupView extends StatefulWidget {
  const TrainerProfileSetupView({super.key});

  @override
  State<TrainerProfileSetupView> createState() =>
      _TrainerProfileSetupViewState();
}

class _TrainerProfileSetupViewState extends State<TrainerProfileSetupView> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  // References controllers
  final List<TextEditingController> _refNameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _refBusinessControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _refRelationControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  // Professional details controllers
  final TextEditingController _federationIdController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();


  bool _confirm18 = false;
  bool _agreeTerms = false;
  bool _understandPlatform = false;

  bool _useSelling = false;
  bool _useBuying = false;
  bool _useBooking = false;

  String _selectedFederation = 'USEF (United States)';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var c in _refNameControllers) {
      c.dispose();
    }
    for (var c in _refBusinessControllers) {
      c.dispose();
    }
    for (var c in _refRelationControllers) {
      c.dispose();
    }
    _federationIdController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _nameController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          onPressed: () {
            Get.back();
          },
        ),
        title: const CommonText(
          AppStrings.completeYourApplication,
          color: AppColors.textPrimary,
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        AppStrings.provideFollowingDetails,
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      _buildCurrentStep(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Obx(
                  () => CommonButton(
                    text: AppStrings.next,
                    isLoading: _authController.isLoading.value,
                    onPressed: () async {


                      // Helper for snackbars
                      void showError(String msg) {
                        Get.snackbar(
                          'Input Required',
                          msg,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }

                      // 1. Trigger Form Validation
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // 2. Additional validation for custom widgets
                      // References logic: ensuring at least 2 references are fully filled (Form handles fields, we just collect)
                      final List<Map<String, String>> references = [];
                      for (int i = 0; i < 2; i++) {
                        references.add({
                          'name': _refNameControllers[i].text.trim(),
                          'business': _refBusinessControllers[i].text.trim(),
                          'relationship': _refRelationControllers[i].text
                              .trim(),
                        });
                      }

                      // Federation selection check
                      if (_selectedFederation == 'Select Federation') {
                        showError('Please select a federation type');
                        return;
                      }

                      // Primary use Validation
                      final List<String> primaryUse = [];
                      if (_useSelling) primaryUse.add('Selling / Leasing');
                      if (_useBuying) primaryUse.add('Buying / Leasing');
                      if (_useBooking)
                        primaryUse.add('Booking Service Providers');

                      if (primaryUse.isEmpty) {
                        showError(
                          'Please select at least one choice for how you will use Catch-Ride',
                        );
                        return;
                      }

                      // Compliance Checkboxes Validation
                      if (!_confirm18 || !_agreeTerms || !_understandPlatform) {
                        showError(
                          'Please confirm all three checkboxes at the bottom',
                        );
                        return;
                      }

                      // Compilation & Submission
                      final Map<String, dynamic> applicationData = {
                        'whyJoin': AppStrings.whyJoinText,
                        'facebook': _facebookController.text.trim(),
                        'website': _websiteController.text.trim(),
                        'instagram': _instagramController.text.trim(),
                        'federationId': _federationIdController.text.trim(),
                        'federationType': _selectedFederation,
                        'primaryUse': primaryUse,
                        'name': _nameController.text.trim(),
                        'references': references,
                      };


                      await _authController.completeTrainerProfile(
                        applicationData,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return Column(
      children: [
        _buildNameCard(),
        const SizedBox(height: 16),
        _buildWhyJoinCard(),
        const SizedBox(height: 16),
        _buildSocialMediaCard(),
        const SizedBox(height: 16),
        _buildFederationInfoCard(),
        const SizedBox(height: 16),
        _buildPrimaryUseCard(),
        const SizedBox(height: 16),
        _buildReferencesCard(),
        const SizedBox(height: 24),
        _buildFooterCheckboxes(),
      ],
    );
  }

  Widget _buildNameCard() {
    return _buildCard(
      title: "Basic Information",
      child: Column(
        children: [
          CommonTextField(
            controller: _nameController,
            label: AppStrings.fullName,
            isRequired: true,
            hintText: "Enter your full name",
            validator: RequiredValidator(errorText: "Full name is required"),
          ),
        ],
      ),
    );
  }


  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildWhyJoinCard() {
    return _buildCard(
      title: AppStrings.whyJoinCommunity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const CommonText(
          AppStrings.whyJoinText,
          fontSize: AppTextSizes.size14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildReferencesCard() {
    return _buildCard(
      title: "Professional References",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            AppStrings.pleaseProvideFourReferences,
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          const SizedBox(height: 20),
          ...List.generate(2, (index) {
            // Showing 2 initially as per image, can be 4
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  "Reference ${index + 1}",
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B4444),
                ),

                const SizedBox(height: 12),
                CommonTextField(
                  controller: _refNameControllers[index],
                  label: AppStrings.fullName,
                  hintText: "Enter full name",
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _refBusinessControllers[index],
                  label: AppStrings.businessName,
                  hintText: AppStrings.enterBusinessName,
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _refRelationControllers[index],
                  label: AppStrings.relationship,
                  hintText: AppStrings.enterRelationshipName, // As per image hint
                ),
                if (index < 1) const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSocialMediaCard() {
    return _buildCard(
      title: AppStrings.socialMediaWebsite,
      child: Column(
        children: [
          CommonTextField(
            controller: _facebookController,
            label: "Facebook",
            isRequired: true,
            hintText: AppStrings.facebookcomyourpage,
            validator: MultiValidator([
              RequiredValidator(
                errorText: 'Please enter your Facebook profile link',
              ),
              Validations.facebookValidator,
            ]),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _websiteController,
            label: AppStrings.websiteUrl,
            hintText: AppStrings.httpsyourwebsitecom,
            validator: (val) => (val == null || val.isEmpty)
                ? null
                : Validations.urlValidator(val),
            prefixIcon: const Icon(
              Icons.link,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _instagramController,
            label: AppStrings.instagram,
            hintText: "@yourusername",
            validator: (val) => (val == null || val.isEmpty)
                ? null
                : Validations.instagramValidator(val),
          ),
        ],
      ),
    );
  }

  Widget _buildFederationInfoCard() {
    return _buildCard(
      title: AppStrings.federationInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.inputBackground,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFederation,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items: ['USEF (United States)', 'Other Federation']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: CommonText(
                          e,
                          fontSize: AppTextSizes.size14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedFederation = val!);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _federationIdController,
            label: AppStrings.federationIdNumber,
            hintText: AppStrings.idNumber,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        AppStrings.federationVerification,
                        fontSize: AppTextSizes.size12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(height: 4),
                      CommonText(
                        "Your federation number will be verified to ensure authenticity and maintain standards",
                        fontSize: AppTextSizes.size12,
                        color: Color(0xFF16A34A),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryUseCard() {
    return _buildCard(
      title: AppStrings.whatIsPrimaryUse,
      child: Column(
        children: [
          _buildSelectionButton(
            title: AppStrings.sellingLeasing,
            isSelected: _useSelling,
            onTap: () => setState(() => _useSelling = !_useSelling),
          ),
          const SizedBox(height: 12),
          _buildSelectionButton(
            title: AppStrings.buyingLeasing,
            isSelected: _useBuying,
            onTap: () => setState(() => _useBuying = !_useBuying),
          ),
          const SizedBox(height: 12),
          _buildSelectionButton(
            title: AppStrings.bookingServiceProviders,
            isSelected: _useBooking,
            onTap: () => setState(() => _useBooking = !_useBooking),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF000040) : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              title,
              fontSize: AppTextSizes.size14,
              color: AppColors.textPrimary,
            ),
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF000040) : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterCheckboxes() {
    return Column(
      children: [
        _buildCheckboxRow(
          value: _confirm18,
          label: AppStrings.confirm18Years,
          onChanged: (val) => setState(() => _confirm18 = val!),
        ),
        const SizedBox(height: 12),
        _buildCheckboxRow(
          value: _agreeTerms,
          label: AppStrings.agreeTerms,
          onChanged: (val) => setState(() => _agreeTerms = val!),
        ),
        const SizedBox(height: 12),
        _buildCheckboxRow(
          value: _understandPlatform,
          label: AppStrings.understandCatchRidePlatform,
          onChanged: (val) => setState(() => _understandPlatform = val!),
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required String label,
    required Function(bool?) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF16A34A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CommonText(
            label,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
