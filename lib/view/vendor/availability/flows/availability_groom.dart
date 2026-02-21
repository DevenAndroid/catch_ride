import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class AvailabilityBlockGroom {
  final String id;
  DateTime start;
  DateTime end;
  Set<String> locations;
  String? otherLocation;
  String? primaryRegion;
  Set<String> workTypes;
  int? maxHorses;
  int? maxDays;
  String? notes;

  AvailabilityBlockGroom({
    required this.id,
    required this.start,
    required this.end,
    this.locations = const {},
    this.otherLocation,
    this.primaryRegion,
    this.workTypes = const {},
    this.maxHorses,
    this.maxDays,
    this.notes,
  });
}

class AvailabilityGroomScreen extends StatefulWidget {
  const AvailabilityGroomScreen({super.key});

  @override
  State<AvailabilityGroomScreen> createState() =>
      _AvailabilityGroomScreenState();
}

class _AvailabilityGroomScreenState extends State<AvailabilityGroomScreen> {
  // Global Status
  bool _isAcceptingRequests = true;
  bool _isFullyBooked = false;

  final List<AvailabilityBlockGroom> _blocks = [];

  final List<String> _commonLocations = [
    'Wellington',
    'WEC Ocala',
    'HITS Ocala',
    'Gulf Coast Florida',
    'Aiken',
    'Tryon',
    'Lexington',
    'Mid-Atlantic',
    'Northeast',
    'Southwest',
  ];

  final List<String> _regions = [
    'Southeast',
    'Mid-Atlantic',
    'Northeast',
    'Midwest',
    'Southwest',
    'West Coast',
    'Canada',
    'International',
  ];

  final List<String> _workTypes = [
    'Show week support',
    'Daily barn help',
    'Fill-in Daily Show Support',
    'Seasonal / temporary',
  ];

  void _addBlock() => _showBlockEditor(null);
  void _editBlock(AvailabilityBlockGroom b) => _showBlockEditor(b);

