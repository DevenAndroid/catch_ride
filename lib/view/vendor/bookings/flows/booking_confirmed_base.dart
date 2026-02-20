// booking_confirmed_base.dart
// Shown when a vendor accepts a booking request
// Named BookingRequestConfirmed[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';

class BookingConfirmedBase extends StatelessWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;

  const BookingConfirmedBase({
    super.key,
    required this.booking,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEEE, MMMM d, yyyy · h:mm a',
    ).format(booking.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Success Icon ─────────────────────────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Accepted!',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A confirmation has been sent to ${booking.clientName}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 28),

            // ── System Message Preview ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'System message sent: "Booking accepted" — visible in your shared thread with ${booking.clientName}.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Booking Summary ──────────────────────────────────────────
            _SummaryCard(booking: booking, service: service, dateStr: dateStr),
            const SizedBox(height: 28),

            // ── Actions ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.snackbar(
                  'Messages',
                  'Opening thread with ${booking.clientName}',
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message Client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.until((r) => r.isFirst),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Back to Bookings'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.deepNavy),
                  foregroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;
  final String dateStr;

  const _SummaryCard({
    required this.booking,
    required this.service,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(Icons.person_outline_rounded, 'Client', booking.clientName),
          _div(),
          _row(Icons.work_outline_rounded, 'Service', booking.serviceDetail),
          _div(),
          _row(Icons.calendar_today_rounded, 'Date', dateStr),
          _div(),
          _row(Icons.location_on_outlined, 'Location', booking.location),
          _div(),
          _row(Icons.flag_outlined, 'Show', booking.showName),
          _div(),
          _row(
            Icons.attach_money_rounded,
            'Rate',
            '${booking.rate} ${service.rateUnit}',
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.grey500),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() =>
      const Divider(height: 1, thickness: 1, color: AppColors.grey100);
}
