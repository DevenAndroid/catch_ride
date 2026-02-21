import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

enum TimeWindow { fullDay, morning, afternoon }

class AvailabilityBlock {
  final String id;
  bool isSpecific; // true = date range, false = weekly days
  Set<int> weeklyDays; // 1 = Mon, 7 = Sun
  DateTimeRange? dateRange;
  Set<String> locations;
  TimeWindow window;

  AvailabilityBlock({
    required this.id,
    this.isSpecific = false,
    this.weeklyDays = const {},
    this.dateRange,
    this.locations = const {},
    this.window = TimeWindow.fullDay,
  });

  String get timeLabel {
    switch (window) {
      case TimeWindow.fullDay:
        return 'Full Day';
      case TimeWindow.morning:
        return 'Morning Window';
      case TimeWindow.afternoon:
        return 'Afternoon Window';
    }
  }
}

class AvailabilityFarrierScreen extends StatefulWidget {
  const AvailabilityFarrierScreen({super.key});

  @override
  State<AvailabilityFarrierScreen> createState() =>
      _AvailabilityFarrierScreenState();
}

class _AvailabilityFarrierScreenState extends State<AvailabilityFarrierScreen> {
  // Global Settings
  String _availabilityMode = 'General bookings';
  String _clientIntake = 'Accepting new clients';
  final _notesController = TextEditingController();

  List<AvailabilityBlock> _blocks = [
    AvailabilityBlock(
      id: '1',
      isSpecific: false,
      weeklyDays: {1, 2, 3, 4, 5},
      locations: {'Ocala', 'WEC Ocala'},
      window: TimeWindow.fullDay,
    ),
  ];

