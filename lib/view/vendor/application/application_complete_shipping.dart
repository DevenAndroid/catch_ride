import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class ApplicationCompleteShippingScreen extends StatefulWidget {
  final bool isLastForm;
  final VoidCallback onContinue;

  const ApplicationCompleteShippingScreen({
    super.key,
    required this.isLastForm,
    required this.onContinue,
  });

  @override
  State<ApplicationCompleteShippingScreen> createState() =>
      _ApplicationCompleteShippingScreenState();
}

class _ApplicationCompleteShippingScreenState
    extends State<ApplicationCompleteShippingScreen> {
  // Business Info
  final _legalBusinessNameController = TextEditingController();
  final _usdotNumberController = TextEditingController();
  bool _insuranceDocumentAttached = false; // Mock for image upload

  // Carrier Attestation
  bool _carrierAttestation = false;

  // Selections
  final Set<String> _selectedRegions = {};
  final Set<String> _selectedRigTypes = {};

  // Driver Credentials
  bool? _cdlHeld;
  final _cdlClassController = TextEditingController();
  final _cdlStateController = TextEditingController();
  final _cdlExpController = TextEditingController();

  // Operation Details
  String? _operationType;
  final _yearsExpController = TextEditingController();
  final _horseCapacityController = TextEditingController();

  // Socials
  final _instaController = TextEditingController();
  final _facebookController = TextEditingController();

  // References
  final _trainer1Name = TextEditingController();
  final _trainer1Biz = TextEditingController();
  final _trainer1Rel = TextEditingController();
  final _trainer2Name = TextEditingController();
  final _trainer2Biz = TextEditingController();
  final _trainer2Rel = TextEditingController();

  final _vendor1Name = TextEditingController();
  final _vendor1Biz = TextEditingController();
  final _vendor1Rel = TextEditingController();
  final _vendor2Name = TextEditingController();
  final _vendor2Biz = TextEditingController();
  final _vendor2Rel = TextEditingController();

  // Compliance Attestation
  bool _ackAccuracy = false;
  bool _ackProfessional = false;
  bool _ackApproval = false;
  bool _ackAge = false;

  void _submit() {
    if (_legalBusinessNameController.text.trim().isEmpty) {
      _err('Missing Field', 'Legal Business Name is required.');
      return;
    }
    if (_usdotNumberController.text.trim().isEmpty) {
      _err('Missing Field', 'USDOT Number is required.');
      return;
    }
    if (!_insuranceDocumentAttached) {
      _err('Missing Field', 'Please upload your active insurance policy.');
      return;
    }
    if (!_carrierAttestation) {
      _err('Missing Field', 'Please confirm your carrier attestation.');
      return;
    }
    if (_selectedRegions.isEmpty) {
      _err('Missing Field', 'Please select at least one service region.');
      return;
    }
    if (_selectedRigTypes.isEmpty) {
      _err('Missing Field', 'Please select at least one rig type.');
      return;
    }
    if (_cdlHeld == null) {
      _err('Missing Field', 'Please specify if you hold a CDL.');
      return;
    }
    if (_operationType == null) {
      _err('Missing Field', 'Please select your operation type.');
      return;
    }
    if (_yearsExpController.text.trim().isEmpty) {
      _err('Missing Field', 'Please enter your years of experience.');
      return;
    }
    if (_horseCapacityController.text.trim().isEmpty) {
      _err('Missing Field', 'Please enter your horse capacity range.');
      return;
    }
    if (_instaController.text.trim().isEmpty &&
        _facebookController.text.trim().isEmpty) {
      _err('Missing Field', 'At least one social media link is required.');
      return;
    }

    // References validation
    if (_trainer1Name.text.isEmpty ||
        _trainer2Name.text.isEmpty ||
        _vendor1Name.text.isEmpty ||
        _vendor2Name.text.isEmpty) {
      _err(
        'Missing References',
        'Please provide all 4 professional references.',
      );
      return;
    }

    // Compliance validation
    if (!_ackAccuracy || !_ackProfessional || !_ackApproval || !_ackAge) {
      _err('Acknowledgements', 'Please accept all compliance attestations.');
      return;
    }

    widget.onContinue();
  }

  void _err(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: AppColors.softRed,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _legalBusinessNameController.dispose();
    _usdotNumberController.dispose();
    _cdlClassController.dispose();
    _cdlStateController.dispose();
    _cdlExpController.dispose();
    _yearsExpController.dispose();
    _horseCapacityController.dispose();
    _instaController.dispose();
    _facebookController.dispose();
    _trainer1Name.dispose();
    _trainer1Biz.dispose();
    _trainer1Rel.dispose();
    _trainer2Name.dispose();
    _trainer2Biz.dispose();
    _trainer2Rel.dispose();
    _vendor1Name.dispose();
    _vendor1Biz.dispose();
    _vendor1Rel.dispose();
    _vendor2Name.dispose();
    _vendor2Biz.dispose();
    _vendor2Rel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_rounded,
                    size: 28,
                    color: AppColors.deepNavy,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'This application confirms your compliance with DOT regulations and professional horse transport standards.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 1. Business Info
            _header('Business Information', required: true),
            CustomTextField(
              label: 'Legal Business Name',
              hint: 'e.g. Cole Equine Transport LLC',
              controller: _legalBusinessNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'USDOT Number',
              hint: '1234567',
              controller: _usdotNumberController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // 2. Insurance
            _header('Insurance', required: true),
            Text(
              'Shipping vendors must carry active commercial auto insurance applicable to the transport of client-owned horses.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _insuranceDocumentAttached = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _insuranceDocumentAttached
                        ? AppColors.successGreen
                        : AppColors.grey300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _insuranceDocumentAttached
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      color: _insuranceDocumentAttached
                          ? AppColors.successGreen
                          : AppColors.grey400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _insuranceDocumentAttached
                          ? 'Policy Document Attached'
                          : 'Upload ACTIVE Insurance Policy',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _insuranceDocumentAttached
                            ? AppColors.successGreen
                            : AppColors.grey600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildAck(
              'I confirm I transport client-owned horses for compensation and am legally authorized to do so.',
              _carrierAttestation,
              (v) => setState(() => _carrierAttestation = v ?? false),
            ),
            const SizedBox(height: 32),

            // 3. Service Region
            _header('Service Region', required: true),
            ...[
              'Local',
              'Statewide',
              'Regional (e.g. North East)',
              'Nationwide',
            ].map((r) {
              return CheckboxListTile(
                title: Text(r),
                value: _selectedRegions.contains(r),
                onChanged: (v) => setState(
                  () =>
                      v! ? _selectedRegions.add(r) : _selectedRegions.remove(r),
                ),
                activeColor: AppColors.deepNavy,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 32),

            // 4. Rig Types
            _header('Rig Types Used', required: true),
            ...['Bumper pull', 'Gooseneck', 'Box truck', 'Semi'].map((r) {
              return CheckboxListTile(
                title: Text(r),
                value: _selectedRigTypes.contains(r),
                onChanged: (v) => setState(
                  () => v!
                      ? _selectedRigTypes.add(r)
                      : _selectedRigTypes.remove(r),
                ),
                activeColor: AppColors.deepNavy,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 32),

            // 5. Driver Credentials
            _header('Driver Credentials', required: true),
            const Text(
              'Do you hold a CDL?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Yes'),
                    value: true,
                    groupValue: _cdlHeld,
                    onChanged: (v) => setState(() => _cdlHeld = v),
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('No'),
                    value: false,
                    groupValue: _cdlHeld,
                    onChanged: (v) => setState(() => _cdlHeld = v),
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (_cdlHeld == true) ...[
              const SizedBox(height: 16),
              const Text(
                'CDL Class',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: ['A', 'B', 'C'].map((c) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(c),
                      value: c,
                      groupValue: _cdlClassController.text,
                      onChanged: (v) =>
                          setState(() => _cdlClassController.text = v!),
                      activeColor: AppColors.deepNavy,
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'State Issued',
                hint: 'e.g. FL',
                controller: _cdlStateController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Expiration Date',
                hint: 'MM/DD/YYYY',
                controller: _cdlExpController,
              ),
            ],
            const SizedBox(height: 32),

            // 6. Operation Type
            _header('Operation Type', required: true),
            ...[
              'Independent / Small Operation',
              'Established Shipping Company',
            ].map((opt) {
              return RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _operationType,
                onChanged: (v) => setState(() => _operationType = v),
                activeColor: AppColors.deepNavy,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 32),

            // 7. Experience & Capacity
            _header('Operation Scope', required: true),
            CustomTextField(
              label: 'Years of Experience',
              hint: 'e.g. 10',
              controller: _yearsExpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Horse Capacity Range',
              hint: 'e.g. 2-6',
              controller: _horseCapacityController,
            ),
            const SizedBox(height: 32),

            // 8. Social Media
            _header('Social Media (1 Required)', required: true),
            CustomTextField(
              label: 'Instagram Handle/URL',
              hint: '@',
              controller: _instaController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Facebook Profile/Page',
              hint: 'URL',
              controller: _facebookController,
            ),
            const SizedBox(height: 32),

            // 9. References
            _header('Professional References', required: true),
            Text(
              'Please provide four professional references (2 Trainers, 2 Vendors).',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 24),
            Text('2 Trainer References', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            _buildReferenceBlock(
              'Trainer Ref 1',
              _trainer1Name,
              _trainer1Biz,
              _trainer1Rel,
            ),
            _buildReferenceBlock(
              'Trainer Ref 2',
              _trainer2Name,
              _trainer2Biz,
              _trainer2Rel,
            ),
            const SizedBox(height: 24),
            Text('2 Vendor References', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            _buildReferenceBlock(
              'Vendor Ref 1',
              _vendor1Name,
              _vendor1Biz,
              _vendor1Rel,
            ),
            _buildReferenceBlock(
              'Vendor Ref 2',
              _vendor2Name,
              _vendor2Biz,
              _vendor2Rel,
            ),
            const SizedBox(height: 32),

            // 10. Compliance Attestation
            _header('Compliance Attestation', required: true),
            _buildAck(
              'I certify that all information provided is accurate and that I comply with applicable federal and state transportation regulations.',
              _ackAccuracy,
              (v) => setState(() => _ackAccuracy = v ?? false),
            ),
            _buildAck(
              'I understand this is a professional-only platform',
              _ackProfessional,
              (v) => setState(() => _ackProfessional = v ?? false),
            ),
            _buildAck(
              'I understand approval is not guaranteed',
              _ackApproval,
              (v) => setState(() => _ackApproval = v ?? false),
            ),
            _buildAck(
              'I confirm that I am 18 years of age or older',
              _ackAge,
              (v) => setState(() => _ackAge = v ?? false),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: widget.isLastForm
                    ? 'Submit Application'
                    : 'Next Application',
                onPressed: _submit,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _header(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy),
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.softRed,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceBlock(
    String title,
    TextEditingController name,
    TextEditingController biz,
    TextEditingController rel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(label: 'Name', hint: '', controller: name),
          const SizedBox(height: 12),
          CustomTextField(label: 'Business Name', hint: '', controller: biz),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Relationship',
            hint: 'e.g. Shipped for 3 years',
            controller: rel,
          ),
        ],
      ),
    );
  }

  Widget _buildAck(String text, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.deepNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
