import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class _ServiceConfig {
  final String label;
  bool isEnabled;
  final TextEditingController priceController;

  _ServiceConfig({
    required this.label,
    this.isEnabled = false,
    String price = '',
  }) : priceController = TextEditingController(text: price);

  void dispose() {
    priceController.dispose();
  }
}

class ServicesRatesBraiderScreen extends StatefulWidget {
  const ServicesRatesBraiderScreen({super.key});

  @override
  State<ServicesRatesBraiderScreen> createState() =>
      _ServicesRatesBraiderScreenState();
}

class _ServicesRatesBraiderScreenState
    extends State<ServicesRatesBraiderScreen> {
  final List<_ServiceConfig> _services = [
    _ServiceConfig(label: 'Hunter Mane + Tail', isEnabled: true, price: '75'),
    _ServiceConfig(label: 'Hunter Mane Only', isEnabled: true, price: '45'),
    _ServiceConfig(label: 'Hunter Tail Only', isEnabled: true, price: '35'),
    _ServiceConfig(label: 'Jumper Braids'),
    _ServiceConfig(label: 'Dressage Braids'),
    _ServiceConfig(label: 'Mane Pull / Clean Up'),
  ];

  @override
  void dispose() {
    for (var s in _services) {
      s.dispose();
    }
    super.dispose();
  }

  void _save() {
    // Verify enabled services have prices
    for (var s in _services) {
      if (s.isEnabled && s.priceController.text.trim().isEmpty) {
        Get.snackbar(
          'Pricing Required',
          'Please provide a price for ${s.label}.',
          backgroundColor: AppColors.softRed,
          colorText: Colors.white,
        );
        return;
      }
    }

    Get.snackbar(
      'Saved',
      'Your services and rates have been updated.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    Future.delayed(const Duration(seconds: 1), () => Get.back());
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
            _note(
              'Enable the services you offer and set your base price per horse/session. This updates your public profile.',
            ),
            const SizedBox(height: 24),
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 36),
            CustomButton(text: 'Save Changes', onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(_ServiceConfig s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: s.isEnabled
            ? AppColors.deepNavy.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: s.isEnabled ? AppColors.deepNavy : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(
              s.label,
              style: AppTextStyles.titleMedium.copyWith(
                color: s.isEnabled ? AppColors.deepNavy : AppColors.textPrimary,
              ),
            ),
            value: s.isEnabled,
            activeTrackColor: AppColors.deepNavy,
            onChanged: (v) => setState(() => s.isEnabled = v),
          ),
          if (s.isEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CustomTextField(
                label: 'Price per session *',
                hint: '\$ e.g. 75',
                controller: s.priceController,
                keyboardType: TextInputType.number,
              ),
            ),
        ],
      ),
    );
  }

  Widget _note(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.grey600,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
