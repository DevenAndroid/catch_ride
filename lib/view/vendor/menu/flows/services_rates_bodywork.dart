import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class _ModalityConfig {
  final String id;
  final String name;
  final IconData icon;
  final bool requiresDisclaimer;

  bool enabled;
  TextEditingController startingPrice;
  Set<int> sessionLengths;
  TextEditingController note;

  _ModalityConfig({
    required this.id,
    required this.name,
    required this.icon,
    this.requiresDisclaimer = false,
    this.enabled = false,
  }) : startingPrice = TextEditingController(),
       sessionLengths = {60},
       note = TextEditingController();
}

class ServicesRatesBodyworkScreen extends StatefulWidget {
  const ServicesRatesBodyworkScreen({super.key});

  @override
  State<ServicesRatesBodyworkScreen> createState() =>
      _ServicesRatesBodyworkScreenState();
}

class _ServicesRatesBodyworkScreenState
    extends State<ServicesRatesBodyworkScreen> {
  late final List<_ModalityConfig> _modalities;

  @override
  void initState() {
    super.initState();
    _modalities = [
      _ModalityConfig(
        id: 'massage',
        name: 'Sports Massage',
        icon: Icons.front_hand_rounded,
        enabled: true,
      )..startingPrice.text = '175',
      _ModalityConfig(
        id: 'myofascial',
        name: 'Myofascial Release',
        icon: Icons.waves_rounded,
      ),
      _ModalityConfig(
        id: 'pemf',
        name: 'PEMF Therapy',
        icon: Icons.bolt_rounded,
      ),
      _ModalityConfig(
        id: 'chiropractic',
        name: 'Chiropractic',
        icon: Icons.accessibility_new_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'acupuncture',
        name: 'Acupuncture',
        icon: Icons.pin_drop_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'laser',
        name: 'Laser Therapy (Cold/Class IV)',
        icon: Icons.flare_rounded,
        requiresDisclaimer: true,
      ),
      _ModalityConfig(
        id: 'redlight',
        name: 'Red Light',
        icon: Icons.light_mode_rounded,
      ),
    ];
  }

  void _save() {
    Get.snackbar(
      'Saved',
      'Services & Rates updated successfully',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Rates'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modalities & Pricing', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Enable each modality you offer. Set a starting price and available session lengths so clients know exactly what to expect.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            _restrictedDisclaimer(),
            const SizedBox(height: 16),
            ..._modalities.map((m) => _modalityCard(m)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

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
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0, width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: AppColors.grey100),
                    const SizedBox(height: 14),
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
}
