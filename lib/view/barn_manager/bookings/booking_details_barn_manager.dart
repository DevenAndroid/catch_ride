import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingDetailsBarnManager extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsBarnManager({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildVendorCard(),
            const SizedBox(height: 32),
            _buildDetailsSection(),
            const SizedBox(height: 32),
            _buildPaymentSummary(),
            const SizedBox(height: 48),
            _buildActions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking #${booking.id}', style: AppTextStyles.titleLarge),
            Text(
              'Placed on behalf of John Smith',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
        _buildStatusBadge(booking.status),
      ],
    );
  }

  Widget _buildVendorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(booking.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.subtitle, style: AppTextStyles.titleMedium),
                Text(
                  'Professional ${booking.type == BookingType.vendorService ? 'Vendor' : 'Partner'}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                Get.snackbar('Profile', 'Opening vendor profile...'),
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          Icons.calendar_today,
          'Date Range',
          '${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d, yyyy').format(booking.endDate)}',
        ),
        const SizedBox(height: 16),
        _infoRow(
          Icons.location_on_outlined,
          'Location / Show',
          booking.location,
        ),
        const SizedBox(height: 16),
        _infoRow(
          Icons.pets,
          'Horse',
          'Midnight Star',
        ), // This should come from booking model if applicable
        const SizedBox(height: 16),
        _infoRow(
          Icons.description_outlined,
          'Requested Service',
          booking.title,
        ),
        if (booking.notes != null) ...[
          const SizedBox(height: 16),
          _infoRow(Icons.notes, 'Notes', booking.notes!),
        ],
      ],
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
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Summary', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        _priceLine('Service Total', '\$${booking.price.toStringAsFixed(0)}'),
        const Divider(height: 24),
        _priceLine(
          'Total',
          '\$${booking.price.toStringAsFixed(0)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _priceLine(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyLarge,
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                )
              : AppTextStyles.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomButton(
          text: 'Open Messages',
          icon: const Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () =>
              Get.snackbar('Messaging', 'Opening linked message thread...'),
        ),
        if (booking.status == BookingStatus.requested) ...[
          const SizedBox(height: 16),
          CustomButton(
            text: 'Cancel Request',
            isOutlined: true,
            textColor: AppColors.softRed,
            onPressed: () =>
                Get.snackbar('Action', 'Requested Trainer to cancel booking.'),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.requested:
        color = AppColors.mutedGold;
        break;
      case BookingStatus.accepted:
        color = AppColors.successGreen;
        break;
      case BookingStatus.completed:
        color = AppColors.deepNavy;
        break;
      default:
        color = AppColors.softRed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}
