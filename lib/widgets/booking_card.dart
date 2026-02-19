import 'package:flutter/material.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText = booking.status.name.toUpperCase();

    switch (booking.status) {
      case BookingStatus.requested:
        statusColor = AppColors.mutedGold;
        break;
      case BookingStatus.accepted:
        statusColor = AppColors.successGreen;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.deepNavy;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        statusColor = AppColors.softRed;
        break;
    }

    String dateRange = DateFormat('MMM d').format(booking.startDate);
    if (booking.endDate.day != booking.startDate.day) {
      dateRange += ' - ${DateFormat('MMM d').format(booking.endDate)}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Image + Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grey200,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTypeBadge(booking.type),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusText,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateRange,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey500,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            if (booking.price > 0)
                              Text(
                                '\$${booking.price.toStringAsFixed(0)}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BookingType type) {
    String text;
    Color color;

    switch (type) {
      case BookingType.vendorService:
        text = 'VENDOR';
        color = Colors.purple;
        break;
      case BookingType.horseTrialIncoming:
        text = 'TRIAL REQ';
        color = Colors.orange;
        break;
      case BookingType.horseTrialOutgoing:
        text = 'TRIAL OUT';
        color = Colors.blue;
        break;
      case BookingType.weeklyLeaseIncoming:
        text = 'LEASE REQ';
        color = Colors.orange;
        break;
      case BookingType.weeklyLeaseOutgoing:
        text = 'LEASE OUT';
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
