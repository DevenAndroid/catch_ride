import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrainerRequestsView extends StatelessWidget {
  const TrainerRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Requests',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, // As per image
        itemBuilder: (context, index) {
          return const RequestCard();
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(AppConstants.dummyImageUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CommonText(
                      'Trainer : Mark Lee',
                      fontWeight: FontWeight.bold,
                      fontSize: AppTextSizes.size14,
                    ),
                    CommonText(
                      'Professional Horse Trainer',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Info Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F7FF), // Very light blue
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horse Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    AppConstants.dummyImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Horse Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            'Starfire',
                            fontWeight: FontWeight.bold,
                            fontSize: AppTextSizes.size16,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const CommonText(
                              'For Sale',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          CommonText(
                            'Tampa, FL, United States',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          CommonText(
                            '01 Apr - 07 Apr 2026',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13CA8B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CommonText(
                        'Accept',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const CommonText(
                        'Reject',
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
