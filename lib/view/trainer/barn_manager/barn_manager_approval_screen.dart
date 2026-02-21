import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class BarnManagerApprovalScreen extends StatelessWidget {
  const BarnManagerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barn Manager Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Sarah Connor', style: AppTextStyles.headlineMedium),
                  Text(
                    'Applying for Barn Manager',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildInfoSection('Professional Links', [
              _buildLinkItem('Facebook', 'https://facebook.com/sarahconnor'),
              _buildLinkItem('Instagram', '@s_connor_equestrian'),
            ]),

            const SizedBox(height: 24),

            _buildInfoSection('Experience Summary', [
              Text(
                'Over 8 years of experience managing high-end Hunter/Jumper stables in Wellington. Specialized in show logistics and horse care coordination.',
                style: AppTextStyles.bodyMedium,
              ),
            ]),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Approve & Link Account',
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Sarah Connor is now linked to your stable.',
                  backgroundColor: AppColors.successGreen,
                  colorText: Colors.white,
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Decline Request',
              isOutlined: true,
              textColor: AppColors.softRed,
              onPressed: () {
                Get.back();
                Get.snackbar('Declined', 'Application has been declined.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildLinkItem(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: AppColors.deepNavy),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              url,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
