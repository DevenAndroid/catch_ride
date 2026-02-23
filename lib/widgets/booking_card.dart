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
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.grey200,
                          image: DecorationImage(
                            image: NetworkImage(booking.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
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
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildTypeBadge(booking.type),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey700,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.location,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateRange,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey500,
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
        text = 'Trail';
        color = AppColors.grey600;
        break;
      case BookingType.horseTrialIncoming:
        text = 'For Sale';
        color = AppColors.grey600;
        break;
      case BookingType.horseTrialOutgoing:
        text = 'For Lease';
        color = AppColors.grey600;
        break;
      case BookingType.weeklyLeaseIncoming:
        text = 'For Lease';
        color = AppColors.grey600;
        break;
      case BookingType.weeklyLeaseOutgoing:
        text = 'For Sale';
        color = AppColors.grey600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
