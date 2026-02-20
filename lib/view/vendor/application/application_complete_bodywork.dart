// application_complete_bodywork.dart
// ApplicationCompleteBodywork — Full Bodywork Specialist application form
// Triggered when "Bodywork Specialist" is selected during vendor application.
// Submits → VendorApplicationSubmitScreen

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/application/vendor_application_submit_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class ApplicationCompleteBodyworkScreen extends StatefulWidget {
  /// True when this form is the only/last form in the flow.
  /// False when additional service forms follow.
  final bool isLastForm;
  final VoidCallback? onContinue;

  const ApplicationCompleteBodyworkScreen({
    super.key,
    this.isLastForm = true,
    this.onContinue,
  });

  @override
  State<ApplicationCompleteBodyworkScreen> createState() =>
      _ApplicationCompleteBodyworkScreenState();
}

class _ApplicationCompleteBodyworkScreenState
    extends State<ApplicationCompleteBodyworkScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _certTypeController = TextEditingController();
  final _certYearsController = TextEditingController();
  final _otherDisciplineController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();

  // Trainer references
  final _t1NameController = TextEditingController();
  final _t1BusinessController = TextEditingController();
  final _t1RelController = TextEditingController();
  final _t2NameController = TextEditingController();
  final _t2BusinessController = TextEditingController();
  final _t2RelController = TextEditingController();

  // Vendor references
  final _v1NameController = TextEditingController();
  final _v1BusinessController = TextEditingController();
  final _v1RelController = TextEditingController();
  final _v2NameController = TextEditingController();
  final _v2BusinessController = TextEditingController();
  final _v2RelController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? _experience;

  final _modalities = [
    'Sports Massage',
    'Myofascial Release',
    'PEMF',
    'Chiropractic',
    'Acupuncture',
    'Laser Therapy',
    'Red Light',
  ];
  final Set<String> _selectedModalities = {};

  final _disciplines = ['Hunters / Jumpers', 'Dressage', 'Eventing', 'Other'];
  final Set<String> _selectedDisciplines = {};

  final _experienceTypes = ['Performance Horses', 'Rehab Cases'];
  final Set<String> _selectedExpTypes = {};

  final _horseLevels = ['Young Horses', 'A / AA Circuit', 'FEI', 'Grand Prix'];
  final Set<String> _selectedHorseLevels = {};

  final _regions = [
    'Wellington',
    'Ocala',
    'Gulf Coast Florida',
    'Aiken',
    'Tryon',
    'Lexington',
    'Northeast',
    'Mid-Atlantic (VA/MD/PA)',
    'Southern California',
    'East Coast Canada',
    'Pacific Northwest',
    'Midwest',
    'Southwest',
    'Travels / Nationwide',
  ];
  final Set<String> _selectedRegions = {};

  bool _hasInsurance = false;
  bool _trainerPresenceRequired = false;
  bool _scopeAck = false;
  bool _refsAware = false;
  bool _insuranceConfirm = false;
  bool _professionalPlatform = false;
  bool _approvalNotGuaranteed = false;
  bool _ageConfirm = false;

  @override
  void dispose() {
    for (final c in [
      _cityController,
      _stateController,
      _countryController,
      _certTypeController,
      _certYearsController,
      _otherDisciplineController,
      _instagramController,
      _facebookController,
      _t1NameController,
      _t1BusinessController,
      _t1RelController,
      _t2NameController,
      _t2BusinessController,
      _t2RelController,
      _v1NameController,
      _v1BusinessController,
      _v1RelController,
      _v2NameController,
      _v2BusinessController,
      _v2RelController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    // Required field validation
    if (_cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty) {
      _err('Home Base Required', 'Please enter your city and state.');
      return;
    }
    if (_experience == null) {
      _err('Experience Required', 'Please select your years of experience.');
      return;
    }
    if (_selectedModalities.isEmpty) {
      _err('Modality Required', 'Please select at least one modality.');
      return;
    }
    if (_selectedHorseLevels.isEmpty) {
      _err(
        'Horse Level Required',
        'Please select at least one typical horse level.',
      );
      return;
    }
    if (_selectedRegions.isEmpty) {
      _err('Region Required', 'Please select at least one region.');
      return;
    }
    if (_instagramController.text.trim().isEmpty &&
        _facebookController.text.trim().isEmpty) {
      _err(
        'Social Media Required',
        'Please provide at least one social media profile.',
      );
      return;
    }
    if (_t1NameController.text.trim().isEmpty ||
        _t2NameController.text.trim().isEmpty ||
        _v1NameController.text.trim().isEmpty ||
        _v2NameController.text.trim().isEmpty) {
      _err('References Required', 'Please provide all 4 references.');
      return;
    }
    if (!_refsAware ||
        !_insuranceConfirm ||
        !_professionalPlatform ||
        !_approvalNotGuaranteed ||
        !_ageConfirm ||
        !_scopeAck) {
      _err(
        'Acknowledgments Required',
        'Please check all required acknowledgments to continue.',
      );
      return;
    }

    if (widget.isLastForm) {
      Get.to(() => const VendorApplicationSubmitScreen());
    } else {
      widget.onContinue?.call();
    }
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
        title: const Text('Bodywork Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Banner ─────────────────────────────────────────────
            _banner(),
            const SizedBox(height: 28),

            // ── 1. Home Base ──────────────────────────────────────────────
            _section('Home Base', Icons.home_outlined, required: true),
            CustomTextField(
              label: 'City *',
              hint: 'e.g. Wellington',
              controller: _cityController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'State / Province *',
                    hint: 'e.g. FL',
                    controller: _stateController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Country',
                    hint: 'e.g. USA',
                    controller: _countryController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── 2. Experience ─────────────────────────────────────────────
            _section('Experience', Icons.work_history_outlined, required: true),
            _label('Years of Professional Experience *'),
            const SizedBox(height: 8),
            _dropdownField(
              value: _experience,
              hint: 'Select years of experience',
              items: ['0 – 1', '2 – 4', '5 – 9', '10+'],
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 28),

            // ── 3. Services & Modality ────────────────────────────────────
            _section('Services & Modality', Icons.spa_rounded),
            _label('Modalities Offered (select all that apply) *'),
            const SizedBox(height: 8),
            _legalNote(
              'Chiropractic, Acupuncture, and Laser Therapy are listed where legally permitted and performed in accordance with veterinary referral or oversight requirements.',
            ),
            const SizedBox(height: 12),
            _multiCheckGrid(_modalities, _selectedModalities, columns: 1),
            const SizedBox(height: 16),

            _label('Certification / Training'),
            const SizedBox(height: 8),
            _note(
              'Formal certification is preferred but not required depending on modality and region.',
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Type of Certification or Trainer',
              hint: 'e.g. IICPCT Certified, trained under Dr. Jane Doe',
              controller: _certTypeController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Years of Practice in Listed Modalities',
              hint: 'e.g. 6',
              controller: _certYearsController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Insurance
            _label('Insurance'),
            const SizedBox(height: 8),
            _toggleTile(
              label: 'I carry active professional liability insurance',
              value: _hasInsurance,
              onChanged: (v) => setState(() => _hasInsurance = v),
            ),
            if (_hasInsurance) ...[
              const SizedBox(height: 12),
              _uploadTile('Upload Insurance Document (optional)'),
            ],
            const SizedBox(height: 28),

            // ── 4. Professional Context ───────────────────────────────────
            _section(
              'Professional Context & Experience',
              Icons.psychology_outlined,
            ),
            _label('Disciplines Commonly Worked With'),
            const SizedBox(height: 8),
            _multiCheckGrid(_disciplines, _selectedDisciplines, columns: 2),
            if (_selectedDisciplines.contains('Other')) ...[
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Please specify',
                hint: 'e.g. Polo, Western',
                controller: _otherDisciplineController,
              ),
            ],
            const SizedBox(height: 16),
            _label('Experience With'),
            const SizedBox(height: 8),
            _multiCheckGrid(_experienceTypes, _selectedExpTypes, columns: 2),
            const SizedBox(height: 28),

            // ── 5. Consent + Scope Disclaimer ─────────────────────────────
            _section('Consent & Professional Boundaries', Icons.gavel_outlined),
            _label('Session Protocol Acknowledgment'),
            const SizedBox(height: 8),
            _toggleTile(
              label: 'Trainer presence required or preferred during sessions',
              value: _trainerPresenceRequired,
              onChanged: (v) => setState(() => _trainerPresenceRequired = v),
            ),
            const SizedBox(height: 12),
            _scopeBox(),
            const SizedBox(height: 12),
            _checkTile(
              label: 'I acknowledge the Scope of Practice disclaimer above *',
              value: _scopeAck,
              onChanged: (v) => setState(() => _scopeAck = v ?? false),
            ),
            const SizedBox(height: 28),

            // ── 6. Typical Horse Level ────────────────────────────────────
            _section(
              'Typical Level of Horses',
              Icons.emoji_events_outlined,
              required: true,
            ),
            _multiCheckGrid(_horseLevels, _selectedHorseLevels, columns: 2),
            const SizedBox(height: 28),

            // ── 7. Regions ────────────────────────────────────────────────
            _section('Regions Covered', Icons.map_outlined, required: true),
            _note(
              'Select the regions you most commonly work in. Availability details will be added later.',
            ),
            const SizedBox(height: 12),
            _multiCheckGrid(_regions, _selectedRegions, columns: 1),
            const SizedBox(height: 28),

            // ── 8. Social Media ───────────────────────────────────────────
            _section('Social Media', Icons.share_outlined),
            _note('At least one is required.'),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Instagram Handle',
              hint: '@yourusername',
              controller: _instagramController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Facebook Profile / Page',
              hint: 'facebook.com/yourpage',
              controller: _facebookController,
            ),
            const SizedBox(height: 28),

            // ── 9. References ─────────────────────────────────────────────
            _section(
              'Professional References',
              Icons.people_outline_rounded,
              required: true,
            ),
            _note(
              'Please provide four professional references who can speak to your experience and reliability.',
            ),
            const SizedBox(height: 16),

            _refSubheader('Trainer Reference 1'),
            _refFields(
              _t1NameController,
              _t1BusinessController,
              _t1RelController,
            ),
            const SizedBox(height: 16),

            _refSubheader('Trainer Reference 2'),
            _refFields(
              _t2NameController,
              _t2BusinessController,
              _t2RelController,
            ),
            const SizedBox(height: 16),

            _refSubheader('Vendor Reference 1'),
            _refFields(
              _v1NameController,
              _v1BusinessController,
              _v1RelController,
            ),
            const SizedBox(height: 16),

            _refSubheader('Vendor Reference 2'),
            _refFields(
              _v2NameController,
              _v2BusinessController,
              _v2RelController,
            ),
            const SizedBox(height: 28),

            // ── 10. Professional Expectations ─────────────────────────────
            _section(
              'Professional Expectations',
              Icons.verified_outlined,
              required: true,
            ),
            _checkTile(
              label:
                  'I confirm the references listed above are aware they may be contacted during application review. *',
              value: _refsAware,
              onChanged: (v) => setState(() => _refsAware = v ?? false),
            ),
            _checkTile(
              label: 'I carry professional liability insurance. *',
              value: _insuranceConfirm,
              onChanged: (v) => setState(() => _insuranceConfirm = v ?? false),
            ),
            _checkTile(
              label: 'I understand this is a professional-only platform. *',
              value: _professionalPlatform,
              onChanged: (v) =>
                  setState(() => _professionalPlatform = v ?? false),
            ),
            _checkTile(
              label: 'I understand approval is not guaranteed. *',
              value: _approvalNotGuaranteed,
              onChanged: (v) =>
                  setState(() => _approvalNotGuaranteed = v ?? false),
            ),
            _checkTile(
              label: 'I confirm that I am 18 years of age or older. *',
              value: _ageConfirm,
              onChanged: (v) => setState(() => _ageConfirm = v ?? false),
            ),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────
            CustomButton(
              text: widget.isLastForm
                  ? 'Submit Application'
                  : 'Continue to Next Service',
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'All applications are subject to admin review and approval.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build helpers
  // ─────────────────────────────────────────────────────────────────────────

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
          const Icon(Icons.spa_rounded, color: AppColors.deepNavy, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bodywork Specialist Application',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verify training, modality scope, and professional boundaries.',
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

  Widget _section(String title, IconData icon, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.deepNavy),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.softRed,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: 40, color: AppColors.mutedGold),
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

  Widget _legalNote(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mutedGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(filled: true, fillColor: Colors.white),
    );
  }

  Widget _multiCheckGrid(
    List<String> options,
    Set<String> selected, {
    int columns = 2,
  }) {
    if (columns == 1) {
      return Column(
        children: options.map((o) {
          final isSelected = selected.contains(o);
          return CheckboxListTile(
            value: isSelected,
            onChanged: (v) => setState(() {
              if (v == true) {
                selected.add(o);
              } else {
                selected.remove(o);
              }
            }),
            title: Text(o, style: AppTextStyles.bodyMedium),
            activeColor: AppColors.deepNavy,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          );
        }).toList(),
      );
    }

    // 2-column grid
    final rows = <Widget>[];
    for (int i = 0; i < options.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _checkChip(options[i], selected)),
            const SizedBox(width: 10),
            i + 1 < options.length
                ? Expanded(child: _checkChip(options[i + 1], selected))
                : const Expanded(child: SizedBox()),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _checkChip(String label, Set<String> selected) {
    final isSelected = selected.contains(label);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() {
        if (isSelected) {
          selected.remove(label);
        } else {
          selected.add(label);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepNavy.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.deepNavy : AppColors.grey300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: isSelected ? AppColors.deepNavy : AppColors.grey400,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.deepNavy
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppTextStyles.bodyMedium),
      activeColor: AppColors.deepNavy,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _checkTile({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppTextStyles.bodyMedium),
      activeColor: AppColors.deepNavy,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _uploadTile(String label) {
    return InkWell(
      onTap: () => Get.snackbar('Upload', 'Document picker coming soon'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.deepNavy.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file_rounded, color: AppColors.deepNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softRed.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gavel_outlined,
                size: 16,
                color: AppColors.softRed,
              ),
              const SizedBox(width: 6),
              Text(
                'Scope of Practice Disclaimer',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.softRed,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...[
            'Services provided are supportive bodywork only.',
            'Not veterinary care.',
            'No diagnosis or medical treatment is provided.',
            'Provider operates within legal scope for their location.',
          ].map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.softRed)),
                  Expanded(
                    child: Text(
                      s,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _refSubheader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.deepNavy,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _refFields(
    TextEditingController nameCtrl,
    TextEditingController businessCtrl,
    TextEditingController relCtrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          CustomTextField(
            label: 'Name *',
            hint: 'Full name',
            controller: nameCtrl,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'Business Name',
            hint: 'Barn / business name',
            controller: businessCtrl,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'Relationship',
            hint: 'e.g. Worked together at WEF 2025',
            controller: relCtrl,
          ),
        ],
      ),
    );
  }
}
