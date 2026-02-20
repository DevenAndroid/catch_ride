import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/application/vendor_application_screen.dart';

class VendorApplicationInitialScreen extends StatefulWidget {
  const VendorApplicationInitialScreen({super.key});

  @override
  State<VendorApplicationInitialScreen> createState() =>
      _VendorApplicationInitialScreenState();
}

class _VendorApplicationInitialScreenState
    extends State<VendorApplicationInitialScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      Get.snackbar(
        'Missing Info',
        'Please fill in your basic information first.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    Get.to(() => const VendorApplicationScreen());
  }

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
              'Before we get started',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your basic contact details to begin the vendor application process.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: 'First Name *',
              hint: 'e.g. John',
              controller: _firstNameController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Last Name *',
              hint: 'e.g. Smith',
              controller: _lastNameController,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Phone Number *',
              hint: 'e.g. (555) 123-4567',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Primary Address',
              hint: 'e.g. 123 Equestrian Way, Wellington, FL',
              controller: _addressController,
            ),
            const SizedBox(height: 48),

            CustomButton(text: 'Continue', onPressed: _nextStep),
          ],
        ),
      ),
    );
  }
}
