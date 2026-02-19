import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class _ServiceRate {
  String name;
  String rate;
  bool enabled;

  _ServiceRate({required this.name, required this.rate, this.enabled = true});
}

class EditServicesRatesScreen extends StatefulWidget {
  const EditServicesRatesScreen({super.key});

  @override
  State<EditServicesRatesScreen> createState() =>
      _EditServicesRatesScreenState();
}

class _EditServicesRatesScreenState extends State<EditServicesRatesScreen> {
  final List<_ServiceRate> _services = [
    _ServiceRate(name: 'Full Day Grooming', rate: '200'),
    _ServiceRate(name: 'Braiding (Mane + Tail)', rate: '65'),
    _ServiceRate(name: 'Full Body Clipping', rate: '150'),
    _ServiceRate(name: 'Show Prep (Half Day)', rate: '120'),
  ];

  final _newServiceNameController = TextEditingController();
  final _newServiceRateController = TextEditingController();

  @override
  void dispose() {
    _newServiceNameController.dispose();
    _newServiceRateController.dispose();
    super.dispose();
  }

  void _addService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add New Service',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newServiceNameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g. Tail Wrap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newServiceRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Rate (\$)',
                  hintText: 'e.g. 45',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _newServiceNameController.text.trim();
                    final rate = _newServiceRateController.text.trim();
                    if (name.isNotEmpty && rate.isNotEmpty) {
                      setState(() {
                        _services.add(_ServiceRate(name: name, rate: rate));
                      });
                      _newServiceNameController.clear();
                      _newServiceRateController.clear();
                      Navigator.pop(context);
                    } else {
                      Get.snackbar(
                        'Required',
                        'Please fill in both fields',
                        backgroundColor: AppColors.softRed,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Service',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteService(int index) {
    if (_services.length <= 1) {
      Get.snackbar(
        'Required',
        'You must have at least one service',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service?'),
        content: Text(
          'Remove "${_services[index].name}" from your service list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _services.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.softRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Rates'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Saved',
                'Services & rates updated',
                backgroundColor: AppColors.successGreen,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mutedGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mutedGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.mutedGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These rates are shown on your public profile. You can enable/disable individual services.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _services.removeAt(oldIndex);
                  _services.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceTile(service, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addService,
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
    );
  }

  Widget _buildServiceTile(_ServiceRate service, int index) {
    final rateController = TextEditingController(text: service.rate);

    return Container(
      key: ValueKey('service_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: service.enabled ? Colors.white : AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: service.enabled ? AppColors.grey200 : AppColors.grey300,
        ),
        boxShadow: service.enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Drag Handle
              const Icon(Icons.drag_handle, color: AppColors.grey400, size: 20),
              const SizedBox(width: 8),
              // Service Name
              Expanded(
                child: Text(
                  service.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: service.enabled
                        ? AppColors.textPrimary
                        : AppColors.grey500,
                    decoration: service.enabled
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
              // Enable/Disable Toggle
              Switch(
                value: service.enabled,
                onChanged: (val) {
                  setState(() => service.enabled = val);
                },
                activeColor: AppColors.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 28), // Align with text above
              // Rate Editor
              SizedBox(
                width: 120,
                child: TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  enabled: service.enabled,
                  onChanged: (val) => service.rate = val,
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const Spacer(),
              // Delete Button
              IconButton(
                onPressed: () => _deleteService(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.softRed,
                  size: 20,
                ),
                tooltip: 'Remove service',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
