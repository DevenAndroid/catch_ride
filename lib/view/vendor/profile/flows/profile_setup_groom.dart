import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/flows/vendor_main_groom.dart';

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

class ProfileSetupGroomScreen extends StatefulWidget {
  const ProfileSetupGroomScreen({super.key});

  @override
  State<ProfileSetupGroomScreen> createState() =>
      _ProfileSetupGroomScreenState();
}

class _ProfileSetupGroomScreenState extends State<ProfileSetupGroomScreen> {
  bool _hasProfilePhoto = false;
  bool _hasCoverPhoto = false;

  // Pre-filled from application (simulated)
  final _nameController = TextEditingController(text: 'Alex Thompson');
  final _businessNameController = TextEditingController(
    text: ' Thompson Show Grooms',
  );
  final _homeBaseController = TextEditingController(text: 'Lexington, KY, USA');
  final _yearsExpController = TextEditingController(text: '5-9');

  // New Inputs
  final _bioController = TextEditingController();
  final _exp1Controller = TextEditingController();
  final _exp2Controller = TextEditingController();
  final _exp3Controller = TextEditingController();

  // Services - Core
  final List<_ServiceConfig> _coreServices = [
    _ServiceConfig(label: 'Stall Upkeep + Daily Care'),
    _ServiceConfig(label: 'Grooming + Turnout'),
    _ServiceConfig(label: 'Tacking + Untacking'),
    _ServiceConfig(label: 'Show Prep (non braiding)'),
    _ServiceConfig(label: 'Wrapping + Bandaging'),
    _ServiceConfig(label: 'Show + Barn Support'),
  ];

  // Services - Jobs
  final List<_ServiceConfig> _jobServices = [
    _ServiceConfig(label: 'Show Grooming'),
    _ServiceConfig(label: 'Fill-In Daily Grooming Support'),
    _ServiceConfig(label: 'Weekly Jobs'),
    _ServiceConfig(label: 'Monthly Jobs'),
    _ServiceConfig(label: 'Seasonal Jobs'),
    _ServiceConfig(label: 'Travel Jobs'),
  ];

  // Horse Handling
  final List<_ServiceConfig> _handlingServices = [
    _ServiceConfig(label: 'Lunging'),
    _ServiceConfig(label: 'Flat Riding (exercise only)'),
  ];

  // Additional Skills
  final List<_ServiceConfig> _additionalSkills = [
    _ServiceConfig(label: 'Braiding'),
    _ServiceConfig(label: 'Clipping'),
  ];

  // Travel Preferences
  String? _travelPref;

  // Rates
  final List<_RateInput> _rates = [
    _RateInput(label: 'Daily'),
    _RateInput(label: 'Weekly'),
    _RateInput(label: 'Monthly'),
  ];
  bool _ratesVaryByShow = false;

  // Cancellation
  String? _cancelPolicy;
  final _customCancelController = TextEditingController();

  // Payment
  final Set<String> _paymentMethods = {};
  final _otherPaymentController = TextEditingController();

