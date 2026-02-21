import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';

class BookingShippingDetailScreen extends StatelessWidget {
  final VendorBooking booking;
  final bool isVendorView;

  const BookingShippingDetailScreen({
    super.key,
    required this.booking,
    this.isVendorView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Booking Title & Route ──
            Text(
              '${booking.horseCount} Horse${booking.horseCount > 1 ? 's' : ''} ${booking.location}',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            _statusBadge(),
            if (booking.relatedLoadId != null) ...[
              const SizedBox(height: 12),
              _loadReferencePill(),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ── Route & Dates ──
            _sectionTitle('Route & Dates'),
            _infoRow(
              'Pickup',
              booking.pickupAddress ?? booking.location.split('→')[0].trim(),
            ),
            _infoRow(
              'Dropoff',
              booking.dropoffAddress ?? booking.location.split('→')[1].trim(),
            ),
            _infoRow('Dates', _formatDates()),
            const SizedBox(height: 24),

            // ── Party Profile ──
            _sectionTitle(isVendorView ? 'Trainer' : 'Shipper'),
            _profileCard(),
            const SizedBox(height: 32),

            // ── Actions ──
            _buildActionButtons(),
            const SizedBox(height: 32),

            // ── Policies & Payments ──
            _sectionTitle('Policies & Payment'),
            _policyCard(),
            const SizedBox(height: 24),

            // ── Cancel Option ──
            _cancelButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    final c = booking.status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        booking.status.label,
        style: AppTextStyles.labelLarge.copyWith(color: c, fontSize: 12),
      ),
    );
  }

  Widget _loadReferencePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 14,
            color: AppColors.deepNavy,
          ),
          const SizedBox(width: 8),
          Text(
            'Linked to Load: #${booking.relatedLoadId}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.deepNavy.withOpacity(0.1),
            child: Text(
              booking.clientName[0],
              style: const TextStyle(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVendorView ? booking.clientName : 'Cole Equine Transport',
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  isVendorView ? booking.clientRole : 'Professional Shipper',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.snackbar('Messages', 'Opening chat thread...'),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepNavy,
              side: const BorderSide(color: AppColors.deepNavy),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.snackbar('Edit', 'Re-opening booking form...'),
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: const Text('Change'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepNavy,
              side: const BorderSide(color: AppColors.deepNavy),
            ),
          ),
        ),
      ],
    );
  }

  Widget _policyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _policyRow(
            Icons.payments_outlined,
            'Payments',
            booking.paymentMethods?.join(', ') ?? 'Cash, Zelle',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          _policyRow(
            Icons.policy_outlined,
            'Cancellation',
            booking.cancellationPolicy ?? 'Flexible',
          ),
        ],
      ),
    );
  }

  Widget _policyRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showCancelDialog(),
        child: const Text(
          'Cancel Booking',
          style: TextStyle(
            color: AppColors.softRed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    Get.defaultDialog(
      title: 'Cancel Booking?',
      middleText:
          'If you cancel, the slots on the associated load will be restored automatically.',
      textConfirm: 'Confirm Cancel',
      textCancel: 'Close',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.softRed,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'Cancelled',
          'Booking has been cancelled and slots restored.',
        );
      },
    );
  }

  String _formatDates() {
    final start = DateFormat('MMM d, yyyy').format(booking.date);
    return booking.endDate != null ? '$start - ${booking.endDate}' : start;
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
