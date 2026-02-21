import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/flows/vendor_main_shipping.dart';

class ProfileSetupShippingScreen extends StatefulWidget {
  const ProfileSetupShippingScreen({super.key});

  @override
  State<ProfileSetupShippingScreen> createState() =>
      _ProfileSetupShippingScreenState();
}

class _ProfileSetupShippingScreenState
    extends State<ProfileSetupShippingScreen> {
  bool _hasProfilePhoto = false;
  bool _hasCoverPhoto = false;

  // Pre-filled from application (simulated)
  final _businessDisplayNameController = TextEditingController(
    text: 'Cole Equine Transport LLC',
  );
  final _baseLocationController = TextEditingController(text: 'Ocala, FL');

  // New Inputs
  final _bioController = TextEditingController();

  // Pricing
  bool _inquireForPricing = false;
  final _pricePerMileController = TextEditingController();

  // Cancellation Policy
  String? _cancelPolicy;
  final _customCancelController = TextEditingController();

  // Payment Methods
  final Set<String> _paymentMethods = {};
  final _otherPaymentController = TextEditingController();

  // Contact
  bool _showPhoneOnProfile = true;

  // Capabilities
  final Set<String> _selectedCapabilities = {};
  final List<String> _capabilityOptions = [
    'Long-distance transport',
    'Climate-controlled equipment',
    'GPS tracking available',
    'Team drivers available',
    'Layovers/overnight stops available',
  ];

  // Visibility
  bool _showActiveLoads = true;

  // Equipment
  final _equipmentSummaryController = TextEditingController();

  @override
  void dispose() {
    _businessDisplayNameController.dispose();
    _baseLocationController.dispose();
    _bioController.dispose();
    _pricePerMileController.dispose();
    _customCancelController.dispose();
    _otherPaymentController.dispose();
    _equipmentSummaryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasProfilePhoto) {
      _err('Photo Required', 'Please upload a professional profile photo.');
      return;
    }
    if (_bioController.text.trim().isEmpty) {
      _err('Bio Required', 'Please provide a short professional bio.');
      return;
    }
    if (!_inquireForPricing && _pricePerMileController.text.trim().isEmpty) {
      _err(
        'Pricing Required',
        'Please provide a rate per mile or select "Inquire for pricing".',
      );
      return;
    }
    if (_cancelPolicy == null) {
      _err('Policy Required', 'Please select a cancellation policy.');
      return;
    }
    if (_paymentMethods.isEmpty) {
      _err(
        'Payment Method Required',
        'Please select at least one accepted payment method.',
      );
      return;
    }

    // Success -> Mark ProfileComplete = true (simulated)
    // Redirect to VendorMainShippingScreen (Availability is index 2)
    Get.offAll(() => const VendorMainShippingScreen());
  }

  void _err(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: AppColors.softRed,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Shipping Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),

            // 1. Photos
            _sectionTitle('Branding & Photos', Icons.camera_alt_outlined),
            Row(
              children: [
                _photoBox(
                  label: 'Profile Photo *',
                  isAdded: _hasProfilePhoto,
                  onTap: () => setState(() => _hasProfilePhoto = true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _photoBox(
                    label: 'Cover Photo (Optional)',
                    isAdded: _hasCoverPhoto,
                    onTap: () => setState(() => _hasCoverPhoto = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Profile Details
            _sectionTitle('Profile Details', Icons.person_outline),
            CustomTextField(
              label: 'Business Display Name *',
              controller: _businessDisplayNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Base Location (City, State) *',
              controller: _baseLocationController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio / About *',
              hint:
                  'Describe your transport experience, safety track record...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // 3. Pricing
            _sectionTitle('Pricing', Icons.payments_outlined),
            CheckboxListTile(
              title: const Text('Inquire for pricing'),
              value: _inquireForPricing,
              onChanged: (v) => setState(() {
                _inquireForPricing = v ?? false;
                if (_inquireForPricing) _pricePerMileController.clear();
              }),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (!_inquireForPricing) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _pricePerMileController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '\$ ',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'per mile fully loaded',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),

            // 4. Cancellation Policy
            _sectionTitle('Cancellation Policy', Icons.policy_outlined),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _cancelPolicy,
                  isExpanded: true,
                  hint: const Text('Select policy'),
                  items:
                      [
                            'Flexible (24+ hrs)',
                            'Moderate (48+ hrs)',
                            'Strict (72+ hrs)',
                            'Custom',
                          ]
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _cancelPolicy = v),
                ),
              ),
            ),
            if (_cancelPolicy == 'Custom') ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Custom Cancellation Policy *',
                controller: _customCancelController,
                hint: 'e.g. 50% fee within 48 hours...',
              ),
            ],
            const SizedBox(height: 32),

            // 5. Payment Methods
            _sectionTitle(
              'Accepted Payment Methods',
              Icons.credit_card_outlined,
            ),
            ...[
              'Venmo',
              'ACH/Bank Transfer',
              'Cash',
              'Zelle',
              'Credit Card',
            ].map((p) => _checkTile(p, _paymentMethods)),
            _checkOtherItem('Other', _paymentMethods, _otherPaymentController),
            const SizedBox(height: 32),

            // 6. Contact & Visibility
            _sectionTitle('Contact & Visibility', Icons.visibility_outlined),
            SwitchListTile(
              title: const Text('Show phone number on profile'),
              value: _showPhoneOnProfile,
              onChanged: (v) => setState(() => _showPhoneOnProfile = v),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Show my active loads on my public profile'),
              value: _showActiveLoads,
              onChanged: (v) => setState(() => _showActiveLoads = v),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // 7. Capabilities
            _sectionTitle('Capabilities', Icons.stars_outlined),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _capabilityOptions.map((cap) {
                final isSelected = _selectedCapabilities.contains(cap);
                return FilterChip(
                  label: Text(cap),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCapabilities.add(cap);
                      } else {
                        _selectedCapabilities.remove(cap);
                      }
                    });
                  },
                  selectedColor: AppColors.deepNavy.withOpacity(0.1),
                  checkmarkColor: AppColors.deepNavy,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.deepNavy : AppColors.grey700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 8. Equipment Summary
            _sectionTitle('Equipment Summary', Icons.build_circle_outlined),
            CustomTextField(
              label: 'Equipment Summary *',
              hint:
                  'e.g. Box trucks + goosenecks, climate controlled when needed',
              controller: _equipmentSummaryController,
              maxLines: 2,
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Complete Profile Setup', onPressed: _submit),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _photoBox({
    required String label,
    required bool isAdded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: isAdded
              ? AppColors.successGreen.withOpacity(0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded ? AppColors.successGreen : AppColors.grey200,
            width: 2,
          ),
        ),
        child: isAdded
            ? const Icon(Icons.check_circle, color: AppColors.successGreen)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _checkTile(String label, Set<String> selectionSet) {
    return CheckboxListTile(
      title: Text(label),
      value: selectionSet.contains(label),
      onChanged: (v) => setState(
        () => v! ? selectionSet.add(label) : selectionSet.remove(label),
      ),
      activeColor: AppColors.deepNavy,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _checkOtherItem(
    String label,
    Set<String> selectionSet,
    TextEditingController ctrl,
  ) {
    bool isSelected = selectionSet.contains(label);
    return Column(
      children: [
        _checkTile(label, selectionSet),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: CustomTextField(label: 'Specify', controller: ctrl),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mutedGold, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.deepNavy,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.successGreen,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Standards Accepted! Complete your profile details to begin receiving shipping requests.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
