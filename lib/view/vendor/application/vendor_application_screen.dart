import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/application/vendor_application_form_screen.dart';

class VendorApplicationScreen extends StatefulWidget {
  const VendorApplicationScreen({super.key});

  @override
  State<VendorApplicationScreen> createState() =>
      _VendorApplicationScreenState();
}

class _VendorApplicationScreenState extends State<VendorApplicationScreen> {
  final List<String> _allServices = [
    'Groom',
    'Clipping',
    'Braiding',
    'Farrier',
    'Bodywork',
    'Shipping',
  ];

  final List<IconData> _serviceIcons = [
    Icons.cleaning_services,
    Icons.content_cut,
    Icons.auto_awesome,
    Icons.handyman,
    Icons.spa,
    Icons.local_shipping,
  ];

  final Set<String> _selectedServices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What services do you offer?',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select up to 2 service types for your profile.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),

            // Service Selection Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _allServices.length,
              itemBuilder: (context, index) {
                final service = _allServices[index];
                final isSelected = _selectedServices.contains(service);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedServices.remove(service);
                      } else if (_selectedServices.length < 2) {
                        _selectedServices.add(service);
                      } else {
                        Get.snackbar(
                          'Limit Reached',
                          'You can select up to 2 services in MVP',
                          backgroundColor: AppColors.softRed,
                          colorText: Colors.white,
                        );
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.deepNavy.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.deepNavy
                            : AppColors.grey300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.deepNavy.withOpacity(0.1)
                                : AppColors.grey100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _serviceIcons[index],
                            size: 28,
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.deepNavy,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            // Selected Count
            Center(
              child: Text(
                '${_selectedServices.length}/2 selected',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _selectedServices.isNotEmpty
                      ? AppColors.deepNavy
                      : AppColors.grey400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: 'Continue',
              onPressed: _selectedServices.isEmpty
                  ? () {
                      Get.snackbar(
                        'Required',
                        'Please select at least one service',
                        backgroundColor: AppColors.softRed,
                        colorText: Colors.white,
                      );
                    }
                  : () {
                      Get.to(
                        () => VendorApplicationFormScreen(
                          selectedServices: _selectedServices.toList(),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