  void _showBlockEditor(AvailabilityBlockGroom? existing) {
    DateTime start = existing?.start ?? DateTime.now();
    DateTime end = existing?.end ?? DateTime.now().add(const Duration(days: 7));
    Set<String> selectedLocs = Set.from(existing?.locations ?? {});
    String? otherLoc = existing?.otherLocation;
    String? primaryReg = existing?.primaryRegion;
    Set<String> selectedWorkTypes = Set.from(existing?.workTypes ?? {});
    final otherLocController = TextEditingController(text: otherLoc);
    final maxHorsesController = TextEditingController(
      text: existing?.maxHorses?.toString() ?? '',
    );
    final maxDaysController = TextEditingController(
      text: existing?.maxDays?.toString() ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');

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

                  // Date Range
                  Text('Date Range *', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final range = await AppDatePicker.pickDateRange(
                        context,
                        initialRange: DateTimeRange(start: start, end: end),
                      );
                      if (range != null) {
                        setModalState(() {
                          start = range.start;
                          end = range.end;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.deepNavy,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d, yyyy').format(end)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Locations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Locations / Venues *',
                        style: AppTextStyles.labelLarge,
                      ),
                      Text(
                        '(Select ≥1)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _commonLocations.map((loc) {
                      final isSelected = selectedLocs.contains(loc);
                      return FilterChip(
                        label: Text(loc),
                        selected: isSelected,
                        onSelected: (val) => setModalState(
                          () => val
                              ? selectedLocs.add(loc)
                              : selectedLocs.remove(loc),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Other Location'),
                    value: selectedLocs.contains('Other'),
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setModalState(
                      () => v == true
                          ? selectedLocs.add('Other')
                          : selectedLocs.remove('Other'),
                    ),
                  ),
                  if (selectedLocs.contains('Other'))
                    CustomTextField(
                      label: 'Specify Location',
                      controller: otherLocController,
                    ),

                  const SizedBox(height: 24),

                  // Primary Region (Optional)
                  Text(
                    'Primary Region (Optional)',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: primaryReg,
                        hint: const Text('Select a region'),
                        items: _regions
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (v) => setModalState(() => primaryReg = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Work Type
                  Text('Work Type *', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _workTypes.map((wt) {
                      final isSelected = selectedWorkTypes.contains(wt);
                      return FilterChip(
                        label: Text(wt),
                        selected: isSelected,
                        onSelected: (val) => setModalState(
                          () => val
                              ? selectedWorkTypes.add(wt)
                              : selectedWorkTypes.remove(wt),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Capacity Controls
                  Text(
                    'Capacity Controls (Optional)',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Max Horses',
                          hint: '0',
                          controller: maxHorsesController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Max Days',
                          hint: '0',
                          controller: maxDaysController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  CustomTextField(
                    label: 'Notes for Trainers',
                    hint:
                        'e.g. "Available for braiding on request", "Willing to travel for multiple horses"',
                    controller: notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: existing == null
                        ? 'Add Availability Block'
                        : 'Update Block',
                    onPressed: () {
                      if (selectedLocs.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please select at least one location',
                        );
                        return;
                      }
                      if (selectedLocs.contains('Other') &&
                          otherLocController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please specify the other location',
                        );
                        return;
                      }

                      final newBlock = AvailabilityBlockGroom(
                        id:
                            existing?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        start: start,
                        end: end,
                        locations: selectedLocs,
                        otherLocation: selectedLocs.contains('Other')
                            ? otherLocController.text.trim()
                            : null,
                        primaryRegion: primaryReg,
                        workTypes: selectedWorkTypes,
                        maxHorses: int.tryParse(maxHorsesController.text),
                        maxDays: int.tryParse(maxDaysController.text),
                        notes: notesController.text.trim(),
                      );

                      setState(() {
                        if (existing == null) {
                          _blocks.add(newBlock);
                        } else {
                          final idx = _blocks.indexWhere(
                            (element) => element.id == existing.id,
                          );
                          _blocks[idx] = newBlock;
                        }
                      });
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  if (existing != null)
                    TextButton(
                      onPressed: () {
                        setState(
                          () => _blocks.removeWhere((e) => e.id == existing.id),
                        );
                        Get.back();
                      },
                      child: const Center(
                        child: Text(
                          'Delete Block',
                          style: TextStyle(color: AppColors.softRed),
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),
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
        title: const Text('Groom Availability'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Toggles
            _sectionHeader('Booking Status', Icons.sync_rounded),
            _buildStatusToggle(
              'Accepting New Requests',
              'Allow trainers to send new booking requests.',
              _isAcceptingRequests,
              (val) => setState(() => _isAcceptingRequests = val),
            ),
            const SizedBox(height: 12),
            _buildStatusToggle(
              'Fully Booked',
              'Mark yourself manually as unavailable for new work.',
              _isFullyBooked,
              (val) => setState(() => _isFullyBooked = val),
              isRed: true,
            ),
            const SizedBox(height: 32),

            // Availability List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader(
                  'Availability Blocks',
                  Icons.event_available_rounded,
                ),
                TextButton.icon(
                  onPressed: _addBlock,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text('Add New'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your schedule by dates and venues. These blocks inform trainers when you are open for work.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 16),

            if (_blocks.isEmpty)
              _buildEmptyState()
            else
              ..._blocks.map((b) => _buildBlockCard(b)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isRed = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value
            ? (isRed
                  ? AppColors.softRed.withOpacity(0.05)
                  : AppColors.successGreen.withOpacity(0.05))
            : AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? (isRed ? AppColors.softRed : AppColors.successGreen)
              : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: isRed ? AppColors.softRed : AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockCard(AvailabilityBlockGroom b) {
    final dateStr =
        '${DateFormat('MMM d').format(b.start)} – ${DateFormat('MMM d, yyyy').format(b.end)}';

    return GestureDetector(
      onTap: () => _editBlock(b),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
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
                Text(
                  dateStr,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.grey400,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Locations
            _infoRow(
              Icons.location_on_rounded,
              b.locations
                  .map(
                    (loc) =>
                        loc == 'Other' ? (b.otherLocation ?? 'Other') : loc,
                  )
                  .join(' + '),
            ),
            const SizedBox(height: 8),

            // Work Types
            if (b.workTypes.isNotEmpty) ...[
              _infoRow(Icons.work_outline_rounded, b.workTypes.join(', ')),
              const SizedBox(height: 8),
            ],

            // Capacity
            if (b.maxHorses != null || b.maxDays != null) ...[
              _infoRow(
                Icons.speed_rounded,
                'Capacity: ${b.maxHorses ?? '-'} horses | ${b.maxDays ?? '-'} days',
              ),
              const SizedBox(height: 8),
            ],

            if (b.notes != null && b.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '"${b.notes}"',
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.mutedGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_note_rounded,
            color: AppColors.grey300,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No availability blocks added.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _addBlock,
            child: const Text('Add your first block'),
          ),
        ],
      ),
    );
  }
}
