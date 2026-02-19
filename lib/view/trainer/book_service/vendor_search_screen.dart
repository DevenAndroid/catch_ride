import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/book_service/vendor_public_profile_screen.dart';

class VendorSearchScreen extends StatelessWidget {
  const VendorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Service'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Service Type Filter
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildServiceChip('All', true),
                _buildServiceChip('Groom', false),
                _buildServiceChip('Farrier', false),
                _buildServiceChip('Braiding', false),
                _buildServiceChip('Shipping', false),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildVendorCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        selectedColor: AppColors.deepNavy,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.deepNavy,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Get.to(() => const VendorPublicProfileScreen());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vendor Name ${index + 1}',
                        style: AppTextStyles.titleMedium,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.mutedGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grooming • Braiding',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location/Availability
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: 4),
                      Text('Wellington, FL', style: AppTextStyles.bodySmall),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Available Today',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.successGreen,
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
    );
  }
}
