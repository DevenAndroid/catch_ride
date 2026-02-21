import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_clipping.dart';

class BookingClippingScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool isVendorView;

  const BookingClippingScreen({
    super.key,
    required this.booking,
    this.isVendorView = true,
  });

  void _showChangeRequestModal() {
    Get.defaultDialog(
      title: 'Modify Reservation',
      middleText:
          'Editing this reservation will notify the other party for approval.',
      textConfirm: 'Edit Details',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.deepNavy,
      onConfirm: () {
        Get.back(); // close dialog
        Get.to(
          () => BookingsRequestClippingScreen(vendorName: booking.clientName),
        ); // Mock router back
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Clipping Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Title Block & Route ──────────────────────────────────────────
            Text(
              '3 Full Body Clipping Job Ocala, FL', // Mock checklist route formatting
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            _statusBadge(),
            const SizedBox(height: 24),
            const Divider(color: AppColors.grey200, thickness: 1),
            const SizedBox(height: 24),

            // ── Static Booking Info ────────────────────────────────────────────
            _sectionTitle('Job Details'),
            _infoRow('Dates', _formatDates()),
            _infoRow('Address', booking.location),
            _infoRow('Services', '2 Full Body Clips, 1 Touches'),
            _infoRow('Total Rate', '\$450.00'),
            const SizedBox(height: 24),

            // ── Action Buttons ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Opening Chat',
                        'Navigating to message thread...',
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message Thread'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepNavy,
                      side: const BorderSide(color: AppColors.deepNavy),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showChangeRequestModal,
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Change Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepNavy,
                      side: const BorderSide(color: AppColors.deepNavy),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Shared Profile Card ───────────────────────────────────────────
            _sectionTitle(isVendorView ? 'Trainer Profile' : 'Clipper Profile'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.mutedGold.withOpacity(0.15),
                    child: Text(
                      booking.clientName[0],
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.mutedGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.clientName,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVendorView
                              ? 'Wellington, FL / Ocala, FL'
                              : 'Ocala, FL (Home Base)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.grey400),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Policies & Payment ────────────────────────────────────────────
            _sectionTitle('Policies & Payment Rules'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.grey600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cancellation Policy: Moderate',
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              'Full refund if canceled 48+ hours before job. 50% refund thereafter.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.grey300),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.payment_outlined,
                        color: AppColors.grey600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payments Accepted',
                              style: AppTextStyles.titleMedium,
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: ['Venmo', 'Zelle', 'Cash'].map((p) {
                                return Chip(
                                  label: Text(
                                    p,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: AppColors.deepNavy
                                      .withOpacity(0.05),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.snackbar(
                    'Canceled',
                    'Booking cancellation initiated.',
                    backgroundColor: AppColors.softRed,
                    colorText: Colors.white,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.softRed,
                  side: const BorderSide(color: AppColors.softRed),
                ),
                child: const Text('Cancel Reservation'),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _formatDates() {
    if (booking.endDate != null) {
      return '${DateFormat('MMM d').format(booking.date)} - ${booking.endDate!}';
    }
    return DateFormat('MMM d, yyyy').format(booking.date);
  }

  Widget _statusBadge() {
    Color c;
    String t;
    switch (booking.status) {
      case BookingStatus.confirmed:
        c = AppColors.successGreen;
        t = 'Confirmed';
        break;
      case BookingStatus.pending:
        c = AppColors.mutedGold;
        t = 'Pending';
        break;
      case BookingStatus.completed:
        c = AppColors.deepNavy;
        t = 'Completed';
        break;
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        c = AppColors.softRed;
        t = 'Canceled';
        break;
      default:
        c = AppColors.grey500;
        t = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c),
      ),
      child: Text(
        t,
        style: AppTextStyles.labelLarge.copyWith(
          color: c,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.grey500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
