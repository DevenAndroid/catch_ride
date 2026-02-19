
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class VendorAvailabilityScreen extends StatefulWidget {
  const VendorAvailabilityScreen({super.key});

  @override
  State<VendorAvailabilityScreen> createState() => _VendorAvailabilityScreenState();
}

class _VendorAvailabilityScreenState extends State<VendorAvailabilityScreen> {
  bool isAccepting = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAccepting ? AppColors.successGreen.withOpacity(0.1) : AppColors.softRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAccepting ? AppColors.successGreen : AppColors.softRed,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAccepting ? 'Accepting Bookings' : 'Not Accepting',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isAccepting ? AppColors.successGreen : AppColors.softRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAccepting ? 'You allow new requests.' : 'Your profile is hidden.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  Switch(
                    value: isAccepting,
                    onChanged: (val) {
                      setState(() {
                        isAccepting = val;
                      });
                    },
                    activeColor: AppColors.successGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings
            Text('Service Settings', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            
            _buildSettingRow(
              icon: Icons.date_range,
              title: 'Working Days',
              value: 'Mon - Sat',
              onTap: () {},
            ),
            _buildSettingRow(
              icon: Icons.location_on_outlined,
              title: 'Service Area',
              value: 'Wellington, FL + 20mi',
              onTap: () {},
            ),
            _buildSettingRow(
              icon: Icons.work_outline,
              title: 'Service Types',
              value: 'Grooming, Braiding',
              onTap: () {},
            ),
            _buildSettingRow(
              icon: Icons.people_outline,
              title: 'Capacity',
              value: 'Max 5 horses/day',
              onTap: () {},
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: 'Update Calendar',
              isOutlined: true,
              onPressed: () {
                // Open calendar view
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.deepNavy),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      subtitle: Text(value, style: AppTextStyles.titleMedium),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}
