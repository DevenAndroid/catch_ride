import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

class BookingsRequestClippingScreen extends StatefulWidget {
  final String? vendorName;

  const BookingsRequestClippingScreen({super.key, this.vendorName});

  @override
  State<BookingsRequestClippingScreen> createState() =>
      _BookingsRequestClippingScreenState();
}

class _BookingsRequestClippingScreenState
    extends State<BookingsRequestClippingScreen> {
  final TextEditingController _showController = TextEditingController();
  final TextEditingController _horsesController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTimeRange? _dates;

  void _submit() {
    if (_showController.text.trim().isEmpty ||
        _dates == null ||
        _horsesController.text.trim().isEmpty ||
        _servicesController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Fields',
        'Please enter a location, date range, horse count, and requested services.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Request Sent',
      'Your clipping request has been sent to ${widget.vendorName ?? 'the Clipper'}.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Clipper'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clipping Booking Request',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your details for ${widget.vendorName ?? 'the Clipper'}.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 32),

            // Location/Venue Name
            CustomTextField(
              label: 'Location / Venue Address *',
              hint: 'e.g. WEC Ocala or Barn Address',
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
              hint: 'How many horses need clipping?',
              controller: _horsesController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Service Types
            CustomTextField(
              label: 'Services Requested *',
              hint: 'e.g. 2 Full Body Clips, 1 Trace Clip',
              controller: _servicesController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Notes
            CustomTextField(
              label: 'Notes / Special Instructions',
              hint: 'Any behavioral notes, schedule locks, etc.',
              controller: _notesController,
              maxLines: 4,
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Submit Request', onPressed: _submit),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
