import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class OperationsComplianceShippingScreen extends StatefulWidget {
  const OperationsComplianceShippingScreen({super.key});

  @override
  State<OperationsComplianceShippingScreen> createState() =>
      _OperationsComplianceShippingScreenState();
}

class _OperationsComplianceShippingScreenState
    extends State<OperationsComplianceShippingScreen> {
  bool _isAcceptingRequests = true;

  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  DateTime? _insuranceExpiry;
  bool _hasFile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            _buildStatusCard(),
            const SizedBox(height: 32),

            _sectionTitle(
              'Insurance & Compliance',
              Icons.verified_user_outlined,
            ),
            _buildInsuranceCard(),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Save Changes',
              onPressed: () {
                Get.back();
                Get.snackbar('Success', 'Status and documents updated');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isAcceptingRequests
            ? AppColors.successGreen.withOpacity(0.05)
            : AppColors.softRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAcceptingRequests
              ? AppColors.successGreen.withOpacity(0.2)
              : AppColors.softRed.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isAcceptingRequests
                    ? Icons.check_circle
                    : Icons.pause_circle_filled,
                color: _isAcceptingRequests
                    ? AppColors.successGreen
                    : AppColors.softRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isAcceptingRequests
                      ? 'Accepting New Requests'
                      : 'Requests Paused',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _isAcceptingRequests
                        ? AppColors.successGreen
                        : AppColors.softRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isAcceptingRequests,
                onChanged: (v) => setState(() => _isAcceptingRequests = v),
                activeColor: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isAcceptingRequests
                ? 'Trainers can see your profile and send new booking requests.'
                : 'Pausing hides you from new booking requests until re-enabled. Your existing bookings remain active.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.deepNavy),
              const SizedBox(width: 12),
              Text('Insurance Document', style: AppTextStyles.titleMedium),
              const Spacer(),
              if (_hasFile)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _uploadButton(),
          const SizedBox(height: 24),

          InkWell(
            onTap: () async {
              final date = await AppDatePicker.pickDate(context);
              if (date != null) setState(() => _insuranceExpiry = date);
            },
            child: _fakeDateInput(
              label: 'Expiration Date *',
              value: _insuranceExpiry == null
                  ? 'Select Date'
                  : DateFormat('MMM d, yyyy').format(_insuranceExpiry!),
              isExpired:
                  _insuranceExpiry != null &&
                  _insuranceExpiry!.isBefore(DateTime.now()),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Provider Name',
            controller: _providerController,
            hint: 'e.g. Hartford Equine Specialty',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Policy Number',
            controller: _policyNumberController,
            hint: 'e.g. POL-9876543',
          ),
        ],
      ),
    );
  }

  Widget _uploadButton() {
    return InkWell(
      onTap: () => setState(() => _hasFile = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.grey300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _hasFile ? Icons.file_present : Icons.cloud_upload_outlined,
              size: 32,
              color: _hasFile ? AppColors.successGreen : AppColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              _hasFile ? 'insurance_policy_final.pdf' : 'Upload PDF or Image',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _hasFile ? AppColors.successGreen : AppColors.grey600,
                fontWeight: _hasFile ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fakeDateInput({
    required String label,
    required String value,
    bool isExpired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isExpired ? AppColors.softRed : AppColors.grey200,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isExpired ? AppColors.softRed.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isExpired ? AppColors.softRed : null,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_month,
                size: 18,
                color: isExpired ? AppColors.softRed : AppColors.grey400,
              ),
            ],
          ),
        ),
        if (isExpired)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Policy Expired',
              style: TextStyle(color: AppColors.softRed, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mutedGold, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              color: AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }
}
