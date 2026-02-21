import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

// Trainer-facing UI to initiate a request to a Bodywork Specialist
class BookingRequestBodyworkScreen extends StatefulWidget {
  final String providerName;
  const BookingRequestBodyworkScreen({super.key, required this.providerName});

  @override
  State<BookingRequestBodyworkScreen> createState() =>
      _BookingRequestBodyworkScreenState();
}

class _BookingRequestBodyworkScreenState
    extends State<BookingRequestBodyworkScreen> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  void _submitRequest() {
    Get.snackbar(
      'Request Sent',
      'Your booking request has been sent to ${widget.providerName}.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    // Mimic the flow routing
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Session'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requesting from: ${widget.providerName}',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 24),
            Text('Select Services', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            // Mock choices for trainer
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Sports Massage (\$175)'),
                  selected: true,
                  onSelected: (_) {},
                  selectedColor: AppColors.deepNavy,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Date/Time Preferences', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.deepNavy),
                  SizedBox(width: 12),
                  Text('March 5, 2026 • Morning'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Location Details', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Wellington Equestrian Center',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Notes for Provider', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any specific horse needs or context...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
