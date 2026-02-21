// booking_detail_braiding.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_braiding.dart';

class BookingBraiderScreen extends StatelessWidget {
  final VendorBooking booking;

  const BookingBraiderScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    // Format dates
    final startStr = DateFormat('MMM d, yyyy').format(b.date);
    final endStr = (b.endDate != null && b.endDate!.isNotEmpty)
        ? ' - ${b.endDate}'
        : '';
    final dateRange = '$startStr$endStr';

    final title = '${b.horseCount} Horses Braiding at ${b.showName}';

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: b.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                b.status.label,
                style: AppTextStyles.labelLarge.copyWith(color: b.status.color),
              ),
            ),
            const SizedBox(height: 16),

            // Main Title
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: 6),
                Text(
                  b.location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Card (Shared Logic representation)
            Text(
              'Booking Parties',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.deepNavy.withOpacity(0.05),
                    child: Text(
                      b.clientName[0],
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.clientName, style: AppTextStyles.titleMedium),
                        Text(
                          b.clientRole,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.grey400,
                    ),
                    onPressed: () =>
                        Get.snackbar('View Profile', 'Opening profile...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message CTA
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.snackbar('Message', 'Opening chat thread...'),
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: const Text('Message Thread'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                  side: const BorderSide(color: AppColors.deepNavy),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Service Info
            _sectionHeader('Service Information'),
            _detailRow('Date Ranges', dateRange),
            const Divider(color: AppColors.grey100),
            _detailRow('Address', b.location),
            const Divider(color: AppColors.grey100),
            _detailRow('Total Horses', '${b.horseCount}'),

            if (b.notes != null && b.notes!.isNotEmpty) ...[
              const Divider(color: AppColors.grey100),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(b.notes!, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Policies
            _sectionHeader('Payment & Policies'),
            _detailRow('Payments Accepted', 'Zelle, Venmo, Cash'),
            const Divider(color: AppColors.grey100),
            _detailRow(
              'Cancellation Policy',
              'Flexible (Free cancellation within 48 hours)',
            ),
            const SizedBox(height: 48),

            // Change Reservation / Cancel Actions
            CustomButton(
              // Secondary style
              text: 'Change Reservation',
              onPressed: () {
                Get.snackbar(
                  'Notification',
                  'Any changes will need to be approved by the other party.',
                );
                // Push to request form
                Future.delayed(const Duration(seconds: 2), () {
                  Get.to(() => const BookingsRequestBraidingScreen());
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.snackbar(
                    'Cancel Booking',
                    'Booking has been cancelled as per the flexible policy.',
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.softRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: AppColors.softRed,
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.deepNavy),
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
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
