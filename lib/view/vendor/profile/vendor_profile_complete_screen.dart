import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/vendor_main_screen.dart';

class VendorProfileCompleteScreen extends StatefulWidget {
  const VendorProfileCompleteScreen({super.key});

  @override
  State<VendorProfileCompleteScreen> createState() =>
      _VendorProfileCompleteScreenState();
}

class _VendorProfileCompleteScreenState
    extends State<VendorProfileCompleteScreen> {
  final _bioController = TextEditingController();
  final _rateGroomController = TextEditingController();
  final _rateBraidController = TextEditingController();
  final _rateClipController = TextEditingController();
  bool _photoUploaded = false;

  @override
  void dispose() {
    _bioController.dispose();
    _rateGroomController.dispose();
    _rateBraidController.dispose();
    _rateClipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Congratulations Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Approved! 🎉',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Complete your profile to go live.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Photo (REQUIRED)
            Text('Profile Photo *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() => _photoUploaded = true);
                  Get.snackbar('Photo', 'Photo picker would open here');
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _photoUploaded
                        ? AppColors.deepNavy.withOpacity(0.1)
                        : AppColors.grey200,
                    border: Border.all(
                      color: _photoUploaded
                          ? AppColors.deepNavy
                          : AppColors.grey300,
                      width: 2,
                    ),
                  ),
                  child: _photoUploaded
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.deepNavy,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.successGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: AppColors.grey500,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upload',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            CustomTextField(
              label: 'Bio / About You *',
              hint: 'Tell clients about your experience and specialties...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Services & Rates
            Text(
              'Services & Rates',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set pricing for each service you offer.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 16),

            _buildRateRow('Full Day Grooming', _rateGroomController, '\$200'),
            const SizedBox(height: 12),
            _buildRateRow(
              'Braiding (Mane + Tail)',
              _rateBraidController,
              '\$65',
            ),
            const SizedBox(height: 12),
            _buildRateRow('Full Body Clipping', _rateClipController, '\$150'),
            const SizedBox(height: 32),

            // Service Area
            Text('Service Area', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.deepNavy,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellington, FL + 20mi radius',
                          style: AppTextStyles.bodyLarge,
                        ),
                        Text(
                          'Tap to update',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            CustomButton(
              text: 'Go Live',
              onPressed: () {
                if (!_photoUploaded) {
                  Get.snackbar(
                    'Required',
                    'Please upload a profile photo',
                    backgroundColor: AppColors.softRed,
                    colorText: Colors.white,
                  );
                  return;
                }
                Get.offAll(() => const VendorMainScreen());
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRateRow(
    String service,
    TextEditingController controller,
    String placeholder,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(service, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: placeholder,
                prefixText: '\$ ',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
