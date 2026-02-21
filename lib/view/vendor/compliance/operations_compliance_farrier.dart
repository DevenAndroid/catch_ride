import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_farrier.dart';

class OperationsComplianceFarrierScreen extends StatefulWidget {
  const OperationsComplianceFarrierScreen({super.key});

  @override
  State<OperationsComplianceFarrierScreen> createState() =>
      _OperationsComplianceFarrierScreenState();
}

class _OperationsComplianceFarrierScreenState
    extends State<OperationsComplianceFarrierScreen> {
  bool _acceptingRequests = true;

  // Insurance State
  bool _hasInsuranceOnFile = true;
  final _providerController = TextEditingController(
    text: 'Equine Guard Insurance',
  );
  final _policyNumberController = TextEditingController(text: 'POL-123456789');
  final _expiryDateController = TextEditingController(text: '12-31-2024');

  @override
  void dispose() {
    _providerController.dispose();
    _policyNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations & Compliance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Service Status', Icons.power_settings_new),
            _note('Control your visibility for new booking requests.'),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _acceptingRequests
                    ? AppColors.successGreen.withOpacity(0.05)
                    : AppColors.softRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _acceptingRequests
                      ? AppColors.successGreen.withOpacity(0.2)
                      : AppColors.softRed.withOpacity(0.2),
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  _acceptingRequests
                      ? 'Accepting new requests'
                      : 'Paused / Not accepting',
                ),
                subtitle: Text(
                  _acceptingRequests
                      ? 'Your profile is visible in search and trainers can send requests.'
                      : 'Pausing hides you from new booking requests until re-enabled.',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _acceptingRequests,
                activeColor: AppColors.successGreen,
                onChanged: (v) => setState(() => _acceptingRequests = v),
              ),
            ),
            const SizedBox(height: 32),

            _sectionTitle('Availability Shortcut', Icons.event_available),
            _note(
              'Quickly jump to manage your calendar and geographic windows.',
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Manage Availability',
              onPressed: () => Get.to(() => const AvailabilityFarrierScreen()),
              isOutlined: true,
            ),
            const SizedBox(height: 32),

            _sectionTitle('Insurance Management', Icons.verified_user_outlined),
            _note(
              'Keep your liability insurance on file for a trust badge on your profile.',
            ),
            const SizedBox(height: 16),

            if (_hasInsuranceOnFile)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.successGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insurance on file',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            'Expires: ${_expiryDateController.text}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified, color: AppColors.mutedGold),
                  ],
                ),
              ),

            CustomTextField(
              label: 'Insurance Provider',
              hint: 'Company Name',
              controller: _providerController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Policy Number',
              hint: 'e.g. 12345ABC',
              controller: _policyNumberController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Expiration Date *',
              hint: 'MM-DD-YYYY',
              controller: _expiryDateController,
            ),
            const SizedBox(height: 16),

            _label('Insurance Document (PDF/Image)'),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey200,
                  style: BorderStyle.none,
                ), // dashed border would be nice but simple box for now
              ),
              child: InkWell(
                onTap: () => Get.snackbar('Upload', 'Opening file picker...'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, color: AppColors.grey400),
                    const SizedBox(height: 4),
                    Text(
                      'Upload New Policy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Save Operational Settings',
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepNavy, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.deepNavy),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: AppTextStyles.labelLarge),
  );
  Widget _note(String text) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
  );
}
