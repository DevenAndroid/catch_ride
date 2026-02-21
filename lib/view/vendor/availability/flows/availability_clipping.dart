import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class _ClippingAvailabilityBlock {
  final String id;
  DateTimeRange? dates;
  String? locationType; // 'Barn', 'Show / Venue', 'Both'
  final Set<String> locations = {};
  String? availabilityType; // 'AM', 'PM', 'Full Day'
  String capacityOption =
      'No capacity limit'; // 'Max horses per day', 'Max horses per time block', 'No capacity limit'
  final TextEditingController maxCapacityController;
  final TextEditingController notesController;
  bool isFullyBooked = false;
  final Set<DateTime> blackoutDates = {};
  bool isTravelDay = false;

  _ClippingAvailabilityBlock()
    : id = UniqueKey().toString(),
      maxCapacityController = TextEditingController(),
      notesController = TextEditingController();

  void dispose() {
    maxCapacityController.dispose();
    notesController.dispose();
  }
}

class AvailabilityClippingScreen extends StatefulWidget {
  const AvailabilityClippingScreen({super.key});

  @override
  State<AvailabilityClippingScreen> createState() =>
      _AvailabilityClippingScreenState();
}

class _AvailabilityClippingScreenState
    extends State<AvailabilityClippingScreen> {
  // Global Toggle
  bool _isAccepting = true;

  final List<_ClippingAvailabilityBlock> _blocks = [];

  final List<String> _locationOptions = [
    'Wellington',
    'Ocala WEC',
    'Aiken',
    'Tryon',
    'Lexington',
    'Northeast',
    'Southern California',
    'Midwest',
    'National',
  ];

  @override
  void initState() {
    super.initState();
    // Default starting block
    _blocks.add(_ClippingAvailabilityBlock());
  }

  @override
  void dispose() {
    for (var b in _blocks) {
      b.dispose();
    }
    super.dispose();
  }

  void _addBlock() {
    setState(() {
      _blocks.add(_ClippingAvailabilityBlock());
    });
  }

  void _removeBlock(String id) {
    setState(() {
      final b = _blocks.firstWhere((e) => e.id == id);
      b.dispose();
      _blocks.removeWhere((e) => e.id == id);
    });
  }

  Future<void> _pickDates(_ClippingAvailabilityBlock block) async {
    final range = await AppDatePicker.pickDateRange(
      context,
      initialRange: block.dates,
    );
    if (range != null) {
      setState(() => block.dates = range);
    }
  }

  Future<void> _addBlackoutDate(_ClippingAvailabilityBlock block) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      // Normalize time to midnight
      final normalized = DateTime(date.year, date.month, date.day);
      setState(() {
        if (!block.blackoutDates.contains(normalized)) {
          block.blackoutDates.add(normalized);
        }
      });
    }
  }

  void _save() {
    // Validation
    for (var i = 0; i < _blocks.length; i++) {
      final b = _blocks[i];
      if (b.dates == null) {
        _err('Dates Missing', 'Please select date ranges for block ${i + 1}.');
        return;
      }
      if (b.locationType == null) {
        _err(
          'Location Type Missing',
          'Please select a location type for block ${i + 1}.',
        );
        return;
      }
      if (b.locations.isEmpty) {
        _err(
          'Locations Missing',
          'Please select at least one location/venue for block ${i + 1}.',
        );
        return;
      }
      if (b.availabilityType == null) {
        _err(
          'Availability Type Missing',
          'Please select an availability type (AM/PM/Full) for block ${i + 1}.',
        );
        return;
      }
      if (b.capacityOption != 'No capacity limit' &&
          b.maxCapacityController.text.trim().isEmpty) {
        _err(
          'Capacity Missing',
          'Please enter a max limit for block ${i + 1}.',
        );
        return;
      }
    }

    Get.snackbar(
      'Saved',
      'Clipping availability updated.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Availability'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isAccepting
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAccepting
                      ? AppColors.successGreen.withValues(alpha: 0.3)
                      : AppColors.grey300,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _isAccepting
                      ? 'Accepting New Requests'
                      : 'Not Accepting Requests',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _isAccepting
                        ? AppColors.successGreen
                        : AppColors.grey600,
                  ),
                ),
                subtitle: Text(
                  'Global toggle for your clipping business.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                value: _isAccepting,
                activeColor: AppColors.successGreen,
                onChanged: (v) => setState(() => _isAccepting = v),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Clipping is time-block based (AM/PM/Full Day). Add blocks of availability by date and location below.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),

            // Blocks Builder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blocks.length,
              itemBuilder: (context, index) {
                return _buildBlockCard(_blocks[index], index);
              },
            ),

            // Add Block Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addBlock,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Another Availability Block'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.deepNavy,
                  side: const BorderSide(color: AppColors.deepNavy, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard(_ClippingAvailabilityBlock block, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Availability Block ${index + 1}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (_blocks.length > 1)
                  InkWell(
                    onTap: () => _removeBlock(block.id),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dates
                _label('Dates Available *'),
                DateRangeChip(
                  startDate: block.dates?.start,
                  endDate: block.dates?.end,
                  onTap: () => _pickDates(block),
                  onClear: () => setState(() => block.dates = null),
                ),
                const SizedBox(height: 24),

                // 2. Location Selection
                _label('Location Type *'),
                ...['Barn', 'Show / Venue', 'Both'].map(
                  (t) => RadioListTile<String>(
                    title: Text(t),
                    value: t,
                    groupValue: block.locationType,
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) => setState(() => block.locationType = v),
                  ),
                ),
                const SizedBox(height: 16),
                _label('Locations / Venues (Select ≥1) *'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locationOptions
                      .map(
                        (l) => FilterChip(
                          label: Text(l),
                          selected: block.locations.contains(l),
                          selectedColor: AppColors.deepNavy.withValues(
                            alpha: 0.1,
                          ),
                          checkmarkColor: AppColors.deepNavy,
                          onSelected: (val) {
                            setState(() {
                              if (val)
                                block.locations.add(l);
                              else
                                block.locations.remove(l);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),

                // 3. Time Block Capacity
                _label('Availability Type *'),
                ...['AM', 'PM', 'Full Day'].map(
                  (t) => RadioListTile<String>(
                    title: Text(t),
                    value: t,
                    groupValue: block.availabilityType,
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) =>
                        setState(() => block.availabilityType = v),
                  ),
                ),
                const SizedBox(height: 16),

                _label('Capacity Option *'),
                ...[
                  'Max horses per day',
                  'Max horses per time block',
                  'No capacity limit',
                ].map(
                  (o) => RadioListTile<String>(
                    title: Text(o),
                    value: o,
                    groupValue: block.capacityOption,
                    activeColor: AppColors.deepNavy,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) => setState(
                      () => block.capacityOption = v ?? 'No capacity limit',
                    ),
                  ),
                ),
                if (block.capacityOption != 'No capacity limit') ...[
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Max Horses Limit *',
                    hint: 'e.g. 5',
                    controller: block.maxCapacityController,
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 24),

                // 4. Status Controls & Exceptions
                _sectionDivider('Limits & Exceptions'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fully Booked / Blocked'),
                  subtitle: Text(
                    'Removes block from trainer search results',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  value: block.isFullyBooked,
                  activeColor: AppColors.softRed,
                  onChanged: (v) => setState(() => block.isFullyBooked = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Travel Day'),
                  subtitle: Text(
                    'Indicates limited availability due to transit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  value: block.isTravelDay,
                  activeColor: AppColors.deepNavy,
                  onChanged: (v) => setState(() => block.isTravelDay = v),
                ),
                const SizedBox(height: 16),

                // Blackout dates
                _label('Blackout Dates (Specific days offline)'),
                if (block.blackoutDates.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: block.blackoutDates
                        .map(
                          (date) => Chip(
                            label: Text(DateFormat('MMM d').format(date)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(
                              () => block.blackoutDates.remove(date),
                            ),
                            backgroundColor: AppColors.softRed.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                TextButton.icon(
                  onPressed: () => _addBlackoutDate(block),
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppColors.deepNavy,
                  ),
                  label: const Text(
                    'Add Blackout Date',
                    style: TextStyle(color: AppColors.deepNavy),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Notes
                _sectionDivider('Booking Notes'),
                CustomTextField(
                  label: 'Notes for Trainers (Optional)',
                  hint:
                      'e.g. "Barn minimum applies", "Prefer full-day bookings"...',
                  controller: block.notesController,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _sectionDivider(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Divider(color: AppColors.grey300)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
