import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

// Bodyworker-facing UI to review incoming requests from Trainers
class BookingRequestReviewBodyworkScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const BookingRequestReviewBodyworkScreen({
    super.key,
    required this.requestData,
  });

  void _accept() {
    Get.snackbar(
      'Accepted',
      'You have accepted the booking from ${requestData['clientName']}. A system message has been sent.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Get.back();
  }

  void _decline() {
    Get.snackbar(
      'Declined',
      'You declined the booking. A system message has been sent.',
      backgroundColor: AppColors.softRed,
      colorText: Colors.white,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Request'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.mutedGold),
                  const SizedBox(width: 12),
                  Text(
                    'Pending your approval',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mutedGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Trainer Info Map
            _infoRow(
              Icons.person,
              'Client',
              requestData['clientName'] ?? 'Unknown Trainer',
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.pets,
              'Horse',
              requestData['horseName'] ?? 'Unknown',
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.spa,
              'Service Requested',
              requestData['service'] ?? 'Bodywork',
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.attach_money,
              'Rate quoted',
              requestData['rate'] ?? 'TBD',
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.calendar_today,
              'Date/Time',
              'March 5, 2026 • 8:00 AM',
            ),
            const Divider(height: 24),
            _infoRow(
              Icons.location_on,
              'Location',
              requestData['location'] ?? 'TBD',
            ),
            const Divider(height: 24),

            Text('Notes from client:', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                requestData['notes'] ?? 'No notes provided.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _decline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.softRed,
                      side: const BorderSide(color: AppColors.softRed),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept Booking',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.deepNavy),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
