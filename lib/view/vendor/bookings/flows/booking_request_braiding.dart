// booking_request_braiding.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

class BookingsRequestBraidingScreen extends StatefulWidget {
  final String? vendorName;

  const BookingsRequestBraidingScreen({super.key, this.vendorName});

  @override
  State<BookingsRequestBraidingScreen> createState() =>
      _BookingsRequestBraidingScreenState();
}

class _BookingsRequestBraidingScreenState
    extends State<BookingsRequestBraidingScreen> {
  final TextEditingController _showController = TextEditingController();
  final TextEditingController _horsesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTimeRange? _dates;

  void _submit() {
    if (_showController.text.trim().isEmpty ||
        _dates == null ||
        _horsesController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Fields',
        'Please enter a show name, date range, and horse count.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Request Sent',
      'Your braiding request has been sent to ${widget.vendorName ?? 'the Braider'}.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Braider'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Request',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your details for ${widget.vendorName ?? 'the Braider'}.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 32),

            // Show Name
            CustomTextField(
              label: 'Show / Venue Name *',
              hint: 'e.g. WEC Ocala',
              controller: _showController,
            ),
            const SizedBox(height: 24),

            // Dates
            Text('Dates Needed *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DateRangeChip(
              startDate: _dates?.start,
              endDate: _dates?.end,
              onTap: () async {
                final dr = await AppDatePicker.pickDateRange(
                  context,
                  initialRange: _dates,
                );
                if (dr != null) setState(() => _dates = dr);
              },
              onClear: () => setState(() => _dates = null),
            ),
            const SizedBox(height: 24),

            // Horse Count
            CustomTextField(
              label: 'Horse Count *',
              hint: 'How many horses?',
              controller: _horsesController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Notes
            CustomTextField(
              label: 'Notes / Special Requests',
              hint: 'e.g. 3 Hunter manes, 1 Jumper braid...',
              controller: _notesController,
              maxLines: 4,
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Submit Request', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
