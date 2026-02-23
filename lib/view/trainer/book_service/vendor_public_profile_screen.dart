import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/book_service/book_service_form_screen.dart';

class VendorPublicProfileScreen extends StatelessWidget {
  const VendorPublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with Large Image/Banner
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://via.placeholder.com/400x300',
                fit: BoxFit.cover,
              ),
              title: Text(
                'Professional Grooming Services',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.grey300,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vendor Name', style: AppTextStyles.titleMedium),
                          Text(
                            'Specializes in Show Grooming | Braiding',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20,
                            color: AppColors.mutedGold,
                          ),
                          const SizedBox(width: 4),
                          Text('4.9', style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // About
                  Text('About', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Over 10 years of experience grooming for top Grand Prix jumpers. Available for full show days or specialized clipping services.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Services/Rates
                  Text('Services & Rates', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _buildServiceRow('Full Day Grooming'),
                  _buildServiceRow('Braiding (Mane)'),
                  _buildServiceRow('Clipping (Full Body)'),

                  const SizedBox(height: 24),

                  // Availability Badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Accepting bookings for Oct - Dec',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reviews Preview (Optional - link to full reviews)
                  const SizedBox(height: 32),
                  Text('Recent Review', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: AppColors.grey50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.mutedGold,
                              ),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.mutedGold,
                              ),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.mutedGold,
                              ),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.mutedGold,
                              ),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.mutedGold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"Fantastic job at WEF last week. Highly recommend!"',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Sarah J.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const BookServiceFormScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Request Booking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title, style: AppTextStyles.bodyLarge)],
      ),
    );
  }
}
