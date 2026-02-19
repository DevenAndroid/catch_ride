import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class BookingRequestVendorScreen extends StatefulWidget {
  final String vendorName;
  final String serviceType; // e.g., 'Braiding'

  const BookingRequestVendorScreen({
    super.key,
    required this.vendorName,
    required this.serviceType,
  });

  @override
  State<BookingRequestVendorScreen> createState() =>
      _BookingRequestVendorScreenState();
}

class _BookingRequestVendorScreenState
    extends State<BookingRequestVendorScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDates() async {
    final range = await AppDatePicker.pickDateRange(context);
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.vendorName, style: AppTextStyles.titleMedium),
                    Text(widget.serviceType, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Form
            Text('Booking Details', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Location',
              hint: 'City or Show Venue',
              controller: _locationController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Quantity (e.g. Number of Horses)',
              keyboardType: TextInputType.number,
              controller: _quantityController,
            ),
            const SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: _pickDates,
              child: AbsorbPointer(
                child: CustomTextField(
                  label: 'Dates',
                  hint: _startDate != null
                      ? '${AppDateFormatter.formatDateOnly(_startDate!)} - ${AppDateFormatter.formatDateOnly(_endDate!)}'
                      : 'Select Dates',
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Notes to Vendor',
              hint: 'Specific instructions...',
              maxLines: 4,
              controller: _notesController,
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Submit Request',
              onPressed: () {
                // Submit Logic
                // 1. Create Booking (Pending)
                // 2. Create System Message
                Get.back();
                Get.snackbar('Success', 'Booking Request Sent!');
              },
            ),
          ],
        ),
      ),
    );
  }
}
