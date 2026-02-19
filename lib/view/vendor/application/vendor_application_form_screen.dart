import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/application/vendor_application_submit_screen.dart';

class VendorApplicationFormScreen extends StatefulWidget {
  final List<String> selectedServices;

  const VendorApplicationFormScreen({
    super.key,
    required this.selectedServices,
  });

  @override
  State<VendorApplicationFormScreen> createState() =>
      _VendorApplicationFormScreenState();
}

class _VendorApplicationFormScreenState
    extends State<VendorApplicationFormScreen> {
  int _currentFormIndex = 0;

  // Form Controllers
  final _businessNameController = TextEditingController();
  final _yearsExpController = TextEditingController();
  final _homeBaseController = TextEditingController();
  final _regionsController = TextEditingController();
  final _rateController = TextEditingController();
  final _bioController = TextEditingController();
  final _referenceController = TextEditingController();
  final _insuranceController = TextEditingController();

  String get _currentService => widget.selectedServices[_currentFormIndex];
  bool get _isLastForm =>
      _currentFormIndex >= widget.selectedServices.length - 1;

  void _nextForm() {
    if (_isLastForm) {
      Get.to(() => const VendorApplicationSubmitScreen());
    } else {
      setState(() {
        _currentFormIndex++;
      });
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _yearsExpController.dispose();
    _homeBaseController.dispose();
    _regionsController.dispose();
    _rateController.dispose();
    _bioController.dispose();
    _referenceController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_currentService Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            if (widget.selectedServices.length > 1) ...[
              Row(
                children: List.generate(widget.selectedServices.length, (i) {
                  final isActive = i <= _currentFormIndex;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.deepNavy
                            : AppColors.grey200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Form ${_currentFormIndex + 1} of ${widget.selectedServices.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Service Title
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getServiceIcon(_currentService),
                    color: AppColors.mutedGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_currentService Service Details',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Business Name
            CustomTextField(
              label: 'Business / Professional Name *',
              hint: 'e.g. Elite Grooming Services',
              controller: _businessNameController,
            ),
            const SizedBox(height: 16),

            // Years Experience
            CustomTextField(
              label: 'Years of Experience *',
              hint: 'e.g. 8',
              controller: _yearsExpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Home Base Location
            CustomTextField(
              label: 'Home Base (City, State) *',
              hint: 'e.g. Wellington, FL',
              controller: _homeBaseController,
            ),
            const SizedBox(height: 16),

            // Service Regions
            CustomTextField(
              label: 'Service Regions',
              hint: 'Cities or show venues you travel to',
              controller: _regionsController,
            ),
            const SizedBox(height: 16),

            // Rate
            CustomTextField(
              label: 'Starting Rate (\$) *',
              hint: 'e.g. 150',
              controller: _rateController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Bio / Description
            CustomTextField(
              label: 'Service Description',
              hint: 'Describe your experience and specialties...',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Professional Reference
            CustomTextField(
              label: 'Professional Reference',
              hint: 'Name and contact of a reference',
              controller: _referenceController,
            ),
            const SizedBox(height: 16),

            // Insurance Info
            CustomTextField(
              label: 'Insurance (if applicable)',
              hint: 'Insurance provider and policy number',
              controller: _insuranceController,
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: _isLastForm
                  ? 'Submit Application'
                  : 'Next: ${widget.selectedServices[_currentFormIndex + 1]}',
              onPressed: _nextForm,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'Groom':
        return Icons.cleaning_services;
      case 'Clipping':
        return Icons.content_cut;
      case 'Braiding':
        return Icons.auto_awesome;
      case 'Farrier':
        return Icons.handyman;
      case 'Bodywork':
        return Icons.spa;
      case 'Shipping':
        return Icons.local_shipping;
      default:
        return Icons.work;
    }
  }
}
