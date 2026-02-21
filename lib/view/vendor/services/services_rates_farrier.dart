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
  final TextEditingController notesController;

  _ServiceConfig({
    required this.label,
    this.isEnabled = false,
    String price = '',
  }) : priceController = TextEditingController(text: price),
       notesController = TextEditingController();

  void dispose() {
    priceController.dispose();
    notesController.dispose();
  }
}

class _CustomItem {
  final TextEditingController nameController;
  final TextEditingController priceController;

  _CustomItem({String name = '', String price = ''})
    : nameController = TextEditingController(text: name),
      priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class ServicesRatesFarrierScreen extends StatefulWidget {
  const ServicesRatesFarrierScreen({super.key});

  @override
  State<ServicesRatesFarrierScreen> createState() =>
      _ServicesRatesFarrierScreenState();
}

class _ServicesRatesFarrierScreenState
    extends State<ServicesRatesFarrierScreen> {
  final List<_ServiceConfig> _services = [
    _ServiceConfig(label: 'Trimming', isEnabled: true, price: '60'),
    _ServiceConfig(label: 'Front Shoes', isEnabled: true, price: '180'),
    _ServiceConfig(label: 'Hind Shoes', isEnabled: false),
    _ServiceConfig(label: 'Full Set', isEnabled: true, price: '320'),
    _ServiceConfig(
      label: 'Corrective / Therapeutic Work',
      isEnabled: true,
      price: '250',
    ),
    _ServiceConfig(label: 'Glue-on Shoes', isEnabled: false),
    _ServiceConfig(
      label: 'Specialty Shoes (bar shoes, pads, wedges, etc.)',
      isEnabled: false,
    ),
    _ServiceConfig(
      label: 'Barefoot / Natural Trim Specialist',
      isEnabled: false,
    ),
  ];
  final List<_CustomItem> _customServices = [];

  final List<_ServiceConfig> _addOns = [
    _ServiceConfig(label: 'Aluminum', isEnabled: true, price: '40'),
  ];
  final List<_CustomItem> _customAddOns = [];

  @override
  void dispose() {
    for (var s in _services) s.dispose();
    for (var c in _customServices) c.dispose();
    for (var a in _addOns) a.dispose();
    for (var c in _customAddOns) c.dispose();
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
      appBar: AppBar(title: const Text('Services & Rates'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your service offerings and starting rates. These will be visible to trainers on your profile.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            _sectionTitle('Standard Services', Icons.handyman_outlined),
            ..._services.map((s) => _buildServiceRow(s)),
            const SizedBox(height: 16),
            Text('Custom Services', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._customServices.map((c) => _buildCustomRow(c, _customServices)),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _customServices.add(_CustomItem())),
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Service',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
            const SizedBox(height: 32),

            _sectionTitle('Add-Ons', Icons.add_circle_outline),
            ..._addOns.map((a) => _buildServiceRow(a)),
            const SizedBox(height: 16),
            Text('Custom Add-Ons', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._customAddOns.map((c) => _buildCustomRow(c, _customAddOns)),
            TextButton.icon(
              onPressed: () => setState(() => _customAddOns.add(_CustomItem())),
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text(
                'Add Custom Add-On',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(text: 'Save Changes', onPressed: _save),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(_ServiceConfig s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: s.isEnabled,
                activeColor: AppColors.deepNavy,
                onChanged: (v) => setState(() => s.isEnabled = v ?? false),
              ),
              Expanded(child: Text(s.label, style: AppTextStyles.titleMedium)),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: s.priceController,
                  enabled: s.isEnabled,
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
          if (s.isEnabled) ...[
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Optional Notes',
              hint: 'Context for this service...',
              controller: s.notesController,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomRow(_CustomItem item, List<_CustomItem> list) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: item.nameController,
              decoration: const InputDecoration(
                hintText: 'Item Name',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextField(
              controller: item.priceController,
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
            onPressed: () => setState(() => list.remove(item)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