  // Data from Application (Display Only)
  final List<String> _applicationDisciplines = ['Hunter/Jumper', 'Dressage'];
  final List<String> _applicationLevels = ['FEI', 'A/AA Circuit'];
  final List<String> _applicationRegions = ['Lexington', 'Wellington', 'Aiken'];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _homeBaseController.dispose();
    _yearsExpController.dispose();
    _bioController.dispose();
    _exp1Controller.dispose();
    _exp2Controller.dispose();
    _exp3Controller.dispose();
    _customCancelController.dispose();
    _otherPaymentController.dispose();
    for (var s in _coreServices) s.dispose();
    for (var s in _jobServices) s.dispose();
    for (var s in _handlingServices) s.dispose();
    for (var s in _additionalSkills) s.dispose();
    for (var r in _rates) r.controller.dispose();
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
    if (_travelPref == null) {
      _err(
        'Travel Preference Required',
        'Please select how far you are willing to travel.',
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

    // Success -> Navigate to VendorMainGroomScreen (which centers on Availability)
    Get.offAll(() => const VendorMainGroomScreen());
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
        title: const Text('Complete Your Groom Profile'),
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

            // 2. Personal Info
            _sectionTitle('Personal Details', Icons.person_outline),
            CustomTextField(label: 'Full Name *', controller: _nameController),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Business Name (Optional)',
              controller: _businessNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Home Base *',
              controller: _homeBaseController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Years Experience *',
              controller: _yearsExpController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Short Bio *',
              hint: 'Describe your grooming experience and specialty...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // 3. Application Data (Badges)
            _sectionTitle('Area of Expertise', Icons.star_outline),
            _note('Pulled from your application'),
            const SizedBox(height: 12),
            _label('Disciplines'),
            _buildBadgeWrap(_applicationDisciplines),
            const SizedBox(height: 12),
            _label('Typical Horse Levels'),
            _buildBadgeWrap(_applicationLevels),
            const SizedBox(height: 32),

            // 4. Services
            _sectionTitle(
              'Core Grooming Services',
              Icons.cleaning_services_outlined,
            ),
            ..._coreServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Grooming Jobs', Icons.assignment_outlined),
            ..._jobServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Horse Handling & Riding', Icons.pets_outlined),
            ..._handlingServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Additional Skills', Icons.auto_awesome_outlined),
            ..._additionalSkills.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 32),

            // 5. Travel Preferences
            _sectionTitle('Travel Preferences', Icons.map_outlined),
            ...['Local Only', 'Regional', 'Nationwide', 'International'].map(
              (t) => _radioTile(
                t,
                _travelPref,
                (v) => setState(() => _travelPref = v),
              ),
            ),
            const SizedBox(height: 32),

            // 6. Rates
            _sectionTitle('Rates & Pricing', Icons.payments_outlined),
            ..._rates.map((r) => _buildRateInput(r)),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Rates vary by show/week'),
              value: _ratesVaryByShow,
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _ratesVaryByShow = v ?? false),
            ),
            const SizedBox(height: 32),

            // 7. Cancellation Policy
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
              ),
            ],
            const SizedBox(height: 32),

            // 8. Payment Methods
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

            // 9. Operating Regions
            _sectionTitle('Operating Regions', Icons.location_on_outlined),
            _note('Pulled from your application'),
            const SizedBox(height: 12),
            _buildBadgeWrap(
              _applicationRegions,
              color: AppColors.mutedGold.withOpacity(0.1),
            ),
            const SizedBox(height: 32),

            // 10. Highlights
            _sectionTitle('Experience Highlights', Icons.emoji_events_outlined),
            _note('Add up to 3 career highlights (Optional)'),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Highlight 1',
              controller: _exp1Controller,
              hint: 'e.g., Head groom for Olympian...',
            ),
            const SizedBox(height: 12),
            CustomTextField(label: 'Highlight 2', controller: _exp2Controller),
            const SizedBox(height: 12),
            CustomTextField(label: 'Highlight 3', controller: _exp3Controller),

            const SizedBox(height: 48),
            CustomButton(text: 'Complete Profile Setup', onPressed: _submit),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---
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

  Widget _buildBadgeWrap(List<String> items, {Color? color}) {
    return Wrap(
      spacing: 8,
      children: items
          .map(
            (i) => Chip(
              label: Text(
                i,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              backgroundColor: color ?? AppColors.deepNavy.withOpacity(0.05),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildServiceCheckbox(_ServiceConfig s) {
    return CheckboxListTile(
      title: Text(s.label),
      value: s.isEnabled,
      activeColor: AppColors.deepNavy,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => setState(() => s.isEnabled = v ?? false),
    );
  }

  Widget _buildRateInput(_RateInput r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(r.label, style: AppTextStyles.bodyLarge)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextField(
              controller: r.controller,
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
    );
  }

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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.labelLarge),
  );
  Widget _note(String text) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
  );

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
              'Standards Accepted! Complete your profile detail to begin receiving grooming requests.',
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

class _RateInput {
  final String label;
  final TextEditingController controller = TextEditingController();
  _RateInput({required this.label});
}
