import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class ApplicationCompleteGroomScreen extends StatefulWidget {
  final bool isLastForm;
  final VoidCallback onContinue;

  const ApplicationCompleteGroomScreen({
    super.key,
    required this.isLastForm,
    required this.onContinue,
  });

  @override
  State<ApplicationCompleteGroomScreen> createState() =>
      _ApplicationCompleteGroomScreenState();
}

class _ApplicationCompleteGroomScreenState
    extends State<ApplicationCompleteGroomScreen> {
  // Required Text Controllers
  final _homeBaseController = TextEditingController();

  // Selections
  String? _selectedExp;
  final Set<String> _selectedDisciplines = {};
  final Set<String> _selectedLevels = {};
  final Set<String> _selectedRegions = {};

  final _otherDisciplineController = TextEditingController();

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

  // Socials
  final _instaController = TextEditingController();
  final _facebookController = TextEditingController();

  // Acknowledgements
  bool _ackReferences = false;
  bool _ackProfessional = false;
  bool _ackApproval = false;
  bool _ackAge = false;

  void _submit() {
    if (_homeBaseController.text.trim().isEmpty) {
      _err('Missing Field', 'Please provide your home base location.');
      return;
    }
    if (_selectedExp == null) {
      _err('Missing Field', 'Please select your experience level.');
      return;
    }
    if (_selectedDisciplines.isEmpty) {
      _err('Missing Field', 'Please select at least one primary discipline.');
      return;
    }
    if (_selectedLevels.isEmpty) {
      _err('Missing Field', 'Please select typical level of horses.');
      return;
    }
    if (_selectedRegions.isEmpty) {
      _err('Missing Field', 'Please select at least one primary region.');
      return;
    }
    if (_instaController.text.trim().isEmpty &&
        _facebookController.text.trim().isEmpty) {
      _err('Missing Field', 'At least one social media link is required.');
      return;
    }

    // Check all refs
    if (_trainer1Name.text.isEmpty ||
        _trainer1Biz.text.isEmpty ||
        _trainer1Rel.text.isEmpty ||
        _trainer2Name.text.isEmpty ||
        _trainer2Biz.text.isEmpty ||
        _trainer2Rel.text.isEmpty ||
        _vendor1Name.text.isEmpty ||
        _vendor1Biz.text.isEmpty ||
        _vendor1Rel.text.isEmpty ||
        _vendor2Name.text.isEmpty ||
        _vendor2Biz.text.isEmpty ||
        _vendor2Rel.text.isEmpty) {
      _err(
        'Missing References',
        'Please complete all fields for your 4 references.',
      );
      return;
    }

    if (!_ackReferences || !_ackProfessional || !_ackApproval || !_ackAge) {
      _err(
        'Missing Acknowledgements',
        'Please check all required professional acknowledgements to proceed.',
      );
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
    _homeBaseController.dispose();
    _otherDisciplineController.dispose();
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
    _instaController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groom Application'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cleaning_services_rounded,
                    size: 28,
                    color: AppColors.mutedGold,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'This application confirms your professionalism, experience, and scope of operations as a groom.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 1. Home Base
            _header('Home Base', required: true),
            CustomTextField(
              label: 'City, State/Province, Country',
              hint: 'e.g. Ocala, FL, USA',
              controller: _homeBaseController,
            ),
            const SizedBox(height: 32),

            // 2. Experience
            _header(
              'Years of Professional Grooming Experience',
              required: true,
            ),
            ...['0-1', '2-4', '5-9', '10+'].map((opt) {
              return RadioListTile<String>(
                title: Text(opt),
                value: opt,
                groupValue: _selectedExp,
                activeColor: AppColors.deepNavy,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _selectedExp = val),
              );
            }),
            const SizedBox(height: 24),

            // 3. Disciplines
            _header('Primary Disciplines Worked', required: true),
            ...['Hunter/Jumper', 'Dressage', 'Eventing'].map((d) {
              return CheckboxListTile(
                title: Text(d),
                value: _selectedDisciplines.contains(d),
                activeColor: AppColors.deepNavy,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedDisciplines.add(d);
                    } else {
                      _selectedDisciplines.remove(d);
                    }
                  });
                },
              );
            }),
            Row(
              children: [
                Checkbox(
                  value: _selectedDisciplines.contains('Other'),
                  activeColor: AppColors.deepNavy,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedDisciplines.add('Other');
                      } else {
                        _selectedDisciplines.remove('Other');
                      }
                    });
                  },
                ),
                Text('Other', style: AppTextStyles.bodyMedium),
                const SizedBox(width: 12),
                if (_selectedDisciplines.contains('Other'))
                  Expanded(
                    child: TextField(
                      controller: _otherDisciplineController,
                      decoration: const InputDecoration(
                        hintText: 'Specify',
                        isDense: true,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // 4. Typical Level of Horses
            _header('Typical Level of Horses', required: true),
            ...['Young horses', 'A/AA Circuit', 'FEI', 'Grand Prix'].map((lvl) {
              return CheckboxListTile(
                title: Text(lvl),
                value: _selectedLevels.contains(lvl),
                activeColor: AppColors.deepNavy,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedLevels.add(lvl);
                    } else {
                      _selectedLevels.remove(lvl);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 32),

            // 5. Regions
            _header('Regions Covered', required: true),
            Text(
              'Select the regions you most commonly work in. Availability details will be added later.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
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
                        'Travels/ Nationwide',
                      ]
                      .map(
                        (r) => FilterChip(
                          label: Text(r),
                          selected: _selectedRegions.contains(r),
                          selectedColor: AppColors.deepNavy.withOpacity(0.1),
                          checkmarkColor: AppColors.deepNavy,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedRegions.add(r);
                              } else {
                                _selectedRegions.remove(r);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 32),

            // 6. Social Media
            _header('Social Media (1 Required)', required: true),
            CustomTextField(
              label: 'Instagram Handle/URL',
              hint: '@',
              controller: _instaController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Facebook Profile/Page',
              hint: 'URL',
              controller: _facebookController,
            ),
            const SizedBox(height: 32),

            // 7. References
            _header('References', required: true),
            Text(
              'Please provide four professional references who can speak to your experience and reliability.',
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

            // 8. Acknowledgements
            _header('Professional Expectations Acknowledgment', required: true),
            _buildAck(
              'I confirm that the references listed above are aware they may be contacted as part of the application review process.',
              _ackReferences,
              (v) => setState(() => _ackReferences = v ?? false),
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
            hint: 'e.g. Worked together entirely 2023',
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
