
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/notifications/notification_permission_screen.dart';
import '../vendor/vendor_main_screen.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'How will you use catch ride?',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.deepNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildRoleCard(
              context: context,
              title: 'Trainer',
              subtitle: 'List horses, manage bookings & reviews',
              icon: Icons.sports_motorsports_rounded, // Best proxy for jockey/rider
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()));
              },
            ),
            const SizedBox(height: 16),
            
            _buildRoleCard(
              context: context,
              title: 'Barn Manager',
              subtitle: 'Handle bookings & logistics for trainers',
              icon: Icons.storefront_rounded,
              onTap: () {
                // Navigate to Barn Manager Registration
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barn Manager Flow Coming Soon')));
              },
            ),
            const SizedBox(height: 16),
            
            _buildRoleCard(
              context: context,
              title: 'Vendor',
              subtitle: 'Offer services like grooming & shipping',
              icon: Icons.handyman_rounded,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VendorMainScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.deepNavy),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}
