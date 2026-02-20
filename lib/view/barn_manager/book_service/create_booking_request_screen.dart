import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class CreateBookingRequestBarnManager extends StatefulWidget {
  final String? prefilledVendorName;
  final String? prefilledServiceType;

  const CreateBookingRequestBarnManager({
    super.key,
    this.prefilledVendorName,
    this.prefilledServiceType,
  });

  @override
  State<CreateBookingRequestBarnManager> createState() =>
      _CreateBookingRequestBarnManagerState();
}

class _CreateBookingRequestBarnManagerState
    extends State<CreateBookingRequestBarnManager> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedServiceType;

  // Mock service types based on vendor categories
  final List<String> _serviceTypes = [
    'Braiding',
    'Clipping',
    'Hauling',
    'Veterinary',
    'Farrier',
    'Massage / Bodywork',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.prefilledServiceType;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _startDate,
    );
    if (dt != null) {
      setState(() => _startDate = dt);
    }
  }

  Future<void> _pickEndDate() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _endDate ?? _startDate,
    );
    if (dt != null) {
      setState(() => _endDate = dt);
    }
  }

  void _submitRequest() {
    if (_selectedServiceType == null) {
      Get.snackbar(
        'Error',
        'Please select a service type',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Error',
        'Please select start and end dates',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    if (_locationController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a show or location',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    // Submit logic
    // Notes: All Barn Manager messages/bookings inherit trainerId
    Get.back();
    Get.snackbar(
      'Request Sent',
      'Your booking request has been sent successfully.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.prefilledVendorName != null) ...[
              Text('Vendor', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Text(
                  widget.prefilledVendorName!,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Service Type
            Text('Service Type *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: InputDecoration(
                hintText: 'Select a service type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: _serviceTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedServiceType = val);
              },
            ),
            const SizedBox(height: 24),

            // Start Date
            Text('Start Date *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _buildDateSelector(
              label: _startDate != null
                  ? AppDateFormatter.format(_startDate!)
                  : 'Select start date',
              isActive: _startDate != null,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 16),

            // End Date
            Text('End Date *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _buildDateSelector(
              label: _endDate != null
                  ? AppDateFormatter.format(_endDate!)
                  : 'Select end date',
              isActive: _endDate != null,
              onTap: _pickEndDate,
            ),
            const SizedBox(height: 24),

            // Location Field
            Text('Show Venue / Location *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Ocala World Equestrian Center',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            Text('Notes', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any specific details or requests...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),

            CustomButton(text: 'Submit Request', onPressed: _submitRequest),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.deepNavy,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isActive ? AppColors.deepNavy : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
