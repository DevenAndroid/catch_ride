import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddAvailabilityBlockView extends StatefulWidget {
  const AddAvailabilityBlockView({super.key});

  @override
  State<AddAvailabilityBlockView> createState() => _AddAvailabilityBlockViewState();
}

class _AddAvailabilityBlockViewState extends State<AddAvailabilityBlockView> {
  final controller = Get.find<VendorAvailabilityController>();

  // Date state
  DateTime? _startDate;
  DateTime? _endDate;

  // Text controllers
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();

  // Lists
  final List<String> _addedVenues = [];
  final RxInt _maxHorses = 6.obs;
  final RxInt _maxDays = 12.obs;

  // Service types
  final List<String> _availableServiceTypes = ['Grooming', 'Braiding'];
  final List<String> _selectedServiceTypes = [];

  // Work types
  final List<String> _workTypes = [
    'Show week support',
    'Daily barn help',
    'Fill In / Daily show support',
    'Seasonal / Temporary',
  ];
  final List<String> _selectedWorkTypes = [];

  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addVenue() {
    final text = _venueController.text.trim();
    if (text.isNotEmpty && !_addedVenues.contains(text)) {
      setState(() => _addedVenues.add(text));
      _venueController.clear();
    }
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar('Missing Info', 'Please select start and end dates', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_selectedServiceTypes.isEmpty) {
      Get.snackbar('Missing Info', 'Please select at least one service type', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    _isSubmitting.value = true;
    try {
      final payload = {
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'serviceTypes': _selectedServiceTypes,
        'workTypes': _selectedWorkTypes,
        'showVenues': _addedVenues,
        'maxBookings': _maxHorses.value,
        'maxDays': _maxDays.value,
        'notes': _notesController.text.trim(),
      };

      await controller.createAvailabilityBlock(payload);
      Get.back();
    } catch (e) {
      // Error already shown by controller
    } finally {
      _isSubmitting.value = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Add Availability Block', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText('Block Details', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),

              // Date Pickers
              Row(
                children: [
                  Expanded(child: _buildDateField('Start Date', _startDate, () => _pickDate(true))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateField('End Date', _endDate, () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 24),

              // Service Types
              _buildLabel('Service Types *'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableServiceTypes.map((type) {
                  final selected = _selectedServiceTypes.contains(type);
                  return GestureDetector(
                    onTap: () => setState(() {
                      selected ? _selectedServiceTypes.remove(type) : _selectedServiceTypes.add(type);
                    }),
                    child: _buildChip(type, isSelected: selected),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Work Type
              _buildLabel('Work Type'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workTypes.map((type) {
                  final selected = _selectedWorkTypes.contains(type);
                  return GestureDetector(
                    onTap: () => setState(() {
                      selected ? _selectedWorkTypes.remove(type) : _selectedWorkTypes.add(type);
                    }),
                    child: _buildChip(type, isSelected: selected),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Show Venue
              _buildLabel('Show Venue (optional)'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _venueController,
                      onSubmitted: (_) => _addVenue(),
                      decoration: InputDecoration(
                        hintText: 'Enter show venue and press add',
                        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addVenue,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              if (_addedVenues.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _addedVenues.map((v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(v, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _addedVenues.remove(v)),
                          child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Capacity
              const CommonText('Capacity (optional)', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildCounter('Max Horses', _maxHorses)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCounter('Max Days', _maxDays)),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              _buildLabel('Notes For Trainers (optional)'),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Any specific preference, requirements, or information trainers should know...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
        child: SafeArea(
          child: Obx(() => Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: 'Cancel',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  borderColor: AppColors.borderLight,
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CommonButton(
                  text: _isSubmitting.value ? 'Saving...' : 'Add Block',
                  onPressed: _isSubmitting.value ? null : _submit,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: date != null ? AppColors.primary : AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
                  color: date != null ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: AppTextSizes.size14,
                  fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: CommonText(
        label,
        fontSize: AppTextSizes.size12,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCounter(String label, RxInt value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () { if (value.value > 1) value.value--; }),
              Obx(() => CommonText('${value.value}', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => value.value++),
            ],
          ),
        ),
      ],
    );
  }
}
