
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('Booking #1042', style: AppTextStyles.headlineMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.deepNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Horse Info
            _buildSectionHeader('Horse'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.grey300,
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/150'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text('Thunderbolt', style: AppTextStyles.titleMedium),
              subtitle: Text('Warmblood • 16.2hh', style: AppTextStyles.bodyMedium),
            ),
            const Divider(height: 32),

            // Dates & Time
            _buildSectionHeader('Schedule'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Oct 12 - Oct 14, 2023'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Full Lease'),
            const Divider(height: 32),

            // Pricing
            _buildSectionHeader('Payment'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lease Fee', style: AppTextStyles.bodyLarge),
                Text('\$1,200', style: AppTextStyles.bodyLarge),
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
                Text('\$1,250', style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy)),
              ],
            ),
            const SizedBox(height: 40),

            // Actions
            CustomButton(
              text: 'Accept Booking',
              onPressed: () {
                // Handle accept
                Get.back();
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey700));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.deepNavy),
        const SizedBox(width: 12),
        Text(text, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}
