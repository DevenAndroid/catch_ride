import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/shipping/flows/load_models.dart';

class CreateLoadShippingScreen extends StatefulWidget {
  final ShippingLoad? existingLoad;
  const CreateLoadShippingScreen({super.key, this.existingLoad});

  @override
  State<CreateLoadShippingScreen> createState() =>
      _CreateLoadShippingScreenState();
}

class _CreateLoadShippingScreenState extends State<CreateLoadShippingScreen> {
  final _originController = TextEditingController();
  final List<TextEditingController> _destinationControllers = [
    TextEditingController(),
  ];
  final _slotsController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _allowsStops = true;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingLoad != null) {
      final load = widget.existingLoad!;
      _originController.text = load.origin;
      _destinationControllers.clear();
      for (var d in load.destinations) {
        _destinationControllers.add(TextEditingController(text: d));
      }
      _slotsController.text = load.totalSlots.toString();
      _equipmentController.text = load.equipmentType;
      _notesController.text = load.notes ?? '';
      _startDate = load.startDate;
      _endDate = load.endDate;
      _allowsStops = load.allowsStops;
      _isPublic = load.isPublic;
    }
  }

  void _addDestination() {
    setState(() {
      _destinationControllers.add(TextEditingController());
    });
  }

  void _removeDestination(int index) {
    if (_destinationControllers.length > 1) {
      setState(() {
        _destinationControllers.removeAt(index);
      });
    }
  }

  void _save() {
    if (_originController.text.isEmpty ||
        _destinationControllers.any((c) => c.text.isEmpty) ||
        _slotsController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    // Logic to save/update load
    Get.back();
    Get.snackbar(
      'Success',
      widget.existingLoad == null
          ? 'Load posted successfully'
          : 'Load updated successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.existingLoad == null ? 'Post a Load' : 'Edit Load'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Route Details', Icons.map_outlined),
            CustomTextField(
              label: 'Origin (City or Show Venue) *',
              controller: _originController,
              hint: 'e.g. Wellington WEF',
            ),
            const SizedBox(height: 16),
            ..._destinationControllers.asMap().entries.map((entry) {
              int idx = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Destination ${idx + 1} *',
                        controller: entry.value,
                        hint: 'City or Show venue',
                      ),
                    ),
                    if (_destinationControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeDestination(idx),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.softRed,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: _addDestination,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Multiple Destinations'),
            ),
            const SizedBox(height: 32),

            _sectionTitle('Date & Capacity', Icons.calendar_today_outlined),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final range = await AppDatePicker.pickDateRange(context);
                      if (range != null) {
                        setState(() {
                          _startDate = range.start;
                          _endDate = range.end;
                        });
                      }
                    },
                    child: _fakeTextField(
                      label: 'Date Range',
                      value: _startDate == null
                          ? 'Select Dates'
                          : '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Available Slots *',
                    controller: _slotsController,
                    keyboardType: TextInputType.number,
                    hint: 'e.g. 6',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _sectionTitle('Equipment & Options', Icons.local_shipping_outlined),
            CustomTextField(
              label: 'Equipment Type *',
              controller: _equipmentController,
              hint: 'e.g. 6-Horse Air Ride Gooseneck',
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              title: const Text('Allows Stops along route'),
              value: _allowsStops,
              onChanged: (v) => setState(() => _allowsStops = v),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile.adaptive(
              title: const Text('Public Visibility'),
              subtitle: const Text('Listed in public load search for trainers'),
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Notes',
              controller: _notesController,
              maxLines: 3,
              hint: 'Special instructions, layover available, etc.',
            ),
            const SizedBox(height: 40),

            CustomButton(
              text: widget.existingLoad == null ? 'Post Load' : 'Save Changes',
              onPressed: _save,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mutedGold, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeTextField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}
