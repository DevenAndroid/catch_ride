import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    bool isIncoming = booking.isIncoming;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: AppTextStyles.headlineMedium,
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 24),

            // Main Entity Info (Horse or Vendor)
            _buildSectionHeader(
              booking.type == BookingType.vendorService
                  ? 'Vendor'
                  : 'Counterparty',
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Navigate to entity profile
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grey300,
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
                        Text(
                          booking.subtitle,
                          style: AppTextStyles.titleMedium,
                        ),
                        if (booking.type == BookingType.vendorService)
                          Text(
                            'Service Provider',
                            style: AppTextStyles.bodyMedium,
                          )
                        else
                          Text(
                            'View Profile >',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedGold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // Dates & Time
            _buildSectionHeader('Schedule'),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              '${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d, yyyy').format(booking.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.event_note,
              booking.title,
            ), // E.g. Full Lease or Service Name
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, booking.location),

            if (booking.notes != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(booking.notes!, style: AppTextStyles.bodyMedium),
            ],

            const Divider(height: 32),

            // Pricing
            _buildSectionHeader('Payment'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Base Fee', style: AppTextStyles.bodyLarge),
                Text(
                  '\$${booking.price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service Fee', style: AppTextStyles.bodyMedium),
                Text('\$50', style: AppTextStyles.bodyMedium),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.titleLarge),
                Text(
                  '\$${(booking.price + 50).toStringAsFixed(0)}',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Actions
            if (isIncoming && booking.status == BookingStatus.requested) ...[
              CustomButton(
                text: 'Accept Booking',
                onPressed: () {
                  // Handle accept logic (API call)
                  Get.back();
                  Get.snackbar('Success', 'Booking marked as Accepted');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Decline',
                isOutlined: true,
                textColor: AppColors.softRed,
                onPressed: () {
                  // Handle decline
                  Get.back();
                  Get.snackbar(
                    'Declined',
                    'Booking request has been declined.',
                  );
                },
              ),
            ] else if (!isIncoming &&
                booking.status == BookingStatus.requested) ...[
              // Outgoing Pending
              CustomButton(
                text: 'Cancel Request',
                isOutlined: true,
                textColor: AppColors.softRed,
                onPressed: () {
                  Get.back();
                  Get.snackbar('Cancelled', 'Booking request cancelled.');
                },
              ),
            ] else if (booking.status == BookingStatus.accepted) ...[
              CustomButton(
                text: 'Message Counterparty',
                isOutlined: true,
                onPressed: () {
                  // Open Chat
                  Get.snackbar(
                    'Message',
                    'Opening chat with ${booking.subtitle}...',
                  );
                },
              ),
            ],
          ],
        ),
      ),
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
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        color = AppColors.softRed;
        break;
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey700),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.deepNavy),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
      ],
    );
  }
}
