// availability_bodywork.dart
// Availability tab for Bodywork Specialist accounts.
// Updated to reflect session-based, location-dependent availability
// (Show vs Barn) with corresponding scheduling rules and trainer-facing notes.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

class AvailabilityBodyworkScreen extends StatefulWidget {
  const AvailabilityBodyworkScreen({super.key});

  @override
  State<AvailabilityBodyworkScreen> createState() =>
      _AvailabilityBodyworkScreenState();
}

class _AvailabilityBodyworkScreenState
    extends State<AvailabilityBodyworkScreen> {
  // ── 1. Accepting toggle ───────────────────────────────────────────────────
  bool _isAccepting = true;

  // ── 2. Location Type (multi-select) ───────────────────────────────────────
  final Set<String> _locationTypes = {'show'}; // 'barn', 'show'

  // ── 3. Show-Based Availability ────────────────────────────────────────────
  final Set<String> _selectedWeeks = {'Week 4', 'Week 5'};
  int _maxSessionsPerWeek = 8;
  bool _acceptWaitlist = true;

  // ── 4. Date-Based (Barn) Availability ─────────────────────────────────────
  DateTime? _availFrom;
  DateTime? _availTo;
  final Set<String> _timeBlocks = {'Full Day'};
  int _maxSessionsPerDayBarn = 3;

  // ── 5. Capacity & Scheduling Rules ────────────────────────────────────────
  int _maxSessionsPerDayTotal = 4;
  bool _bufferBetweenSessions = true;
  bool _noBackToBack = false;

  // ── 6. Trainer-Facing Notes ───────────────────────────────────────────────
  final TextEditingController _notesController = TextEditingController();

  Future<void> _pickFrom() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _availFrom,
    );
    if (dt != null) setState(() => _availFrom = dt);
  }

  Future<void> _pickTo() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _availTo ?? _availFrom,
    );
    if (dt != null) setState(() => _availTo = dt);
  }

  void _save() {
    if (_locationTypes.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one Location Type.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      'Saved',
      'Availability rules updated',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Availability'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
            // ── Accepting Toggle ──
            _acceptingBanner(),
            const SizedBox(height: 28),

            // ── Location Type ──
            _sectionLabel('Location Type', Icons.location_on_rounded),
            const SizedBox(height: 4),
            Text(
              'Required. Where do you offer sessions?',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            _locationTypeSelector(),
            const SizedBox(height: 28),

            // ── Show-Based Section ──
            if (_locationTypes.contains('show')) ...[
              _showBasedSection(),
              const SizedBox(height: 32),
            ],

            // ── Date-Based (Barn) Section ──
            if (_locationTypes.contains('barn')) ...[
              _barnBasedSection(),
              const SizedBox(height: 32),
            ],

            // ── Capacity & Scheduling Rules ──
            _capacityAndRulesSection(),
            const SizedBox(height: 32),

            // ── Trainer-Facing Notes ──
            _trainerNotesSection(),
            const SizedBox(height: 40),

            // ── Save Button ──
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
                  'Save Availability',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  UI Sections
  // ─────────────────────────────────────────────────────────────────────────

  Widget _acceptingBanner() {
    final color = _isAccepting ? AppColors.successGreen : AppColors.softRed;
    final label = _isAccepting
        ? 'Accepting Session Requests'
        : 'Not Accepting Requests';
    final sub = _isAccepting
        ? 'Trainers can see you in search results.'
        : 'Your profile is hidden until re-enabled.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            _isAccepting ? Icons.check_circle_rounded : Icons.block_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAccepting,
            onChanged: (v) => setState(() => _isAccepting = v),
            activeColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _locationTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _locChip(
            'barn',
            'Barn / Private Farm',
            Icons.home_work_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _locChip(
            'show',
            'Show / Competition',
            Icons.emoji_events_outlined,
          ),
        ),
      ],
    );
  }

  Widget _locChip(String id, String label, IconData icon) {
    final sel = _locationTypes.contains(id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (sel) {
            _locationTypes.remove(id);
          } else {
            _locationTypes.add(id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.deepNavy : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? AppColors.deepNavy : AppColors.grey200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: sel ? Colors.white : AppColors.grey500),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showBasedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.stadium_rounded,
                size: 20,
                color: AppColors.deepNavy,
              ),
              const SizedBox(width: 8),
              Text('Show-Based Availability', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          // Mock Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.grey400,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search show database...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Mock Selected Show
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deepNavy.withOpacity(0.04),
              border: Border.all(color: AppColors.deepNavy.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: AppColors.mutedGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Winter Equestrian Festival (WEF)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Wellington, FL • 2026 Circuit',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Available Weeks', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Week 4', 'Week 5', 'Week 6', 'Week 7'].map((w) {
              final sel = _selectedWeeks.contains(w);
              return ChoiceChip(
                label: Text(w),
                selected: sel,
                selectedColor: AppColors.deepNavy,
                backgroundColor: AppColors.grey50,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : AppColors.textPrimary,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (v) => setState(() {
                  if (v)
                    _selectedWeeks.add(w);
                  else
                    _selectedWeeks.remove(w);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _stepper(
            label: 'Session capacity (per selected week)',
            value: _maxSessionsPerWeek,
            onChanged: (v) => setState(() => _maxSessionsPerWeek = v),
          ),
          const SizedBox(height: 12),
          _settingToggle(
            label: 'Accept Waitlist',
            subtitle: 'Allow backup requests if week is full',
            value: _acceptWaitlist,
            onChanged: (v) => setState(() => _acceptWaitlist = v),
          ),
        ],
      ),
    );
  }

  Widget _barnBasedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.home_work_rounded,
                size: 20,
                color: AppColors.deepNavy,
              ),
              const SizedBox(width: 8),
              Text('Barn / Farm Availability', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          _datePicker(
            label: 'Available From',
            value: _availFrom,
            onTap: _pickFrom,
          ),
          const SizedBox(height: 10),
          _datePicker(label: 'Available To', value: _availTo, onTap: _pickTo),
          if (_availFrom != null && _availTo != null) ...[
            const SizedBox(height: 10),
            _rangeChip(),
          ],
          const SizedBox(height: 20),
          Text('Time Blocks', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['AM', 'PM', 'Full Day', 'Flexible'].map((tb) {
              final sel = _timeBlocks.contains(tb);
              return ChoiceChip(
                label: Text(tb),
                selected: sel,
                selectedColor: AppColors.deepNavy,
                backgroundColor: AppColors.grey50,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : AppColors.textPrimary,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (v) => setState(() {
                  if (v)
                    _timeBlocks.add(tb);
                  else
                    _timeBlocks.remove(tb);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _stepper(
            label: 'Session capacity (per day)',
            value: _maxSessionsPerDayBarn,
            onChanged: (v) => setState(() => _maxSessionsPerDayBarn = v),
          ),
        ],
      ),
    );
  }

  Widget _capacityAndRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Capacity & Scheduling Rules', Icons.rule_rounded),
        const SizedBox(height: 12),
        _stepper(
          label: 'Max total sessions per day',
          value: _maxSessionsPerDayTotal,
          onChanged: (v) => setState(() => _maxSessionsPerDayTotal = v),
        ),
        const SizedBox(height: 12),
        _settingToggle(
          label: 'Buffer between sessions',
          subtitle: 'Adds mandatory travel/prep time gap',
          value: _bufferBetweenSessions,
          onChanged: (v) => setState(() => _bufferBetweenSessions = v),
        ),
        const SizedBox(height: 8),
        _settingToggle(
          label: 'No back-to-back sessions',
          subtitle: 'Requires 1+ hr gap between bookings',
          value: _noBackToBack,
          onChanged: (v) => setState(() => _noBackToBack = v),
        ),
      ],
    );
  }

  Widget _trainerNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Trainer-Facing Notes', Icons.speaker_notes_outlined),
        const SizedBox(height: 4),
        Text(
          'Visible on your profile. Set expectations for trainers.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText:
                'e.g., "Limit 3 sessions/day", "Show days only", "Prefer 48h notice"',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey400,
            ),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.deepNavy),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.deepNavy),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: value != null
                ? AppColors.deepNavy.withOpacity(0.4)
                : AppColors.grey300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: value != null ? AppColors.deepNavy : AppColors.grey400,
            ),
            const SizedBox(width: 12),
            Text(
              value != null ? AppDateFormatter.format(value) : label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: value != null ? AppColors.deepNavy : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.date_range_rounded,
            size: 14,
            color: AppColors.deepNavy,
          ),
          const SizedBox(width: 8),
          Text(
            AppDateFormatter.formatRange(_availFrom!, _availTo!),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _stepBtn(
            icon: Icons.remove_rounded,
            onTap: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.deepNavy,
                fontSize: 18,
              ),
            ),
          ),
          _stepBtn(
            icon: Icons.add_rounded,
            onTap: value < 50 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepBtn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.deepNavy : AppColors.grey200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : AppColors.grey400,
        ),
      ),
    );
  }

  Widget _settingToggle({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: value ? AppColors.deepNavy.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.deepNavy.withOpacity(0.3)
              : AppColors.grey200,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        activeColor: AppColors.deepNavy,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
