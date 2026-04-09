import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/api_service.dart';

class ClippingServiceRatesTab extends StatefulWidget {
  const ClippingServiceRatesTab({super.key});

  @override
  State<ClippingServiceRatesTab> createState() => _ClippingServiceRatesTabState();
}

class _ClippingServiceRatesTabState extends State<ClippingServiceRatesTab> {
  final controller = Get.find<GroomViewProfileController>();
  
  final RxList<Map<String, dynamic>> clippingServices = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> addOnServices = <Map<String, dynamic>>[].obs;

  final List<String> defaultClippingServices = [
    'Full Body Clip',
    'Hunter Clip',
    'Trace Clip',
    'Bib Clip',
    'Irish Clip',
    'Touch Ups'
  ];

  final List<String> defaultAddOns = [
    'Bath & Clip Prep',
    'Show Clean Up',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final existing = controller.groomingServices; // Reusing the same underlying list for the active role
    
    final Map<String, Map<String, dynamic>> existingMap = {};
    for (var s in existing) {
      if (s is Map<String, dynamic>) {
        existingMap[s['name'] ?? ''] = s;
      }
    }

    // Initialize Clipping Services
    final List<Map<String, dynamic>> initialClipping = [];
    for (var name in defaultClippingServices) {
      final found = existingMap[name];
      initialClipping.add({
        'name': name,
        'price': TextEditingController(text: found?['price']?.toString() ?? '0'),
        'isSelected': (found != null).obs,
      });
      existingMap.remove(name);
    }
    clippingServices.assignAll(initialClipping);

    // Initialize Add-Ons
    final List<Map<String, dynamic>> initialAddOns = [];
    for (var name in defaultAddOns) {
      final found = existingMap[name];
      initialAddOns.add({
        'name': name,
        'price': TextEditingController(text: found?['price']?.toString() ?? '0'),
        'isSelected': (found != null).obs,
      });
      existingMap.remove(name);
    }
    
    // Any remaining ones go to main clipping services
    existingMap.forEach((key, value) {
      clippingServices.add({
        'name': key,
        'price': TextEditingController(text: value['price']?.toString() ?? '0'),
        'isSelected': true.obs,
      });
    });
    
    addOnServices.assignAll(initialAddOns);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildServiceCard(
          title: 'Clipping Services',
          subtitle: 'Select the services you offer and set your pricing',
          services: clippingServices,
          onAddTap: () => _showAddServiceBottomSheet(isAddOn: false),
        ),
        const SizedBox(height: 20),
        _buildServiceCard(
          title: 'Add - Ons',
          subtitle: 'Optional services offered in addition to standard clipping',
          services: addOnServices,
          onAddTap: () => _showAddServiceBottomSheet(isAddOn: true),
        ),
        const SizedBox(height: 32),
        _buildBottomButtons(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required RxList<Map<String, dynamic>> services,
    required VoidCallback onAddTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          CommonText(subtitle, fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Obx(() => Column(
                children: services.map((service) => _buildServiceItem(service)).toList(),
              )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAddTap,
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                SizedBox(width: 4),
                CommonText(
                  'Add Service',
                  color: AppColors.linkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSizes.size14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Obx(() {
      final isSelected = service['isSelected'].value;
      final TextEditingController priceCtrl = service['price'];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => service['isSelected'].value = !service['isSelected'].value,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF001149) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF001149) : const Color(0xFFD0D5DD),
                            width: 2,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              service['name'],
                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            const CommonText(
                              'Per horse',
                              fontSize: AppTextSizes.size12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 90,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: AppTextSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.textPrimary : const Color(0xFF98A2B3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAddServiceBottomSheet({required bool isAddOn}) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Add More Service', fontSize: 22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            CommonTextField(label: 'Service', hintText: 'Enter service name', controller: nameController),
            const SizedBox(height: 20),
            const CommonText('Price per horse', fontSize: 14, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.borderLight))),
                    child: const CommonText('\$', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '0', border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: CommonButton(text: 'Cancel', backgroundColor: Colors.white, textColor: AppColors.textPrimary, borderColor: AppColors.borderLight, onPressed: () => Get.back())),
                const SizedBox(width: 16),
                Expanded(child: CommonButton(text: 'Save', onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final target = isAddOn ? addOnServices : clippingServices;
                    target.add({
                      'name': nameController.text,
                      'price': TextEditingController(text: priceController.text),
                      'isSelected': true.obs,
                    });
                    Get.back();
                  }
                })),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            text: 'Cancel',
            backgroundColor: Colors.white,
            textColor: AppColors.textPrimary,
            borderColor: AppColors.borderLight,
            onPressed: () => Get.back(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CommonButton(
            text: 'Save',
            onPressed: () async {
              final payload = [
                ...clippingServices,
                ...addOnServices
              ]
              .where((s) => s['isSelected'].value)
              .map((s) => {
                'name': s['name'],
                'price': double.tryParse(s['price'].text) ?? 0.0,
              })
              .toList();
              
              // Reusing braiding update method because it basically updates the 'services' list in the payload
              // But we need to make sure backend handles 'clipping' key
              final success = await _updateClippingServices(payload);
              if (success) Get.back();
            },
          ),
        ),
      ],
    );
  }
  
  // Local implementation since controller might not have it yet or we need special handling
  Future<bool> _updateClippingServices(List<Map<String, dynamic>> services) async {
    try {
      controller.isLoading.value = true;
      final vendorId = controller.vendorData['_id'];
      
      final payload = {
        'servicesData': {
          'clipping': {
            'profileData': {
              'services': services,
            }
          }
        }
      };

      final response = await Get.find<ApiService>().putRequest('/vendors/$vendorId', payload);
      if (response.statusCode == 200) {
        await controller.fetchProfile();
        Get.snackbar('Success', 'Clipping services updated successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', response.body['message'] ?? 'Failed to update services', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      debugPrint('Update clipping services error: $e');
      return false;
    } finally {
      controller.isLoading.value = false;
    }
  }
}
