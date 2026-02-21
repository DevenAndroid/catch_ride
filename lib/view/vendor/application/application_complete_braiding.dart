import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/application/vendor_application_submit_screen.dart';

class ApplicationCompleteBraidingScreen extends StatefulWidget {
  final bool isLastForm;
  final VoidCallback? onContinue;

  const ApplicationCompleteBraidingScreen({
    super.key,
    this.isLastForm = true,
    this.onContinue,
  });

  @override
  State<ApplicationCompleteBraidingScreen> createState() =>
      _ApplicationCompleteBraidingScreenState();
}

class _ApplicationCompleteBraidingScreenState
    extends State<ApplicationCompleteBraidingScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
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

  final _disciplines = ['Hunter', 'Jumper', 'Dressage', 'Eventing', 'Other'];
  final Set<String> _selectedDisciplines = {};

  final _horseLevels = ['A / AA Circuit', 'FEI / International', 'Grand Prix'];
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

  bool _refsAware = false;
  bool _professionalPlatform = false;
  bool _approvalNotGuaranteed = false;
  bool _ageConfirm = false;

  @override
  void dispose() {
    for (final c in [
      _cityController,
      _stateController,
      _countryController,
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
    if (_selectedDisciplines.isEmpty) {
      _err('Disciplines Required', 'Please select at least one discipline.');
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
        !_professionalPlatform ||
        !_approvalNotGuaranteed ||
        !_ageConfirm) {
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
        title: const Text('Braiding Application'),
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
            _label('Years of Professional Braiding Experience *'),
            const SizedBox(height: 8),
            _dropdownField(
              value: _experience,
              hint: 'Select years of experience',
              items: ['0-1', '2-4', '5-9', '10+'],
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 28),

            // ── 3. Professional Context ───────────────────────────────────
            _section(
              'Professional Context & Experience',
              Icons.psychology_outlined,
              required: true,
            ),
            _label('Disciplines Worked (select at least one) *'),
            const SizedBox(height: 8),
            _multiCheckGrid(_disciplines, _selectedDisciplines, columns: 2),
            if (_selectedDisciplines.contains('Other')) ...[
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Please specify',
                hint: 'e.g. Equitation',
                controller: _otherDisciplineController,
              ),
            ],
            const SizedBox(height: 28),

            // ── 4. Typical Horse Level ────────────────────────────────────
            _section(
              'Typical Level of Horses',
              Icons.emoji_events_outlined,
              required: true,
            ),
            _multiCheckGrid(_horseLevels, _selectedHorseLevels, columns: 1),
            const SizedBox(height: 28),

            // ── 5. Regions ────────────────────────────────────────────────
            _section('Regions Covered', Icons.map_outlined, required: true),
            _note(
              'Select the regions you most commonly work in. Availability details will be added later.',
            ),
            const SizedBox(height: 12),
            _multiCheckGrid(_regions, _selectedRegions, columns: 1),
            const SizedBox(height: 28),

            // ── 6. Social Media ───────────────────────────────────────────
            _section('Social Media', Icons.share_outlined, required: true),
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

            // ── 7. References ─────────────────────────────────────────────
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

            // ── 8. Professional Expectations ─────────────────────────────
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
          const Icon(
            Icons.content_cut_rounded,
            color: AppColors.deepNavy,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Braiding Application',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Confirm professionalism and show-readiness.',
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
    int columns = 1,
  }) {
    if (columns == 1) {
      return Column(
        children: options.map((o) {
          final isSelected = selected.contains(o);
          return _checkTile(
            label: o,
            value: isSelected,
            onChanged: (v) => setState(() {
              if (v == true) {
                selected.add(o);
              } else {
                selected.remove(o);
              }
            }),
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

  Widget _refSubheader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _refFields(
    TextEditingController name,
    TextEditingController biz,
    TextEditingController rel,
  ) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CustomTextField(label: 'Name *', hint: 'Jane Doe', controller: name),
        const SizedBox(height: 8),
        CustomTextField(
          label: 'Business Name',
          hint: 'Doe Stables',
          controller: biz,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          label: 'Relationship',
          hint: 'e.g. Current Boss',
          controller: rel,
        ),
      ],
    );
  }
}
