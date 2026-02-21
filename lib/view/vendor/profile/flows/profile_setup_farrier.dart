import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

import 'package:catch_ride/view/vendor/flows/vendor_main_farrier.dart';

class _ServiceConfig {
  final String label;
  bool isEnabled;
  final TextEditingController priceController;
  final TextEditingController notesController;

  _ServiceConfig({required this.label})
    : isEnabled = false,
      priceController = TextEditingController(),
      notesController = TextEditingController();

  void dispose() {
    priceController.dispose();
    notesController.dispose();
  }
}

class _CustomItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class ProfileSetupFarrierScreen extends StatefulWidget {
  const ProfileSetupFarrierScreen({super.key});

  @override
  State<ProfileSetupFarrierScreen> createState() =>
      _ProfileSetupFarrierScreenState();
}

class _ProfileSetupFarrierScreenState extends State<ProfileSetupFarrierScreen> {
  bool _hasProfilePhoto = false;
  bool _hasCoverPhoto = false;

  final _nameController = TextEditingController(text: 'Sam Smith');
  final _businessNameController = TextEditingController(
    text: 'Smith Farrier Services',
  );
  final _homeBaseController = TextEditingController(text: 'Ocala, FL, USA');
  final _yearsExpController = TextEditingController(text: '10+');
  final _bioController = TextEditingController();

  // Services
  final List<_ServiceConfig> _services = [
    _ServiceConfig(label: 'Trimming'),
    _ServiceConfig(label: 'Front Shoes'),
    _ServiceConfig(label: 'Hind Shoes'),
    _ServiceConfig(label: 'Full Set'),
    _ServiceConfig(label: 'Corrective / Therapeutic Work'),
    _ServiceConfig(label: 'Glue-on Shoes'),
    _ServiceConfig(label: 'Specialty Shoes (bar shoes, pads, wedges, etc.)'),
    _ServiceConfig(label: 'Barefoot / Natural Trim Specialist'),
  ];
  final List<_CustomItem> _customServices = [];

  // Add-Ons
  final List<_ServiceConfig> _addOns = [_ServiceConfig(label: 'Aluminum')];
  final List<_CustomItem> _customAddOns = [];

  // Travel
  String? _travelPref;
  String? _travelFeeType;
  final _travelFeeAmountController = TextEditingController();
  final _travelFeeNotesController = TextEditingController();

  // Client Intake
  String? _newClientPolicy;
  final _minHorsesController = TextEditingController();
  bool _emergencySupport = false;
  final _notesForTrainersController = TextEditingController();

  // Highlights
  final _exp1Controller = TextEditingController();
  final _exp2Controller = TextEditingController();
  final _exp3Controller = TextEditingController();

  // Cancellation
  String? _cancelPolicy;
  final _customCancelController = TextEditingController();

  // Payment
  final Set<String> _paymentMethods = {};
  final _otherPaymentController = TextEditingController();

