// booking_request_form_base.dart
// TRAINER's side — form to send a service request to a vendor
// Named BookingsRequest[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';

class BookingRequestFormBase extends StatefulWidget {
  final VendorServiceConfig service;
  final String? prefilledVendorName; // passed when coming from a vendor profile
  final VendorBooking?
  existingBooking; // passed when editing/changing reservation

  const BookingRequestFormBase({
    super.key,
    required this.service,
    this.prefilledVendorName,
    this.existingBooking,
  });

  @override
  State<BookingRequestFormBase> createState() => _BookingRequestFormBaseState();
}

class _BookingRequestFormBaseState extends State<BookingRequestFormBase> {
  final _vendorNameController = TextEditingController();
  final _showNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _horseCountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledVendorName != null) {
      _vendorNameController.text = widget.prefilledVendorName!;
    }

    if (widget.existingBooking != null) {
      final b = widget.existingBooking!;
      _vendorNameController.text =
          'John Smith'; // Assuming vendor name for mock
      _showNameController.text = b.showName;
      _locationController.text = b.location;
      _horseCountController.text = b.horseCount.toString();
      _notesController.text = b.notes ?? '';
      _startDate = b.date;
      _selectedService = b.serviceDetail;
    }
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _showNameController.dispose();
    _locationController.dispose();
    _horseCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_showNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _startDate == null ||
        _selectedService == null) {
      Get.snackbar(
        'Missing Information',
        'Please fill in all required fields.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    // Simulate sending booking request + creating inbox thread
    Get.back();
    Get.snackbar(
      'Request Sent!',
      'Your ${widget.service.verbLabel} request has been sent. A message thread has been created.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _startDate == null
        ? 'Select date'
        : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}';
    final endStr = _endDate == null
        ? 'Select end date (optional)'
        : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Request ${widget.service.verbLabel}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service type header banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deepNavy.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.service.icon,
                    color: AppColors.deepNavy,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sending a ${widget.service.verbLabel} request. A message thread will be created automatically.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vendor (pre-filled or manual)
            CustomTextField(
              label: 'Vendor Name',
              hint: 'Who are you sending this to?',
              controller: _vendorNameController,
              readOnly: widget.prefilledVendorName != null,
            ),
            const SizedBox(height: 16),

            // Service type dropdown
            Text('Service Type *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedService,
              hint: const Text('Select a service'),
              items: widget.service.serviceOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedService = val),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Show / Event
            CustomTextField(
              label: 'Show / Event Name *',
              hint: 'e.g. WEF Week 8',
              controller: _showNameController,
            ),
            const SizedBox(height: 16),

            // Location
            CustomTextField(
              label: 'Location / Barn *',
              hint: 'e.g. Wellington Equestrian Center – Barn 4',
              controller: _locationController,
            ),
            const SizedBox(height: 16),

            // Horse count
            CustomTextField(
              label: 'Number of Horses',
              hint: 'e.g. 2',
              controller: _horseCountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Date picker
            Text('Start Date *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _DatePickerTile(label: dateStr, onTap: () => _pickDate(true)),
            const SizedBox(height: 16),

            Text('End Date', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _DatePickerTile(label: endStr, onTap: () => _pickDate(false)),
            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              label: 'Additional Notes',
              hint: 'Gate access, special instructions, timing...',
              controller: _notesController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            CustomButton(text: 'Send Request', onPressed: _submit),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.deepNavy,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
