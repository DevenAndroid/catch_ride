import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/flows/vendor_main_clipping.dart';

class _ServiceConfig {
  final String label;
  bool isEnabled;
  final TextEditingController priceController;

  _ServiceConfig({required this.label})
    : isEnabled = false,
      priceController = TextEditingController();

  void dispose() {
    priceController.dispose();
  }
}

class _CustomService {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class ProfileSetupClippingScreen extends StatefulWidget {
  const ProfileSetupClippingScreen({super.key});

  @override
  State<ProfileSetupClippingScreen> createState() =>
      _ProfileSetupClippingScreenState();
}

class _ProfileSetupClippingScreenState
    extends State<ProfileSetupClippingScreen> {
  bool _hasProfilePhoto = false;
  bool _hasCoverPhoto = false;

  final _nameController = TextEditingController(text: 'Jamie Roberts');
  final _businessNameController = TextEditingController(
    text: 'JR Clipping Services',
  );
  final _homeBaseController = TextEditingController(text: 'Ocala, FL, USA');
  final _yearsExpController = TextEditingController(text: '5-9');
  final _bioController = TextEditingController();

  // Services
  final List<_ServiceConfig> _services = [
    _ServiceConfig(label: 'Full Body Clip'),
    _ServiceConfig(label: 'Hunter Clip'),
    _ServiceConfig(label: 'Trace Clip'),
    _ServiceConfig(label: 'Bib Clip'),
    _ServiceConfig(label: 'Irish Clip'),
    _ServiceConfig(label: 'Touch Ups'),
    _ServiceConfig(label: 'Add - Ons'),
    _ServiceConfig(label: 'Show clean up (Bridle/whiskers)'),
    _ServiceConfig(label: 'Bath + Clip Prep'),
  ];

  final List<_CustomService> _customServices = [];

  // Travel
  String? _travelPref;
  String? _travelFeeType;
  final _travelFeeAmountController = TextEditingController();
  final _travelFeeNotesController = TextEditingController();

  // Cancellation
  String? _cancelPolicy;
  final _customCancelController = TextEditingController();

  // Payment
  final Set<String> _paymentMethods = {};
  final _otherPaymentController = TextEditingController();

  // Experience Highlights
  final _exp1Controller = TextEditingController();
  final _exp2Controller = TextEditingController();
  final _exp3Controller = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _homeBaseController.dispose();
    _yearsExpController.dispose();
    _bioController.dispose();
    for (var s in _services) {
      s.dispose();
    }
    for (var c in _customServices) {
      c.dispose();
    }
    _travelFeeAmountController.dispose();
    _travelFeeNotesController.dispose();
    _customCancelController.dispose();
    _otherPaymentController.dispose();
    _exp1Controller.dispose();
    _exp2Controller.dispose();
    _exp3Controller.dispose();
    super.dispose();
  }

