import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_bodywork.dart';

// Booking detail view shared between Trainer & Specialist (Static View)
class BookingDetailBodyworkScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailBodyworkScreen({super.key, required this.bookingData});

  void _requestChange() {
    Get.snackbar(
      'Notice',
      'This will bring you back to the booking request form to edit details. A notification will be sent to the other party to approve changes.',
      duration: const Duration(seconds: 4),
    );
    // Route to BookingRequestBodywork initialized with previous data
    Get.to(
      () =>
          BookingRequestBodyworkScreen(providerName: bookingData['clientName']),
    );
  }

  void _cancelReservation() {
    Get.snackbar(
      'Cancelation Started',
      'Please review the cancellation policy before proceeding.',
      backgroundColor: AppColors.softRed,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: ${bookingData['status'].toString().toUpperCase()}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.successGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header/Trip Route Title
            Text(
              '${bookingData['service']}',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${bookingData['location']}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Date/Time: March 5, 2026 • Morning',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 32),

            // Profiles Swap
            _profileSection(),
            const Divider(height: 48),

            // Payment Context
            Text('Payment & Policy', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            _infoRow(
              Icons.payments_outlined,
              'Quoted Rate',
              bookingData['rate'] ?? 'TBD',
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.receipt_long_outlined,
              'Payments Accepted',
              'Credit Card, Venmo, Zelle — Collected via Platform',
            ),
            const Divider(height: 48),

            // Action Blocks
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Message Thread',
                    'Opening chat...',
                    backgroundColor: AppColors.deepNavy,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Message Thread'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.deepNavy,
                  side: const BorderSide(color: AppColors.deepNavy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _requestChange,
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Request Change to Reservation'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.deepNavy,
                  side: const BorderSide(color: AppColors.deepNavy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _cancelReservation,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking (View Policy)'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.softRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileSection() {
    return InkWell(
      onTap: () {
        Get.snackbar('Profile', 'Opening full profile overview');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.deepNavy.withOpacity(0.1),
              child: Text(
                bookingData['clientName'].toString().substring(0, 1),
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
                    'Counterparty',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  Text(
                    bookingData['clientName'],
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'View Full Profile',
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.grey400,
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
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
