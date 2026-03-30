import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcomingClientsView extends StatelessWidget {
  const UpcomingClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Upcoming Clients', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildClientCard(
            name: 'Emma Caldwell',
            service: 'Braiding',
            location: 'Tampa, FL, USA',
            date: '01 Apr - 07 Apr 2026',
            note: 'Looking for a reliable braiding!',
            imageUrl: 'https://i.pravatar.cc/100?u=emma',
          ),
          const SizedBox(height: 16),
          _buildClientCard(
            name: 'Mark Lee',
            service: 'Braiding',
            location: 'Tampa, FL, USA',
            date: '01 Apr - 07 Apr 2026',
            note: 'Looking for a reliable braiding!',
            imageUrl: 'https://i.pravatar.cc/100?u=mark',
          ),
          const SizedBox(height: 16),
          _buildClientCard(
            name: 'Mark Lee',
            service: 'Braiding',
            location: 'Tampa, FL, USA',
            date: '01 Apr - 07 Apr 2026',
            note: 'Looking for a reliable braiding!',
            imageUrl: 'https://i.pravatar.cc/100?u=mark',
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard({
    required String name,
    required String service,
    required String location,
    required String date,
    required String note,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CommonImageView(url: imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CommonText('Trainer : $name', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CommonText(service, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        CommonText(location, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        CommonText(date, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText('NOTE : $note', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B4444)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF8B4444)),
                SizedBox(width: 8),
                CommonText('Message', color: Color(0xFF8B4444), fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
