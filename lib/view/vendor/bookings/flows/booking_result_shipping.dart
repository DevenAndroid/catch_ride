import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_shipping.dart';

class BookingResultShippingScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool isConfirmed;

  const BookingResultShippingScreen({
    super.key,
    required this.booking,
    required this.isConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildIcon(),
              const SizedBox(height: 32),
              Text(
                isConfirmed ? 'Booking Confirmed!' : 'Request Declined',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isConfirmed
                    ? 'You have successfully accepted the booking from ${booking.clientName}. The trainer has been notified.'
                    : 'You have declined the request from ${booking.clientName}. They will be notified accordingly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'View Booking Details',
                onPressed: () => Get.off(
                  () => BookingShippingDetailScreen(booking: booking),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: (isConfirmed ? AppColors.successGreen : AppColors.softRed)
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isConfirmed ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 60,
        color: isConfirmed ? AppColors.successGreen : AppColors.softRed,
      ),
    );
  }
}
