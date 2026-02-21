import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/flows/vendor_main_braiding.dart';

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

class ProfileSetupBraidingScreen extends StatefulWidget {
  const ProfileSetupBraidingScreen({super.key});

  @override
  State<ProfileSetupBraidingScreen> createState() =>
      _ProfileSetupBraidingScreenState();
}

class _ProfileSetupBraidingScreenState
    extends State<ProfileSetupBraidingScreen> {
  // Bio
  final _bioController = TextEditingController(
    text:
        '12 years braiding for top hunter/jumper barns along the A-circuit. '
        'Offering running braids, button braids, and French braids for any discipline. '
        'Known for clean, consistent braids that hold all show day.',
  );

  // Services
  final List<_ServiceConfig> _services = [
    _ServiceConfig(label: 'Hunter Mane + Tail'),
    _ServiceConfig(label: 'Hunter Mane Only'),
    _ServiceConfig(label: 'Hunter Tail Only'),
    _ServiceConfig(label: 'Jumper Braids'),
    _ServiceConfig(label: 'Dressage Braids'),
    _ServiceConfig(label: 'Mane Pull / Clean Up'),
  ];

  // Travel Preferences
  final _travelOptions = [
    'Local Only',
    'Regional',
    'Nationwide',
    'International',
  ];
  String? _selectedTravel;

  // Cancellation
  final _cancelOptions = [
    'Flexible (24+ hrs)',
    'Moderate (48+ hrs)',
    'Strict (72+ hrs)',
    'Custom',
  ];
  String? _selectedCancelPolicy;
  final _customCancelController = TextEditingController();

  // Payment Methods
  final _paymentOptions = [
    'Venmo',
    'ACH/Bank Transfer',
    'Cash',
    'Zelle',
    'Credit Card',
    'Other',
  ];
  final Set<String> _selectedPayments = {};
  final _otherPaymentController = TextEditingController();

  // Experience Highlights
  final _exp1Controller = TextEditingController();
  final _exp2Controller = TextEditingController();
  final _exp3Controller = TextEditingController();

  // Notes for Trainers
  final _notesController = TextEditingController();

  bool _hasProfilePhoto = false;
  bool _hasCoverPhoto = false;

  @override
  void dispose() {
    _bioController.dispose();
    for (var s in _services) {
      s.dispose();
    }
    _customCancelController.dispose();
    _otherPaymentController.dispose();
    _exp1Controller.dispose();
    _exp2Controller.dispose();
    _exp3Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasProfilePhoto) {
      _err('Profile Photo Required', 'Please upload a profile photo.');
      return;
    }
    if (_bioController.text.trim().isEmpty) {
      _err('Bio Required', 'Please provide a short bio.');
      return;
    }
    if (_services.where((s) => s.isEnabled).isEmpty) {
      _err('Services Required', 'Please select at least one braiding service.');
      return;
    }
    // Verify enabled services have prices
    for (var s in _services) {
      if (s.isEnabled && s.priceController.text.trim().isEmpty) {
        _err('Pricing Required', 'Please provide a price for ${s.label}.');
        return;
      }
    }
    if (_selectedCancelPolicy == null) {
      _err('Policy Required', 'Please select a cancellation policy.');
      return;
    }
    if (_selectedCancelPolicy == 'Custom' &&
        _customCancelController.text.trim().isEmpty) {
      _err('Policy Definition Required', 'Please detail your custom policy.');
      return;
    }
    if (_selectedPayments.isEmpty) {
      _err('Payment Required', 'Please select at least one payment method.');
      return;
    }
    if (_selectedPayments.contains('Other') &&
        _otherPaymentController.text.trim().isEmpty) {
      _err('Payment Details', 'Please specify your "Other" payment method.');
      return;
    }

    // Done
    Get.offAll(() => const VendorMainBraidingScreen());
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
            const SizedBox(height: 28),

            // 1. Photos
            _sectionTitle('Profile & Branding', Icons.camera_alt_outlined),
            Row(
              children: [
                _photoBox(
                  label: 'Profile Photo *\n(Headshot)',
                  isAdded: _hasProfilePhoto,
                  isCover: false,
                  onTap: () => setState(() => _hasProfilePhoto = true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _photoBox(
                    label: 'Cover Photo\n(Banner)',
                    isAdded: _hasCoverPhoto,
                    isCover: true,
                    onTap: () => setState(() => _hasCoverPhoto = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 2. Bio
            _sectionTitle('Short Bio', Icons.person_outline),
            _note(
              'Your bio helps trainers understand your braiding style and experience. We pulled this from your application.',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Bio *',
              hint: 'Write about your background...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 28),

            // 3. Services & Pricing
            _sectionTitle(
              'Braiding Services + Pricing',
              Icons.content_cut_rounded,
            ),
            _note(
              'Enable the services you offer and set your base price per horse/session.',
            ),
            const SizedBox(height: 12),
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 28),

            // 4. Travel
            _sectionTitle('Travel Preferences', Icons.drive_eta_outlined),
            DropdownButtonFormField<String>(
              value: _selectedTravel,
              hint: const Text('Select Travel Preference'),
              items: _travelOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTravel = v),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 28),

            // 5. Policies
            _sectionTitle('Policies & Payments', Icons.gavel_outlined),
            _label('Cancellation Policy *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCancelPolicy,
              hint: const Text('Select Cancellation Policy'),
              items: _cancelOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCancelPolicy = v),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (_selectedCancelPolicy == 'Custom') ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Custom Policy Rules *',
                hint:
                    'e.g. 50% fee if cancelled within 24 hours of first horse.',
                controller: _customCancelController,
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 20),
            _label('Payment Methods Accepted *'),
            const SizedBox(height: 8),
            Column(
              children: _paymentOptions.map((o) {
                final isSelected = _selectedPayments.contains(o);
                return CheckboxListTile(
                  title: Text(o, style: AppTextStyles.bodyMedium),
                  value: isSelected,
                  activeColor: AppColors.deepNavy,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedPayments.add(o);
                      } else {
                        _selectedPayments.remove(o);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedPayments.contains('Other')) ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Other Payment Method *',
                hint: 'e.g. Apple Pay',
                controller: _otherPaymentController,
              ),
            ],
            const SizedBox(height: 28),

            // 6. Experience Highlights
            _sectionTitle(
              'Experience Highlights',
              Icons.workspace_premium_outlined,
            ),
            _note(
              'Optional. Highlight major circuits, finals, or notable clients you have worked with.',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Highlight 1',
              hint: 'e.g. Lead Braider for [Barn Name] at WEF 2024',
              controller: _exp1Controller,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Highlight 2',
              hint: 'e.g. Braided for 3 Maclay Finalists',
              controller: _exp2Controller,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Highlight 3',
              hint: 'e.g. Official braider for Devon Horse Show',
              controller: _exp3Controller,
            ),
            const SizedBox(height: 28),

            // 7. Notes
            _sectionTitle('Notes for Trainers', Icons.speaker_notes_outlined),
            _note(
              'Optional. Any special requests, scheduling preferences, or communication methods.',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Trainer Notes',
              hint:
                  'e.g. Text preferred. Night braiding available upon request.',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 36),

            // Done
            CustomButton(text: 'Complete Profile Setup', onPressed: _submit),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildServiceRow(_ServiceConfig s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: s.isEnabled
            ? AppColors.deepNavy.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: s.isEnabled ? AppColors.deepNavy : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(
              s.label,
              style: AppTextStyles.titleMedium.copyWith(
                color: s.isEnabled ? AppColors.deepNavy : AppColors.textPrimary,
              ),
            ),
            value: s.isEnabled,
            activeColor: AppColors.deepNavy,
            onChanged: (v) => setState(() => s.isEnabled = v),
          ),
          if (s.isEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CustomTextField(
                label: 'Price per session *',
                hint: '\$ e.g. 75',
                controller: s.priceController,
                keyboardType: TextInputType.number,
              ),
            ),
        ],
      ),
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deepNavy.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings_outlined,
            color: AppColors.deepNavy,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Braiding Profile Builder',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Set your prices, availability, and policies in one place.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.deepNavy),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
    );
  }

  Widget _note(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.grey500,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _photoBox({
    required String label,
    required bool isAdded,
    required bool isCover,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isCover ? 100 : 120,
        width: isCover ? double.infinity : 100,
        decoration: BoxDecoration(
          color: isAdded
              ? AppColors.deepNavy.withOpacity(0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded ? AppColors.deepNavy : AppColors.grey300,
            style: isAdded ? BorderStyle.solid : BorderStyle.none,
          ),
          image: isAdded
              ? const DecorationImage(
                  image: AssetImage('assets/images/home_banner.png'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: isAdded
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.successGreen,
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                      height: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
