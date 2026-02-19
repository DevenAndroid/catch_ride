import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class VendorAvailabilityScreen extends StatefulWidget {
  const VendorAvailabilityScreen({super.key});

  @override
  State<VendorAvailabilityScreen> createState() =>
      _VendorAvailabilityScreenState();
}

class _VendorAvailabilityScreenState extends State<VendorAvailabilityScreen> {
  bool isAccepting = true;
  DateTime? _availableFrom;
  DateTime? _availableTo;

  Future<void> _pickAvailableFrom() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _availableFrom,
    );
    if (dt != null) setState(() => _availableFrom = dt);
  }

  Future<void> _pickAvailableTo() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _availableTo ?? _availableFrom,
    );
    if (dt != null) setState(() => _availableTo = dt);
  }

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
                color: isAccepting
                    ? AppColors.successGreen.withOpacity(0.1)
                    : AppColors.softRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAccepting
                      ? AppColors.successGreen
                      : AppColors.softRed,
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
                          color: isAccepting
                              ? AppColors.successGreen
                              : AppColors.softRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAccepting
                            ? 'You allow new requests.'
                            : 'Your profile is hidden.',
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

            // Availability Date Range
            Text('Availability Period', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Set when you\'re available for bookings',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),

            // Available From
            Text('Available From', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickAvailableFrom,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _availableFrom != null
                          ? AppDateFormatter.format(_availableFrom!)
                          : 'Select start date & time',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _availableFrom != null
                            ? AppColors.deepNavy
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Available To
            Text('Available To', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickAvailableTo,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _availableTo != null
                          ? AppDateFormatter.format(_availableTo!)
                          : 'Select end date & time',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _availableTo != null
                            ? AppColors.deepNavy
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selected Range Preview
            if (_availableFrom != null && _availableTo != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppDateFormatter.formatRange(
                          _availableFrom!,
                          _availableTo!,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              text: 'Save Availability',
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'Availability updated',
                  backgroundColor: AppColors.successGreen,
                  colorText: Colors.white,
                );
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
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(value, style: AppTextStyles.titleMedium),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }
}
