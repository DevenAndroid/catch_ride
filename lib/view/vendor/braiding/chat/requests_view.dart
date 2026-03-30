import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsView extends StatelessWidget {
  const RequestsView({super.key});

  final List<Map<String, dynamic>> _requests = const [
    {
      'role': 'Barn Manager',
      'name': 'Sarah Jones',
      'barn': 'Willow Crest Stables',
      'location': 'Tampa, FL, USA',
      'dates': '01 Apr - 07 Apr 2026',
      'service': 'Braiding',
      'note': 'Prefer mornings.',
      'avatar': 'https://i.pravatar.cc/150?u=sarah'
    },
    {
      'role': 'Trainer',
      'name': 'Mark Lee',
      'barn': 'Willow Crest Stables',
      'location': 'Tampa, FL, USA',
      'dates': '01 Apr - 07 Apr 2026',
      'service': 'Braiding',
      'note': 'Prefer mornings.',
      'avatar': 'https://i.pravatar.cc/150?u=mark'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Requests', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6ED), // Off-white/Beige as in design
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 26, backgroundImage: NetworkImage(request['avatar'])),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText('${request['role']} : ${request['name']}', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    CommonText(request['barn'], fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 4),
                            CommonText(request['location'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 6),
                            CommonText(request['dates'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                      child: CommonText(request['service'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommonText('Note - ${request['note']}', fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Reject',
                        backgroundColor: Colors.white,
                        textColor: AppColors.textPrimary,
                        borderColor: AppColors.borderMedium,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonButton(
                        text: 'Accept',
                        backgroundColor: AppColors.secondary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