  void _submit() {
    // Validations
    if (!_hasProfilePhoto) {
      _err('Profile Photo Required', 'Please upload a profile photo.');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _err('Missing Field', 'Please provide your name.');
      return;
    }
    if (_homeBaseController.text.trim().isEmpty) {
      _err('Missing Field', 'Please provide your home base location.');
      return;
    }
    if (_yearsExpController.text.trim().isEmpty) {
      _err('Missing Field', 'Please provide years of experience.');
      return;
    }
    if (_bioController.text.trim().isEmpty) {
      _err('Missing Field', 'Please provide a short bio.');
      return;
    }

    // Check at least one service enabled
    bool hasService =
        _services.any((s) => s.isEnabled) || _customServices.isNotEmpty;
    if (!hasService) {
      _err('No Services', 'Please enable at least one service with a rate.');
      return;
    }

    if (_travelPref == null) {
      _err('Missing Field', 'Please select a travel preference.');
      return;
    }
    if (_travelFeeType == null) {
      _err('Missing Field', 'Please select a travel fee type.');
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

    // Done -> Route to Vendor Nav Frame (which drops them on Availability natively)
    Get.offAll(() => const VendorMainClippingScreen());
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
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            _banner(),

            // 1. Photos
            _sectionTitle('Profile & Branding', Icons.camera_alt_outlined),
            Row(
              children: [
                _photoBox(
                  label: 'Profile Photo *\\n(Headshot)',
                  isAdded: _hasProfilePhoto,
                  isCover: false,
                  onTap: () => setState(() => _hasProfilePhoto = true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _photoBox(
                    label: 'Cover Photo\\n(Banner)',
                    isAdded: _hasCoverPhoto,
                    isCover: true,
                    onTap: () => setState(() => _hasCoverPhoto = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Core Identity
            _sectionTitle('Personal Information', Icons.person_outline_rounded),
            CustomTextField(
              label: 'Full Name *',
              hint: '',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Business Name',
              hint: '(Optional)',
              controller: _businessNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Home Base (City, State/Province, Country) *',
              hint: '',
              controller: _homeBaseController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Years of Experience *',
              hint: '',
              controller: _yearsExpController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Short Bio *',
              hint: 'Tell clients about yourself...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // 3. Read Only from App
            _sectionTitle('Application History', Icons.history_rounded),
            _note('These details are from your application.'),
            const SizedBox(height: 12),
            _buildAttributeList('Disciplines', ['Hunter/Jumper', 'Dressage']),
            const SizedBox(height: 16),
            _buildAttributeList('Typical Horse Level', ['A/AA Circuit', 'FEI']),
            const SizedBox(height: 16),
            _buildAttributeList('General Operating Regions', [
              'Wellington',
              'Ocala',
            ]),
            const SizedBox(height: 32),

            // 4. Services + Pricing
            _sectionTitle('Services & Rates', Icons.content_cut_rounded),
            _note(
              'Toggle the services you offer and enter your starting rate.',
            ),
            const SizedBox(height: 16),
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 16),
            Text('Other Services', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._customServices.map((c) => _buildCustomServiceRow(c)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() => _customServices.add(_CustomService()));
              },
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Service',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Travel Preferences
            _sectionTitle('Travel & Logistics', Icons.commute_outlined),
            _label('Travel Preferences *'),
            ...['Local Only', 'Regional', 'Nationwide'].map(
              (t) => RadioListTile<String>(
                title: Text(t),
                value: t,
                groupValue: _travelPref,
                activeColor: AppColors.deepNavy,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _travelPref = v),
              ),
            ),
            const SizedBox(height: 16),
            _label('Travel Fee Structure *'),
            ...['Flat fee', 'Per-mile', 'Varies by location/week'].map(
              (t) => RadioListTile<String>(
                title: Text(t),
                value: t,
                groupValue: _travelFeeType,
                activeColor: AppColors.deepNavy,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _travelFeeType = v),
              ),
            ),
            if (_travelFeeType == 'Flat fee' ||
                _travelFeeType == 'Per-mile') ...[
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Amount (\$) *',
                hint: _travelFeeType == 'Flat fee' ? 'e.g. 50' : 'e.g. 1.50',
                controller: _travelFeeAmountController,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Travel Fee Notes',
              hint: 'Additional context (250-500 chars)',
              controller: _travelFeeNotesController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // 6. Cancellation + Payment
            _sectionTitle('Policies & Payment', Icons.policy_outlined),
            _label('Cancellation Policy *'),
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
                  hint: const Text('Select a policy'),
                  items:
                      [
                        'Flexible (24+ hrs)',
                        'Moderate (48+ hrs)',
                        'Strict (72+ hrs)',
                        'Custom',
                      ].map((String policy) {
                        return DropdownMenuItem<String>(
                          value: policy,
                          child: Text(policy),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => _cancelPolicy = v),
                ),
              ),
            ),
            if (_cancelPolicy == 'Custom') ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Custom Policy Details *',
                hint: '',
                controller: _customCancelController,
              ),
            ],
            const SizedBox(height: 24),
            _label('Payment Methods Accepted *'),
            ...[
              'Venmo',
              'ACH/Bank Transfer',
              'Cash',
              'Zelle',
              'Credit Card',
            ].map(
              (p) => CheckboxListTile(
                title: Text(p),
                value: _paymentMethods.contains(p),
                activeColor: AppColors.deepNavy,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _paymentMethods.add(p);
                  } else {
                    _paymentMethods.remove(p);
                  }
                }),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _paymentMethods.contains('Other'),
                  activeColor: AppColors.deepNavy,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _paymentMethods.add('Other');
                    } else {
                      _paymentMethods.remove('Other');
                    }
                  }),
                ),
                Text('Other', style: AppTextStyles.bodyMedium),
                const SizedBox(width: 12),
                if (_paymentMethods.contains('Other'))
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Specify',
                        isDense: true,
                      ),
                      controller: _otherPaymentController,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // 7. Experience Highlights
            _sectionTitle('Experience Highlights', Icons.star_border_rounded),
            _note('Add up to 3 career highlights (Optional)'),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Highlight 1',
              hint: 'e.g. Clipped Grand Prix winner at WEF',
              controller: _exp1Controller,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Highlight 2',
              hint: '',
              controller: _exp2Controller,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Highlight 3',
              hint: '',
              controller: _exp3Controller,
            ),
            const SizedBox(height: 48),

            // Submit
            CustomButton(text: 'Complete Profile Setup', onPressed: _submit),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(_ServiceConfig s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: s.isEnabled,
            activeColor: AppColors.deepNavy,
            onChanged: (v) => setState(() => s.isEnabled = v ?? false),
          ),
          Expanded(child: Text(s.label, style: AppTextStyles.bodyMedium)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: s.priceController,
              enabled: s.isEnabled,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Rate',
                isDense: true,
                filled: true,
                fillColor: s.isEnabled ? Colors.white : AppColors.grey50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServiceRow(_CustomService c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: c.nameController,
              decoration: const InputDecoration(
                hintText: 'Custom Service Name',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextField(
              controller: c.priceController,
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
            onPressed: () {
              setState(() => _customServices.remove(c));
            },
          ),
        ],
      ),
    );
  }

  // UI Helpers
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
            Icons.rocket_launch,
            color: AppColors.successGreen,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Profile Setup: Final step before your account goes live!',
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
    required bool isCover,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: isAdded
              ? AppColors.successGreen.withOpacity(0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded ? AppColors.successGreen : AppColors.grey200,
            width: isAdded ? 2 : 1,
            style: isAdded ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: isAdded
            ? const Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 32,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.deepNavy.withOpacity(0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAttributeList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
              ),
              child: Text(
                i,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
