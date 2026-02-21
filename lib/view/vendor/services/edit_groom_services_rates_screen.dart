import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class _ServiceConfig {
  final String label;
  bool isEnabled;
  final TextEditingController priceController;
  final TextEditingController notesController;

  _ServiceConfig({required this.label})
    : isEnabled = false,
      priceController = TextEditingController(),
      notesController = TextEditingController();

  void dispose() {
    priceController.dispose();
    notesController.dispose();
  }
}

class _RateInput {
  final String label;
  final TextEditingController controller = TextEditingController();
  _RateInput({required this.label});
}

class EditGroomServicesRatesScreen extends StatefulWidget {
  const EditGroomServicesRatesScreen({super.key});

  @override
  State<EditGroomServicesRatesScreen> createState() =>
      _EditGroomServicesRatesScreenState();
}

class _EditGroomServicesRatesScreenState
    extends State<EditGroomServicesRatesScreen> {
  // Services - Core
  final List<_ServiceConfig> _coreServices = [
    _ServiceConfig(label: 'Stall Upkeep + Daily Care'),
    _ServiceConfig(label: 'Grooming + Turnout'),
    _ServiceConfig(label: 'Tacking + Untacking'),
    _ServiceConfig(label: 'Show Prep (non braiding)'),
    _ServiceConfig(label: 'Wrapping + Bandaging'),
    _ServiceConfig(label: 'Show + Barn Support'),
  ];

  // Services - Jobs
  final List<_ServiceConfig> _jobServices = [
    _ServiceConfig(label: 'Show Grooming'),
    _ServiceConfig(label: 'Fill-In Daily Grooming Support'),
    _ServiceConfig(label: 'Weekly Jobs'),
    _ServiceConfig(label: 'Monthly Jobs'),
    _ServiceConfig(label: 'Seasonal Jobs'),
    _ServiceConfig(label: 'Travel Jobs'),
  ];

  // Horse Handling
  final List<_ServiceConfig> _handlingServices = [
    _ServiceConfig(label: 'Lunging'),
    _ServiceConfig(label: 'Flat Riding (exercise only)'),
  ];

  // Additional Skills
  final List<_ServiceConfig> _additionalSkills = [
    _ServiceConfig(label: 'Braiding'),
    _ServiceConfig(label: 'Clipping'),
  ];

  // Rates
  final List<_RateInput> _rates = [
    _RateInput(label: 'Daily'),
    _RateInput(label: 'Weekly'),
    _RateInput(label: 'Monthly'),
  ];
  bool _ratesVaryByShow = false;

  @override
  void dispose() {
    for (var s in _coreServices) s.dispose();
    for (var s in _jobServices) s.dispose();
    for (var s in _handlingServices) s.dispose();
    for (var s in _additionalSkills) s.dispose();
    for (var r in _rates) r.controller.dispose();
    super.dispose();
  }

  void _save() {
    Get.back();
    Get.snackbar(
      'Success',
      'Services and rates updated successfully.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Services & Rates'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Core Grooming Services',
              Icons.cleaning_services_outlined,
            ),
            ..._coreServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Grooming Jobs', Icons.assignment_outlined),
            ..._jobServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Horse Handling & Riding', Icons.pets_outlined),
            ..._handlingServices.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 24),

            _sectionTitle('Additional Skills', Icons.auto_awesome_outlined),
            ..._additionalSkills.map((s) => _buildServiceCheckbox(s)),
            const SizedBox(height: 32),

            _sectionTitle('Base Rates', Icons.payments_outlined),
            ..._rates.map((r) => _buildRateInput(r)),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Rates vary by show/week'),
              value: _ratesVaryByShow,
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _ratesVaryByShow = v ?? false),
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Save Changes', onPressed: _save),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCheckbox(_ServiceConfig s) {
    return CheckboxListTile(
      title: Text(s.label),
      value: s.isEnabled,
      activeColor: AppColors.deepNavy,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => setState(() => s.isEnabled = v ?? false),
    );
  }

  Widget _buildRateInput(_RateInput r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(r.label, style: AppTextStyles.bodyLarge)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextField(
              controller: r.controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: 'Rate',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mutedGold, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.deepNavy,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
