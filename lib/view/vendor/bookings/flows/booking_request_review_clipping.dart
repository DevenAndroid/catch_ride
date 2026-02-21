import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/clipping_booking_screens.dart';

class BookingRequestReviewClippingScreen extends StatefulWidget {
  final VendorBooking booking;

  const BookingRequestReviewClippingScreen({super.key, required this.booking});

  @override
  State<BookingRequestReviewClippingScreen> createState() =>
      _BookingRequestReviewClippingScreenState();
}

class _BookingRequestReviewClippingScreenState
    extends State<BookingRequestReviewClippingScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _accept() {
    Get.snackbar(
      'Request Accepted',
      'System auto-message sent marking accepted.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => Get.off(
        () => BookingRequestConfirmedClippingScreen(booking: widget.booking),
      ),
    );
  }

  void _decline() {
    Get.snackbar(
      'Request Declined',
      'System auto-message sent marking declined.',
      backgroundColor: AppColors.softRed,
      colorText: Colors.white,
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => Get.off(
        () => BookingRequestDeniedClippingScreen(booking: widget.booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Review Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: Text(
                    widget.booking.clientName.substring(0, 1),
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
                        'Request from ${widget.booking.clientName}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.deepNavy,
                        ),
                      ),
                      Text(
                        widget.booking.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Services & Context
            _sectionTitle('Clipping Job Summary'),
            _infoRow('Location', widget.booking.location),
            _infoRow(
              'Dates',
              widget.booking.endDate != null
                  ? '${DateFormat('MMM d').format(widget.booking.date)} - ${widget.booking.endDate!}'
                  : DateFormat('MMM d, yyyy').format(widget.booking.date),
            ),
            _infoRow('Horses', '3 Horses'), // Mock context
            _infoRow('Services requested', '2 Full Body Clips, 1 Touches'),
            const SizedBox(height: 16),

            // Financial Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Request Value',
                    style: AppTextStyles.titleMedium,
                  ),
                  Text(
                    '\$450.00',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Notes
            _sectionTitle('Client Notes'),
            Text(
              'One horse requires a bridle path touch up. Located in Barn 4.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            // Final Actions
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a message to your response (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _decline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.softRed),
                      foregroundColor: AppColors.softRed,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _accept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.successGreen,
                    ),
                    child: const Text('Accept Booking'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
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
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
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
