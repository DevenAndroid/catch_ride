import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_bodywork.dart';

final List<Map<String, dynamic>> _mockBodyworkBookings = [
  {
    'id': 'BK-BW01',
    'clientName': 'Sarah Williams',
    'horseName': 'Midnight Star',
    'service': 'Sports Massage & PEMF',
    'date': DateTime(2026, 3, 5, 14, 0),
    'location': 'Wellington Equestrian Center (Stall 4A)',
    'rate': '\$220',
    'status': 'confirmed',
    'notes': 'He usually gets tense in the hindquarters.',
  },
  {
    'id': 'BK-BW02',
    'clientName': 'Emily Johnson',
    'horseName': 'Apollo',
    'service': 'Chiropractic Adjustment',
    'date': DateTime(2026, 3, 7, 9, 30),
    'location': 'Showgrounds (Ring 2 Warmup area)',
    'rate': '\$180',
    'status': 'confirmed',
    'notes': 'Pre-show checkup.',
  },
];

class BookingsListBodyworkScreen extends StatelessWidget {
  const BookingsListBodyworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Bookings'), centerTitle: true),
      body: _mockBodyworkBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy_rounded,
                    size: 60,
                    color: AppColors.grey300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming bookings',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockBodyworkBookings.length,
              itemBuilder: (context, index) {
                final b = _mockBodyworkBookings[index];
                return GestureDetector(
                  onTap: () =>
                      Get.to(() => BookingDetailBodyworkScreen(bookingData: b)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b['date'].toString().split(
                                ' ',
                              )[0], // simple mock format
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.deepNavy,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Confirmed',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.successGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${b['service']}',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${b['clientName']} • ${b['horseName']}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              b['location'],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
