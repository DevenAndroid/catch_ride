import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_result_shipping.dart';

class BookingRequestReviewShippingScreen extends StatelessWidget {
  final VendorBooking booking;

  const BookingRequestReviewShippingScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Review Request'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            _sectionTitle('Shipping Details'),
            _detailCard(),
            const SizedBox(height: 32),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              _sectionTitle('Client Notes'),
              _notesCard(),
              const SizedBox(height: 32),
            ],

            if (booking.relatedLoadId != null) _slotWarningCard(),

            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.mutedGold.withOpacity(0.1),
          child: Text(
            booking.clientName[0],
            style: const TextStyle(
              color: AppColors.mutedGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Request from', style: AppTextStyles.bodySmall),
              Text(
                booking.clientName,
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
              Text(
                booking.clientRole,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _infoRow(Icons.local_shipping_outlined, 'Route', booking.location),
          _div(),
          _infoRow(
            Icons.pin_drop_outlined,
            'Pickup',
            booking.pickupAddress ?? 'Not specified',
          ),
          _div(),
          _infoRow(
            Icons.flag_circle_outlined,
            'Dropoff',
            booking.dropoffAddress ?? 'Not specified',
          ),
          _div(),
          _infoRow(
            Icons.calendar_today_outlined,
            'Departs',
            DateFormat('MMM d, yyyy').format(booking.date),
          ),
          _div(),
          _infoRow(
            Icons.pets_rounded,
            'Horses',
            '${booking.horseCount} Horse${booking.horseCount > 1 ? 's' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(booking.notes!, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _slotWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Accepting this will automatically reduce your load #${booking.relatedLoadId} by ${booking.horseCount} slots.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.successGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.to(
              () => BookingResultShippingScreen(
                booking: booking,
                isConfirmed: true,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.to(
              () => BookingResultShippingScreen(
                booking: booking,
                isConfirmed: false,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.softRed,
              side: const BorderSide(color: AppColors.softRed),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Decline Request',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey400),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _div() => const Divider(height: 1, color: AppColors.grey100);
}
