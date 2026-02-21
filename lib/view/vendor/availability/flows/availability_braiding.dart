import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

class _BraidingAvailabilityBlock {
  final String id;
  String showName;
  DateTimeRange? dates;
  int maxHorsesPerNight = 10;
  bool isFullyBooked = false;
  final TextEditingController notesController;

  _BraidingAvailabilityBlock({String? showName})
    : id = UniqueKey().toString(),
      showName = showName ?? '',
      notesController = TextEditingController();

  void dispose() {
    notesController.dispose();
  }
}

class AvailabilityBraidingScreen extends StatefulWidget {
  const AvailabilityBraidingScreen({super.key});

  @override
  State<AvailabilityBraidingScreen> createState() =>
      _AvailabilityBraidingScreenState();
}

class _AvailabilityBraidingScreenState
    extends State<AvailabilityBraidingScreen> {
  // Global Toggle
  bool _isAccepting = true;

  final List<_BraidingAvailabilityBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    // Default starting block
    _blocks.add(_BraidingAvailabilityBlock(showName: 'WEF'));
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
      _blocks.add(_BraidingAvailabilityBlock());
    });
  }

  void _removeBlock(String id) {
    setState(() {
      final b = _blocks.firstWhere((e) => e.id == id);
      b.dispose();
      _blocks.removeWhere((e) => e.id == id);
    });
  }

  Future<void> _pickDates(_BraidingAvailabilityBlock block) async {
    final range = await AppDatePicker.pickDateRange(
      context,
      initialRange: block.dates,
    );
    if (range != null) {
      setState(() => block.dates = range);
    }
  }

  void _save() {
    // Validation
    for (var b in _blocks) {
      if (b.showName.isEmpty) {
        _err('Show Missing', 'Please specify a show or venue for all blocks.');
        return;
      }
      if (b.dates == null) {
        _err('Dates Missing', 'Please select date ranges for all blocks.');
        return;
      }
    }

    Get.snackbar(
      'Saved',
      'Braiding schedule updated.',
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
            // ── Global Accept Bookings ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAccepting
                    ? AppColors.successGreen.withOpacity(0.05)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAccepting
                      ? AppColors.successGreen.withOpacity(0.3)
                      : AppColors.grey300,
                ),
              ),
              child: SwitchListTile.adaptive(
                title: Text(
                  _isAccepting
                      ? 'Accepting Requests'
                      : 'Not Accepting Requests',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _isAccepting
                        ? AppColors.successGreen
                        : AppColors.grey600,
                  ),
                ),
                subtitle: const Text(
                  'Toggle off to pause all incoming booking requests temporarily.',
                ),
                value: _isAccepting,
                activeTrackColor: AppColors.successGreen,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isAccepting = v),
              ),
            ),
            const SizedBox(height: 32),

            // ── Show Builder ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Show Schedule',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Build your date-range availability blocks',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _addBlock,
                  icon: const Icon(Icons.add_circle, color: AppColors.deepNavy),
                  tooltip: 'Add Schedule Block',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_blocks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.grey200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Text(
                  'No availability blocks added.\nTrainers will see you as unavailable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),

            ..._blocks.map((b) => _buildAvailabilityBlock(b)),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBlock(_BraidingAvailabilityBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_seat_rounded,
                  size: 18,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Availability Block',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                if (_blocks.length > 1)
                  GestureDetector(
                    onTap: () => _removeBlock(block.id),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.grey400,
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show Select
                _label('Show / Venue *'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: block.showName.isEmpty ? null : block.showName,
                  hint: const Text('Select Location'),
                  items:
                      ['WEF', 'Ocala WEC', 'Aiken', 'Tryon', 'Devon', 'Other']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => block.showName = v);
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Date Range
                _label('Date Range *'),
                const SizedBox(height: 6),
                DateRangeChip(
                  startDate: block.dates?.start,
                  endDate: block.dates?.end,
                  onTap: () => _pickDates(block),
                  onClear: () => setState(() => block.dates = null),
                ),
                const SizedBox(height: 20),

                // Capacity Controls
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Max Horses Per Night',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {
                              if (block.maxHorsesPerNight > 1) {
                                setState(() => block.maxHorsesPerNight--);
                              }
                            },
                          ),
                          Text(
                            '${block.maxHorsesPerNight}',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.deepNavy,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {
                              setState(() => block.maxHorsesPerNight++);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fully Booked Toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: block.isFullyBooked
                        ? AppColors.softRed.withOpacity(0.05)
                        : Colors.white,
                    border: Border.all(
                      color: block.isFullyBooked
                          ? AppColors.softRed
                          : AppColors.grey200,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile.adaptive(
                    value: block.isFullyBooked,
                    activeColor: AppColors.softRed,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Mark Block as Fully Booked',
                      style: TextStyle(
                        color: block.isFullyBooked
                            ? AppColors.softRed
                            : AppColors.grey700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Hides this block from trainer searches.',
                      style: TextStyle(fontSize: 11),
                    ),
                    onChanged: (v) => setState(() => block.isFullyBooked = v),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Notes Visible to Trainers
                _label('Visible Notes for Trainers (Optional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: block.notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Only taking returning clients, Min 5 horses, Hunters Only',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.grey300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.grey300),
                    ),
                  ),
                ),
              ],
            ),
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
}
