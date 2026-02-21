import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

class InsuranceUploadBodyworkScreen extends StatefulWidget {
  const InsuranceUploadBodyworkScreen({super.key});

  @override
  State<InsuranceUploadBodyworkScreen> createState() =>
      _InsuranceUploadBodyworkScreenState();
}

class _InsuranceUploadBodyworkScreenState
    extends State<InsuranceUploadBodyworkScreen> {
  DateTime? _expirationDate;
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  bool _documentUploaded = false;

  Future<void> _pickDate() async {
    final dt = await AppDatePicker.pickDate(
      context,
      initialDate: _expirationDate,
    );
    if (dt != null) setState(() => _expirationDate = dt);
  }

  void _save() {
    if (!_documentUploaded) {
      Get.snackbar(
        'Required',
        'Please upload a proof of insurance document.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    if (_expirationDate == null) {
      Get.snackbar(
        'Required',
        'Please select the policy expiration date.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      'Saved',
      'Insurance details have been securely saved.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  // Calculate status (mock logic)
  String get _statusLabel {
    if (!_documentUploaded || _expirationDate == null) return 'No File';
    final df = _expirationDate!.difference(DateTime.now()).inDays;
    if (df < 0) return 'Expired';
    if (df < 30) return 'Expiring Soon';
    return 'Insurance on file';
  }

  Color get _statusColor {
    if (!_documentUploaded || _expirationDate == null) return AppColors.grey500;
    final df = _expirationDate!.difference(DateTime.now()).inDays;
    if (df < 0) return AppColors.softRed;
    if (df < 30) return AppColors.mutedGold;
    return AppColors.successGreen;
  }

  IconData get _statusIcon {
    if (!_documentUploaded || _expirationDate == null) return Icons.upload_file;
    final df = _expirationDate!.difference(DateTime.now()).inDays;
    if (df < 0) return Icons.error_outline_rounded;
    if (df < 30) return Icons.warning_amber_rounded;
    return Icons.verified_user_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance & Liability'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Done')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: $_statusLabel',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: _statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'This is for platform verification. Clients only see an "Insurance on file" badge.',
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

            // Upload Document
            Text(
              'Current Insurance Document *',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() => _documentUploaded = true);
                Get.snackbar('File', 'Picker simulated.');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _documentUploaded
                        ? AppColors.successGreen
                        : AppColors.grey200,
                    width: _documentUploaded ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentUploaded
                          ? Icons.task_rounded
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _documentUploaded
                          ? AppColors.successGreen
                          : AppColors.deepNavy,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _documentUploaded
                          ? 'Liability_Policy.pdf'
                          : 'Tap to upload PDF or Image',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _documentUploaded
                            ? AppColors.successGreen
                            : AppColors.deepNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Expiration Date
            Text('Expiration Date *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
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
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _expirationDate != null
                          ? AppDateFormatter.formatDateOnly(_expirationDate!)
                          : 'Select policy expiration',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _expirationDate != null
                            ? AppColors.deepNavy
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Optional Details
            Text('Policy Details (Optional)', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _providerController,
              decoration: InputDecoration(
                labelText: 'Provider Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _policyNumberController,
              decoration: InputDecoration(
                labelText: 'Policy Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upload & Verify',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
