// booking_request_review_braiding.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';

class BookingRequestReviewBraiderScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool acceptMode;

  const BookingRequestReviewBraiderScreen({
    super.key,
    required this.booking,
    this.acceptMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    // Format dates
    final startStr = DateFormat('MMM d, yyyy').format(b.date);
    final endStr = (b.endDate != null && b.endDate!.isNotEmpty)
        ? ' - ${b.endDate}'
        : '';
    final dateRange = '$startStr$endStr';

    return Scaffold(
      appBar: AppBar(title: const Text('Review Request'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner for context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_twilight_rounded,
                    size: 20,
                    color: AppColors.mutedGold,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Needs your approval',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.mutedGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: Text(
                    b.clientName[0],
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.clientName,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        b.clientRole,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Request Details
            _detailRow(
              'Show / Venue',
              b.showName.isEmpty ? 'Not Specified' : b.showName,
            ),
            const Divider(),
            _detailRow('Date(s)', dateRange),
            const Divider(),
            _detailRow('Horse Count', '${b.horseCount} Horses'),

            if (b.notes != null && b.notes!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Notes from ${b.clientName}',
                style: AppTextStyles.labelLarge,
              ),
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
                  b.notes!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.off(
                        () => BookingDeniedBase(
                          booking: booking,
                          service: VendorServiceConfig.braiding,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.softRed,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.softRed,
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Accept',
                    onPressed: () {
                      Get.off(
                        () => BookingConfirmedBase(
                          booking: booking,
                          service: VendorServiceConfig.braiding,
                        ),
                      );
                    },
                    backgroundColor: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