  // Compliance
  String? _insuranceStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _homeBaseController.dispose();
    _yearsExpController.dispose();
    _bioController.dispose();
    for (var s in _services) s.dispose();
    for (var c in _customServices) c.dispose();
    for (var a in _addOns) a.dispose();
    for (var c in _customAddOns) c.dispose();
    _travelFeeAmountController.dispose();
    _travelFeeNotesController.dispose();
    _minHorsesController.dispose();
    _notesForTrainersController.dispose();
    _exp1Controller.dispose();
    _exp2Controller.dispose();
    _exp3Controller.dispose();
    _customCancelController.dispose();
    _otherPaymentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasProfilePhoto) {
      _err('Profile Photo Required', 'Please upload a profile photo.');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _homeBaseController.text.trim().isEmpty) {
      _err(
        'Missing Field',
        'Please complete the required personal information.',
      );
      return;
    }

    bool hasService =
        _services.any((s) => s.isEnabled) || _customServices.isNotEmpty;
    if (!hasService) {
      _err('No Services', 'Please enable at least one service offered.');
      return;
    }

    if (_travelPref == null) {
      _err('Missing Field', 'Please select a travel preference.');
      return;
    }

    if (_newClientPolicy == null) {
      _err('Missing Field', 'Please select a new client policy.');
      return;
    }

    if (_cancelPolicy == null) {
      _err('Missing Field', 'Please select a cancellation policy.');
      return;
    }

    if (_paymentMethods.isEmpty) {
      _err(
        'Missing Field',
        'Please select at least one accepted payment method.',
      );
      return;
    }

    // Success
    Get.offAll(() => const VendorMainFarrierScreen());
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Farrier Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),

            // 1. Photos
            _sectionTitle('Profile & Branding', Icons.camera_alt_outlined),
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

            // 2. Personal Info (Core Identity)
            _sectionTitle('Personal Information', Icons.person_outline_rounded),
            CustomTextField(label: 'Full Name *', controller: _nameController),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Business Name',
              hint: '(Optional)',
              controller: _businessNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Home Base *',
              hint: 'City, State, Country',
              controller: _homeBaseController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Years of Experience *',
              controller: _yearsExpController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Short Bio',
              hint: 'Professional overview...',
              controller: _bioController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // 3. Services Offered
            _sectionTitle('Services Offered', Icons.handyman_outlined),
            _note('Enable services and enter pricing/notes.'),
            const SizedBox(height: 16),
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 16),
            Text('Custom Services', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._customServices.map((c) => _buildCustomRow(c, _customServices)),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _customServices.add(_CustomItem())),
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Service',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
            const SizedBox(height: 32),

            // 4. Add-Ons
            _sectionTitle('Add-Ons', Icons.add_circle_outline),
            ..._addOns.map((a) => _buildServiceRow(a)),
            const SizedBox(height: 16),
            Text('Custom Add-Ons', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._customAddOns.map((c) => _buildCustomRow(c, _customAddOns)),
            TextButton.icon(
              onPressed: () => setState(() => _customAddOns.add(_CustomItem())),
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Add-On',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Travel Preferences
            _sectionTitle('Travel & Logistics', Icons.commute_outlined),
            _label('Travel Preferences *'),
            ...['Local Only', 'Regional', 'Nationwide'].map(
              (t) => _radioTile(
                t,
                _travelPref,
                (v) => setState(() => _travelPref = v),
              ),
            ),
            const SizedBox(height: 16),
            _label('Travel Fee Structure (Optional)'),
            ...[
              'Included Locally',
              'Flat Travel Fee',
              'Per-mile fee',
              'Varies by location/week',
            ].map(
              (t) => _radioTile(
                t,
                _travelFeeType,
                (v) => setState(() => _travelFeeType = v),
              ),
            ),
            if (_travelFeeType == 'Flat Travel Fee' ||
                _travelFeeType == 'Per-mile fee') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 120,
                child: CustomTextField(
                  label: 'Amount (\$) *',
                  hint: _travelFeeType == 'Flat Travel Fee'
                      ? 'e.g. 50'
                      : 'e.g. 1.50',
                  controller: _travelFeeAmountController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Travel Notes',
              hint: 'Pricing or distance context...',
              controller: _travelFeeNotesController,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // 6. Client Intake + Scheduling
            _sectionTitle(
              'Client Intake & Scheduling',
              Icons.event_available_outlined,
            ),
            _label('New Client Policy *'),
            ...[
              'Accepting new clients',
              'Limited availability',
              'Referral-only',
              'Not accepting new clients',
            ].map(
              (p) => _radioTile(
                p,
                _newClientPolicy,
                (v) => setState(() => _newClientPolicy = v),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Minimum horses per stop',
              hint: 'e.g. 2',
              controller: _minHorsesController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Emergency Support Offered?'),
              value: _emergencySupport,
              onChanged: (v) => setState(() => _emergencySupport = v),
              activeColor: AppColors.successGreen,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Notes for Trainers *',
              hint: '250-500 chars...',
              controller: _notesForTrainersController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // 7. Experience Highlights
            _sectionTitle('Experience Highlights', Icons.star_border_rounded),
            _note('Add up to 3 career highlights (Optional)'),
            const SizedBox(height: 12),
            CustomTextField(label: 'Highlight 1', controller: _exp1Controller),
            const SizedBox(height: 12),
            CustomTextField(label: 'Highlight 2', controller: _exp2Controller),
            const SizedBox(height: 12),
            CustomTextField(label: 'Highlight 3', controller: _exp3Controller),
            const SizedBox(height: 32),

            // 8. Cancellation Policy
            _sectionTitle('Cancellation Policy', Icons.policy_outlined),
            _label('Policy Selection *'),
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
                label: 'Custom Policy Text *',
                controller: _customCancelController,
              ),
            ],
            const SizedBox(height: 32),

            // 9. Payment Methods
            _sectionTitle('Accepted Payments', Icons.payment_outlined),
            ...[
              'Venmo',
              'ACH/Bank Transfer',
              'Cash',
              'Zelle',
              'Credit Card',
            ].map((p) => _checkTile(p, _paymentMethods)),
            _checkOtherItem('Other', _paymentMethods, _otherPaymentController),
            const SizedBox(height: 32),

            // 10. Compliance
            _sectionTitle('Compliance', Icons.verified_user_outlined),
            _label('Insurance Status'),
            ...[
              'Carries Insurance',
              'Insurance available upon request',
              'Not currently insured',
            ].map(
              (i) => _radioTile(
                i,
                _insuranceStatus,
                (v) => setState(() => _insuranceStatus = v),
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Complete Profile Setup', onPressed: _submit),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(_ServiceConfig s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: s.isEnabled,
                activeColor: AppColors.deepNavy,
                onChanged: (v) => setState(() => s.isEnabled = v ?? false),
              ),
              Expanded(child: Text(s.label, style: AppTextStyles.titleMedium)),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: s.priceController,
                  enabled: s.isEnabled,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    hintText: 'Rate',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (s.isEnabled) ...[
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Optional Notes',
              hint: 'Context for this service...',
              controller: s.notesController,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomRow(_CustomItem item, List<_CustomItem> list) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: item.nameController,
              decoration: const InputDecoration(
                hintText: 'Item Name',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextField(
              controller: item.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: 'Rate',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.softRed,
            ),
            onPressed: () => setState(() => list.remove(item)),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _radioTile(String label, String? group, Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: group,
      activeColor: AppColors.deepNavy,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }

  Widget _checkTile(String label, Set<String> selectionSet) {
    return CheckboxListTile(
      title: Text(label),
      value: selectionSet.contains(label),
      activeColor: AppColors.deepNavy,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => setState(() {
        if (v == true)
          selectionSet.add(label);
        else
          selectionSet.remove(label);
      }),
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
        CheckboxListTile(
          title: Text(label),
          value: isSelected,
          activeColor: AppColors.deepNavy,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() {
            if (v == true)
              selectionSet.add(label);
            else
              selectionSet.remove(label);
          }),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: CustomTextField(label: 'Specify', controller: ctrl),
          ),
      ],
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
              'Approved! Complete your professional profile to showcase your scope and start receiving requests.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.labelLarge),
  );
  Widget _note(String text) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
  );

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
}
