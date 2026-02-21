// profile_setup_bodywork.dart
// ProfileCompleteBodywork — post-approval profile setup for Bodywork Specialists.
// Communicates modality clarity + session logistics, not marketing fluff.
// Completion routes → VendorMainScreen (profile is auto-generated from this data).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/flows/vendor_main_bodywork.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data models for modality configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Per-modality pricing + session lengths the vendor can configure.
class _ModalityConfig {
  final String id;
  final String name;
  final IconData icon;
  final bool requiresDisclaimer; // chiro / acu / laser
  bool enabled;
  final TextEditingController startingPrice;
  final Set<int> sessionLengths; // minutes: 30, 45, 60, 90
  final TextEditingController note;

  _ModalityConfig({
    required this.id,
    required this.name,
    required this.icon,
    this.requiresDisclaimer = false,
    this.enabled = false,
  }) : startingPrice = TextEditingController(),
       sessionLengths = {},
       note = TextEditingController();

  void dispose() {
    startingPrice.dispose();
    note.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileSetupBodyworkScreen extends StatefulWidget {
  const ProfileSetupBodyworkScreen({super.key});

  @override
  State<ProfileSetupBodyworkScreen> createState() =>
      _ProfileSetupBodyworkScreenState();
}

class _ProfileSetupBodyworkScreenState
    extends State<ProfileSetupBodyworkScreen> {
  // ── Photos ────────────────────────────────────────────────────────────────
  bool _profilePhotoUploaded = false;
  bool _coverPhotoUploaded = false;

  // ── Bio ───────────────────────────────────────────────────────────────────
  final _bioController = TextEditingController();

  // ── Modalities ────────────────────────────────────────────────────────────
  late final List<_ModalityConfig> _modalities;

  // ── Compliance ────────────────────────────────────────────────────────────
  final _certTypeController = TextEditingController();
  final _certYearsController = TextEditingController();
  String _insuranceStatus = 'carries'; // 'carries' | 'onRequest' | 'none'

  // ── Service Area ─────────────────────────────────────────────────────────
  final _primaryBaseController = TextEditingController();
  String _travelWillingness = 'regional'; // 'local' | 'regional' | 'national'
  final Set<String> _showCircuits = {};

  // ── Horse Level ───────────────────────────────────────────────────────────
  final Set<String> _horseLevels = {};

  // ── Specialties ───────────────────────────────────────────────────────────
  bool _performanceHorses = false;
  bool _rehabSupportive = false;
  bool _youngHorses = false;
  bool _feiPrograms = false;

  @override
  void initState() {
    super.initState();
    _modalities = [
      _ModalityConfig(
        id: 'massage',
        name: 'Sports Massage',
        icon: Icons.self_improvement_rounded,
      ),
      _ModalityConfig(
        id: 'myofascial',
        name: 'Myofascial Release',
        icon: Icons.waves_rounded,
      ),
      _ModalityConfig(
        id: 'pemf',
        name: 'PEMF',
        icon: Icons.electric_bolt_rounded,
      ),
      _ModalityConfig(
        id: 'chiro',
        name: 'Chiropractic',
        icon: Icons.airline_seat_flat_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'acu',
        name: 'Acupuncture',
        icon: Icons.colorize_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'laser',
        name: 'Laser Therapy',
        icon: Icons.highlight_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'redlight',
        name: 'Red Light',
        icon: Icons.light_mode_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _bioController.dispose();
    _certTypeController.dispose();
    _certYearsController.dispose();
    _primaryBaseController.dispose();
    for (final m in _modalities) {
      m.dispose();
    }
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool get _canPublish {
    return _profilePhotoUploaded &&
        _bioController.text.trim().isNotEmpty &&
        _modalities.any((m) => m.enabled) &&
        _horseLevels.isNotEmpty;
  }

  void _publish() {
    if (!_profilePhotoUploaded) {
      _error('Profile photo is required.');
      return;
    }
    if (_bioController.text.trim().isEmpty) {
      _error('Please add a short bio.');
      return;
    }
    if (!_modalities.any((m) => m.enabled)) {
      _error('Enable at least one modality.');
      return;
    }
    if (_horseLevels.isEmpty) {
      _error('Select at least one horse level you work with.');
      return;
    }
    Get.offAll(() => const VendorMainBodyworkScreen());
  }

  void _error(String msg) => Get.snackbar(
    'Required',
    msg,
    backgroundColor: AppColors.softRed,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
  );

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome ───────────────────────────────────────────────────
            _welcomeBanner(),
            const SizedBox(height: 32),

            // ── 1. Photos ─────────────────────────────────────────────────
            _sectionHeader('1', 'Photos', Icons.camera_alt_outlined),
            const SizedBox(height: 16),
            _photoRow(),
            const SizedBox(height: 32),

            // ── 2. Bio ────────────────────────────────────────────────────
            _sectionHeader('2', 'Short Bio', Icons.edit_note_rounded),
            const SizedBox(height: 4),
            Text(
              'Keep it factual — certifications, specialties, approach. '
              'No medical claims.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Bio *',
              hint:
                  'e.g. "Certified equine massage therapist with 8 yrs experience '
                  'supporting performance horses on the A-circuit. '
                  'Trained in sports massage and PEMF. '
                  'Work alongside vet teams — not a replacement for veterinary care."',
              controller: _bioController,
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            // ── 3. Services & Modalities ──────────────────────────────────
            _sectionHeader('3', 'Services & Modalities', Icons.spa_rounded),
            const SizedBox(height: 4),
            Text(
              'Enable each modality you offer. Set a starting price and '
              'available session lengths so clients know exactly what to expect.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            // Restricted modality disclaimer
            _restrictedDisclaimer(),
            const SizedBox(height: 16),
            ..._modalities.map((m) => _modalityCard(m)),
            const SizedBox(height: 32),

            // ── 4. Compliance ─────────────────────────────────────────────
            _sectionHeader(
              '4',
              'Certification & Compliance',
              Icons.verified_outlined,
            ),
            const SizedBox(height: 16),
            _complianceSection(),
            const SizedBox(height: 32),

            // ── 5. Service Area ───────────────────────────────────────────
            _sectionHeader('5', 'Service Area & Travel', Icons.map_outlined),
            const SizedBox(height: 16),
            _serviceAreaSection(),
            const SizedBox(height: 32),

            // ── 6. Horse Level (REQUIRED) ─────────────────────────────────
            _sectionHeader('6', 'Horse Level *', Icons.star_outline_rounded),
            const SizedBox(height: 4),
            Text(
              'At least one is required. This appears as a badge on your profile.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            _horseLevelChips(),
            const SizedBox(height: 32),

            // ── 7. Experience & Specialties ───────────────────────────────
            _sectionHeader(
              '7',
              'Experience & Specialties',
              Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 16),
            _specialtiesSection(),
            const SizedBox(height: 40),

            // ── Progress + Publish ────────────────────────────────────────
            _completionStatus(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canPublish ? _publish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _canPublish
                      ? 'Go Live — Publish My Profile'
                      : 'Complete Required Fields to Publish',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Your profile is fully editable anytime via Menu → Your Profile.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey400,
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
  //  Section components
  // ─────────────────────────────────────────────────────────────────────────

  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepNavy.withOpacity(0.06),
            AppColors.mutedGold.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.deepNavy.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_rounded,
                color: AppColors.deepNavy,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Set Up Your Bodywork Profile',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This information powers your public profile. '
            'Be specific and accurate — clients use this to assess fit before booking. '
            'Focus on logistics and qualifications, not marketing.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey700,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String num, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            num,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: AppColors.deepNavy),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  // ── Photos ────────────────────────────────────────────────────────────────

  Widget _photoRow() {
    return Row(
      children: [
        // Profile photo (required)
        Expanded(
          child: _photoTile(
            label: 'Profile Photo *',
            icon: Icons.person_rounded,
            uploaded: _profilePhotoUploaded,
            required: true,
            onTap: () {
              setState(() => _profilePhotoUploaded = true);
              Get.snackbar('Photo', 'Picker would open here');
            },
          ),
        ),
        const SizedBox(width: 12),
        // Cover photo (optional)
        Expanded(
          child: _photoTile(
            label: 'Cover Photo',
            icon: Icons.landscape_rounded,
            uploaded: _coverPhotoUploaded,
            required: false,
            onTap: () {
              setState(() => _coverPhotoUploaded = true);
              Get.snackbar('Photo', 'Picker would open here');
            },
          ),
        ),
      ],
    );
  }

  Widget _photoTile({
    required String label,
    required IconData icon,
    required bool uploaded,
    required bool required,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        decoration: BoxDecoration(
          color: uploaded
              ? AppColors.successGreen.withOpacity(0.06)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded
                ? AppColors.successGreen.withOpacity(0.5)
                : required
                ? AppColors.mutedGold.withOpacity(0.6)
                : AppColors.grey300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              uploaded ? Icons.check_circle_rounded : icon,
              size: 32,
              color: uploaded ? AppColors.successGreen : AppColors.grey400,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: uploaded ? AppColors.successGreen : AppColors.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!uploaded)
              Text(
                required ? 'Required' : 'Optional',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: required ? AppColors.mutedGold : AppColors.grey400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Restricted Modality Disclaimer ───────────────────────────────────────

  Widget _restrictedDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softRed.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.policy_outlined, size: 16, color: AppColors.softRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '*** Chiropractic, Acupuncture, and Laser Therapy will display the '
              'following on your profile: "Where legally permitted and performed in '
              'accordance with applicable veterinary referral/oversight requirements."',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.softRed,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modality Card ─────────────────────────────────────────────────────────

  Widget _modalityCard(_ModalityConfig m) {
    final isEnabled = m.enabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : AppColors.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled
                ? AppColors.deepNavy.withOpacity(0.4)
                : AppColors.grey200,
            width: isEnabled ? 1.5 : 1,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.deepNavy.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle header
            SwitchListTile(
              value: isEnabled,
              onChanged: (v) => setState(() => m.enabled = v),
              title: Row(
                children: [
                  Icon(
                    m.icon,
                    size: 18,
                    color: isEnabled ? AppColors.deepNavy : AppColors.grey400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? AppColors.deepNavy : AppColors.grey500,
                    ),
                  ),
                  if (m.requiresDisclaimer) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.softRed.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        '***',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.softRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              activeColor: AppColors.deepNavy,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
            ),

            // Expanded pricing fields (only when enabled)
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: AppColors.grey100),
                    const SizedBox(height: 14),

                    // Starting price
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: m.startingPrice,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Starting price ("From \$___")',
                              prefixText: '\$ ',
                              hintText: '150',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Session lengths
                    Text(
                      'Available session lengths (minutes)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [30, 45, 60, 90].map((len) {
                        final sel = m.sessionLengths.contains(len);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (sel) {
                              m.sessionLengths.remove(len);
                            } else {
                              m.sessionLengths.add(len);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.deepNavy
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${len}min',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppColors.grey600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Optional note
                    TextField(
                      controller: m.note,
                      decoration: InputDecoration(
                        labelText: 'Optional note',
                        hintText:
                            'e.g. "show days only," "performance maintenance"',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isEnabled
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compliance ────────────────────────────────────────────────────────────

  Widget _complianceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cert type + years
        Text('Certification / Training', style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Formal certification preferred. Verified certs will display as a badge on your profile.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Type of certification or training',
          hint: 'e.g. "ESMT — Equine Sports Massage Therapist"',
          controller: _certTypeController,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Years of practice in listed modalities',
          hint: 'e.g. "7 years"',
          controller: _certYearsController,
        ),
        const SizedBox(height: 20),

        // Insurance status
        Text('Insurance Status', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        _insuranceTile(
          value: 'carries',
          label: 'Carries Insurance',
          subtitle: 'Available upon request',
          icon: Icons.shield_rounded,
          iconColor: AppColors.successGreen,
        ),
        const SizedBox(height: 8),
        _insuranceTile(
          value: 'onRequest',
          label: 'Insurance Available Upon Request',
          subtitle: 'Provider listed on request',
          icon: Icons.shield_outlined,
          iconColor: AppColors.mutedGold,
        ),
        const SizedBox(height: 8),
        _insuranceTile(
          value: 'none',
          label: 'Not Currently Insured',
          subtitle:
              'Will display on your profile — this is fine for some modalities',
          icon: Icons.no_encryption_outlined,
          iconColor: AppColors.grey400,
        ),
      ],
    );
  }

  Widget _insuranceTile({
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final sel = _insuranceStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _insuranceStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? iconColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? iconColor : AppColors.grey200,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: sel ? iconColor : AppColors.grey400, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.grey800 : AppColors.grey600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            if (sel)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  // ── Service Area ──────────────────────────────────────────────────────────

  Widget _serviceAreaSection() {
    final circuits = [
      'WEF (Wellington, FL)',
      'GDF (Ocala, FL)',
      'HITS Ocala',
      'Devon',
      'Traverse City',
      'INDOORS (Harrisburg)',
      'Capital Challenge',
      'National (DC)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Primary Base',
          hint: 'City, State (e.g. Wellington, FL)',
          controller: _primaryBaseController,
        ),
        const SizedBox(height: 16),

        Text('Willingness to Travel', style: AppTextStyles.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            _travelChip('local', 'Local Only', Icons.near_me_rounded),
            const SizedBox(width: 8),
            _travelChip('regional', 'Regional', Icons.drive_eta_rounded),
            const SizedBox(width: 8),
            _travelChip('national', 'Nationwide', Icons.flight_rounded),
          ],
        ),
        const SizedBox(height: 16),

        Text('Show Circuits Frequented', style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Select all that apply so clients can find you at shows.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: circuits.map((c) {
            final sel = _showCircuits.contains(c);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) {
                  _showCircuits.remove(c);
                } else {
                  _showCircuits.add(c);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppColors.deepNavy : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? AppColors.deepNavy : AppColors.grey200,
                  ),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: sel ? Colors.white : AppColors.grey600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _travelChip(String value, String label, IconData icon) {
    final sel = _travelWillingness == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _travelWillingness = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.deepNavy : AppColors.grey100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? AppColors.deepNavy : AppColors.grey200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: sel ? Colors.white : AppColors.grey500,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Horse Level ───────────────────────────────────────────────────────────

  Widget _horseLevelChips() {
    final levels = [
      ('Performance Horses', Icons.emoji_events_rounded, AppColors.mutedGold),
      ('Young Horses', Icons.child_friendly_rounded, AppColors.deepNavy),
      ('FEI Programs', Icons.military_tech_rounded, AppColors.deepNavy),
      ('Rehab-supportive', Icons.healing_rounded, AppColors.successGreen),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: levels.map((l) {
        final label = l.$1;
        final icon = l.$2;
        final color = l.$3;
        final sel = _horseLevels.contains(label);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) {
              _horseLevels.remove(label);
            } else {
              _horseLevels.add(label);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? color.withOpacity(0.12) : AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel ? color : AppColors.grey200,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: sel ? color : AppColors.grey400),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: sel ? color : AppColors.grey600,
                  ),
                ),
                if (sel) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle_rounded, size: 14, color: color),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Specialties ───────────────────────────────────────────────────────────

  Widget _specialtiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Types of cases you support', style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(
          'These display as searchable tags on your profile.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 12),
        _specialtyToggle(
          label: 'Performance Horses',
          subtitle: 'Active competition horses in regular work',
          icon: Icons.directions_run_rounded,
          value: _performanceHorses,
          onChanged: (v) => setState(() => _performanceHorses = v),
        ),
        const SizedBox(height: 8),
        _specialtyToggle(
          label: 'Rehab-supportive Cases',
          subtitle: 'Post-injury or post-surgery maintenance support',
          icon: Icons.healing_rounded,
          value: _rehabSupportive,
          onChanged: (v) => setState(() => _rehabSupportive = v),
        ),
        const SizedBox(height: 8),
        _specialtyToggle(
          label: 'Young Horses',
          subtitle: 'Horses in early training (under 6)',
          icon: Icons.child_friendly_rounded,
          value: _youngHorses,
          onChanged: (v) => setState(() => _youngHorses = v),
        ),
        const SizedBox(height: 8),
        _specialtyToggle(
          label: 'FEI Programs',
          subtitle: 'Grand Prix / international level sport horses',
          icon: Icons.military_tech_rounded,
          value: _feiPrograms,
          onChanged: (v) => setState(() => _feiPrograms = v),
        ),
      ],
    );
  }

  Widget _specialtyToggle({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: value ? AppColors.deepNavy.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.deepNavy.withOpacity(0.4)
              : AppColors.grey200,
          width: value ? 1.5 : 1,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: value ? AppColors.deepNavy : AppColors.grey400,
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        activeColor: AppColors.deepNavy,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  // ── Completion status ─────────────────────────────────────────────────────

  Widget _completionStatus() {
    final steps = [
      ('Profile Photo', _profilePhotoUploaded),
      ('Bio', _bioController.text.trim().isNotEmpty),
      ('At least one modality', _modalities.any((m) => m.enabled)),
      ('Horse Level', _horseLevels.isNotEmpty),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required to publish',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    s.$2
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: s.$2 ? AppColors.successGreen : AppColors.grey400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.$1,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: s.$2 ? AppColors.grey800 : AppColors.grey500,
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
}
