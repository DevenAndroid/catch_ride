import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class _ServiceConfig {
  final String label;
  bool isEnabled;
  final TextEditingController priceController;

  _ServiceConfig({
    required this.label,
    this.isEnabled = false,
    String? initialPrice,
  }) : priceController = TextEditingController(text: initialPrice);

  void dispose() {
    priceController.dispose();
  }
}

class _CustomService {
  final TextEditingController nameController;
  final TextEditingController priceController;

  _CustomService({String? name, String? price})
    : nameController = TextEditingController(text: name),
      priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class ServicesRatesClippingScreen extends StatefulWidget {
  const ServicesRatesClippingScreen({super.key});

  @override
  State<ServicesRatesClippingScreen> createState() =>
      _ServicesRatesClippingScreenState();
}

class _ServicesRatesClippingScreenState
    extends State<ServicesRatesClippingScreen> {
  // Services directly derived from profile completion logic
  final List<_ServiceConfig> _services = [
    _ServiceConfig(
      label: 'Full Body Clip',
      isEnabled: true,
      initialPrice: '150',
    ),
    _ServiceConfig(label: 'Hunter Clip', isEnabled: true, initialPrice: '120'),
    _ServiceConfig(label: 'Trace Clip', isEnabled: false),
    _ServiceConfig(label: 'Bib Clip', isEnabled: false),
    _ServiceConfig(label: 'Irish Clip', isEnabled: false),
    _ServiceConfig(label: 'Touch Ups', isEnabled: true, initialPrice: '40'),
    _ServiceConfig(label: 'Add - Ons', isEnabled: false),
    _ServiceConfig(
      label: 'Show clean up (Bridle/whiskers)',
      isEnabled: true,
      initialPrice: '30',
    ),
    _ServiceConfig(
      label: 'Bath + Clip Prep',
      isEnabled: true,
      initialPrice: '50',
    ),
  ];

  final List<_CustomService> _customServices = [
    _CustomService(name: 'Leg Whitening', price: '25'),
  ];

  @override
  void dispose() {
    for (var s in _services) {
      s.dispose();
    }
    for (var c in _customServices) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    Get.snackbar(
      'Saved',
      'Services and rates updated successfully.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services & Rates'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage the services you offer and your starting prices. These will be visible to trainers requesting bookings.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),

            // Default services list
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 24),

            // Custom Services
            Text('Other Services', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            ..._customServices.map((c) => _buildCustomServiceRow(c)),
            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                setState(() => _customServices.add(_CustomService()));
              },
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Service',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
            const SizedBox(height: 48),

            CustomButton(text: 'Save Changes', onPressed: _save),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(_ServiceConfig s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: s.isEnabled,
            activeColor: AppColors.deepNavy,
            onChanged: (v) => setState(() => s.isEnabled = v ?? false),
          ),
          Expanded(child: Text(s.label, style: AppTextStyles.bodyMedium)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: s.priceController,
              enabled: s.isEnabled,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Rate',
                isDense: true,
                filled: true,
                fillColor: s.isEnabled ? Colors.white : AppColors.grey50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServiceRow(_CustomService c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: c.nameController,
              decoration: const InputDecoration(
                hintText: 'Custom Service Name',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextField(
              controller: c.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: 'Rate',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.softRed,
            ),
            onPressed: () {
              setState(() => _customServices.remove(c));
            },
          ),
        ],
      ),
    );
  }
}