  final List<String> _allLocations = [
    'Wellington',
    'Ocala',
    'Gulf Coast Florida',
    'Aiken',
    'Tryon',
    'Lexington',
    'Northeast',
    'Mid-Atlantic (VA/MD/PA)',
    'WEC Ocala',
    'HITS Ocala',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addBlock() {
    _showBlockManagement(null);
  }

  void _editBlock(AvailabilityBlock block) {
    _showBlockManagement(block);
  }

  void _showBlockManagement(AvailabilityBlock? existing) {
    bool isSpecific = existing?.isSpecific ?? false;
    Set<int> days = Set.from(existing?.weeklyDays ?? {});
    DateTimeRange? range = existing?.dateRange;
    Set<String> locations = Set.from(existing?.locations ?? {});
    TimeWindow window = existing?.window ?? TimeWindow.fullDay;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null
                        ? 'Add Availability Block'
                        : 'Edit Availability Block',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // Block Type Toggle
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setModalState(() => isSpecific = false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !isSpecific
                                ? AppColors.deepNavy.withOpacity(0.05)
                                : null,
                            side: BorderSide(
                              color: !isSpecific
                                  ? AppColors.deepNavy
                                  : AppColors.grey200,
                            ),
                          ),
                          child: const Text('Weekly Days'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setModalState(() => isSpecific = true),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSpecific
                                ? AppColors.deepNavy.withOpacity(0.05)
                                : null,
                            side: BorderSide(
                              color: isSpecific
                                  ? AppColors.deepNavy
                                  : AppColors.grey200,
                            ),
                          ),
                          child: const Text('Date Range'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (!isSpecific) ...[
                    Text('Select Days', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final dayNum = index + 1;
                        final label = DateFormat(
                          'E',
                        ).format(DateTime(2024, 1, dayNum));
                        final isSelected = days.contains(dayNum);
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (val) {
                            setModalState(() {
                              if (val)
                                days.add(dayNum);
                              else
                                days.remove(dayNum);
                            });
                          },
                          selectedColor: AppColors.deepNavy.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.grey600,
                          ),
                        );
                      }),
                    ),
                  ] else ...[
                    Text('Select Date Range', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 12),
                    DateRangeChip(
                      startDate: range?.start,
                      endDate: range?.end,
                      onTap: () async {
                        final dr = await AppDatePicker.pickDateRange(
                          context,
                          initialRange: range,
                        );
                        if (dr != null) setModalState(() => range = dr);
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  Text('Locations *', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _allLocations.map((loc) {
                      final isSelected = locations.contains(loc);
                      return FilterChip(
                        label: Text(loc),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            if (val)
                              locations.add(loc);
                            else
                              locations.remove(loc);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Text('Time Window', style: AppTextStyles.labelLarge),
                  _note(
                    'Reflects when you are generally open to bookings. Exact timing is coordinated directly.',
                  ),
                  const SizedBox(height: 12),
                  ...TimeWindow.values.map((tw) {
                    return RadioListTile<TimeWindow>(
                      title: Text(
                        AvailabilityBlock(id: '', window: tw).timeLabel,
                      ),
                      value: tw,
                      groupValue: window,
                      onChanged: (v) => setModalState(() => window = v!),
                      activeColor: AppColors.deepNavy,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),

                  const SizedBox(height: 32),
                  CustomButton(
                    text: existing == null ? 'Add Block' : 'Update Block',
                    onPressed: () {
                      if (locations.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Selection ≥1 location is required',
                        );
                        return;
                      }
                      setState(() {
                        if (existing != null) {
                          _blocks[_blocks.indexOf(
                            existing,
                          )] = AvailabilityBlock(
                            id: existing.id,
                            isSpecific: isSpecific,
                            weeklyDays: days,
                            dateRange: range,
                            locations: locations,
                            window: window,
                          );
                        } else {
                          _blocks.add(
                            AvailabilityBlock(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              isSpecific: isSpecific,
                              weeklyDays: days,
                              dateRange: range,
                              locations: locations,
                              window: window,
                            ),
                          );
                        }
                      });
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (existing != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _blocks.remove(existing));
                        Get.back();
                      },
                      child: const Center(
                        child: Text(
                          'Remove Block',
                          style: TextStyle(color: AppColors.softRed),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Farrier Availability'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Global Availability Preferences',
              Icons.settings_outlined,
            ),
            _label('Availability Mode'),
            ...['General bookings', 'Emergency-only'].map(
              (m) => _radioTile(
                m,
                _availabilityMode,
                (v) => setState(() => _availabilityMode = v!),
              ),
            ),

            const SizedBox(height: 16),
            _label('Client Intake Status'),
            ...[
              'Accepting new clients',
              'Limited availability',
              'Referral-only',
            ].map(
              (s) => _radioTile(
                s,
                _clientIntake,
                (v) => setState(() => _clientIntake = v!),
              ),
            ),

            const SizedBox(height: 16),
            CustomTextField(
              label: 'Availability Notes for Trainers',
              hint: 'e.g. "Must align with existing route", "Showgrounds only"',
              controller: _notesController,
              maxLines: 2,
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(
                  'Bookable Windows',
                  Icons.event_available_outlined,
                ),
                TextButton.icon(
                  onPressed: _addBlock,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Block'),
                ),
              ],
            ),
            _note(
              'Manage your availability by geography and time. Overlapping windows are allowed.',
            ),
            const SizedBox(height: 16),

            if (_blocks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: AppColors.grey300,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No availability blocks added.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._blocks.map((b) => _buildBlockCard(b)),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard(AvailabilityBlock b) {
    String title = '';
    if (b.isSpecific) {
      if (b.dateRange != null) {
        title = AppDateFormatter.formatRange(
          b.dateRange!.start,
          b.dateRange!.end,
        );
      } else {
        title = 'Unset Date Range';
      }
    } else {
      if (b.weeklyDays.isEmpty) {
        title = 'No Days Selected';
      } else {
        final sortedDays = b.weeklyDays.toList()..sort();
        title = sortedDays
            .map((d) => DateFormat('E').format(DateTime(2024, 1, d)))
            .join(', ');
      }
    }

    return GestureDetector(
      onTap: () => _editBlock(b),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.grey400),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.mutedGold,
                ),
                const SizedBox(width: 6),
                Text(
                  b.timeLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: b.locations
                  .map(
                    (loc) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        loc,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepNavy, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(text, style: AppTextStyles.labelLarge),
  );
  Widget _note(String text) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
  );

  Widget _radioTile(
    String label,
    String group,
    void Function(String?) onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: group,
      onChanged: onChanged,
      activeColor: AppColors.deepNavy,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
