import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_textfield.dart';
import '../../braiding/profile/braiding_service_rates_tab.dart';
import '../../clipping/profile/clipping_service_rates_tab.dart';
import '../../farrier/profile/farrier_service_rates_tab.dart';
import '../../bodywork/profile/bodywork_service_rates_tab.dart';
import '../../../../controllers/vendor/farrier/farrier_details_controller.dart' as fdc; 
import '../../../../controllers/vendor/bodywork/bodywork_details_controller.dart' as bdc;

class ServicesRatesView extends StatefulWidget {
  const ServicesRatesView({super.key});

  @override
  State<ServicesRatesView> createState() => _ServicesRatesViewState();
}

class _ServicesRatesViewState extends State<ServicesRatesView> with TickerProviderStateMixin {
  final controller = Get.put(GroomViewProfileController());
  TabController? _tabController;
  final RxBool isTabReady = false.obs;

  final dailyController = TextEditingController();
  final weeklyController = TextEditingController();
  final monthlyController = TextEditingController();
  
  final RxString weeklyDays = '5'.obs;
  final RxString monthlyDays = '5'.obs;
  
  final RxList<Map<String, dynamic>> additionalServices = <Map<String, dynamic>>[].obs;
  
  // Available Grooming Skills (can expand as needed)
  final List<String> availableGroomingSkills = [
    'Grooming & Turnout',
    'Wrapping & Bandaging',
    'Stall Upkeep & Daily Care',
    'Show Prep (non braiding)',
  ];
  final RxList<String> selectedGroomingSkills = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await controller.fetchProfile();
    final services = controller.allAssignedServices;
    if (services.isNotEmpty) {
      _tabController = TabController(length: services.length, vsync: this);
      _tabController!.addListener(() {
        controller.currentServiceIndex.value = _tabController!.index;
        _updateLocalFields();
      });
      isTabReady.value = true;
    }
    
    _updateLocalFields();
  }

  void _updateLocalFields() {
    dailyController.text = controller.dailyRate;
    weeklyController.text = controller.weeklyRate;
    monthlyController.text = controller.monthlyRate;
    weeklyDays.value = controller.weeklyDays;
    monthlyDays.value = controller.monthlyDays;
    additionalServices.assignAll(controller.additionalServices.map((s) => {...s, 'isSelected': true.obs}).toList());
    
    // Sync grooming skills
    final currentSkills = controller.groomingServices.map((e) => e.toString()).toList();
    selectedGroomingSkills.assignAll(currentSkills);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Services & Rates', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(controller.allAssignedServices.length <= 1 ? 0 : 48),
          child: Obx(() {
            if (!isTabReady.value || controller.allAssignedServices.length <= 1) return const SizedBox.shrink();
            return TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: controller.allAssignedServices.map((s) => Tab(text: s['serviceType'].toString().capitalizeFirst)).toList(),
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final assigned = controller.allAssignedServices;
        if (assigned.isEmpty) return const Center(child: CommonText('No services assigned'));
        if (assigned.length > 1 && !isTabReady.value) return const SizedBox.shrink();

        return TabBarView(
          controller: _tabController,
          children: assigned.map((s) {
            final type = s['serviceType'].toString().toLowerCase();
            if (type.contains('braid')) {
              return const SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: BraidingServiceRatesTab(),
              );
            } else if (type.contains('clip')) {
              return const SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: ClippingServiceRatesTab(),
              );
            } else if (type.contains('farrier')) {
              return const FarrierServiceRatesTab();
            } else if (type.contains('bodywork') || type.contains('body work')) {
              return const BodyworkServiceRatesTab();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildGroomingServicesCard(),
                  const SizedBox(height: 16),
                  _buildRateSection(),
                  const SizedBox(height: 16),
                  _buildAdditionalServicesCard(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }).toList(),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!isTabReady.value) return const SizedBox.shrink();
        final activeType = controller.activeServiceType.toLowerCase();
        // Hide global buttons if tab provides its own (Clipping, Braiding)
        if (activeType.contains('clip') || activeType.contains('braid')) {
          return const SizedBox.shrink();
        }
        return _buildBottomButtons();
      }),
    );
  }

  Widget _buildGroomingServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Grooming Services', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Select the services you offer', fontSize: 14, color: Color(0xFF667085)),
          const SizedBox(height: 20),
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: availableGroomingSkills.map((s) {
                  final isSelected = selectedGroomingSkills.contains(s);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        selectedGroomingSkills.remove(s);
                      } else {
                        selectedGroomingSkills.add(s);
                      }
                    },
                    child: _buildSkillChip(s, isSelected),
                  );
                }).toList(),
              )),
          const SizedBox(height: 20),
          _buildAddServiceLink('Add Service', () => _showAddSkillBS()),
        ],
      ),
    );
  }

  Widget _buildRateSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Rates', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Set your standard rates based on how you typically work', fontSize: 14, color: Color(0xFF667085)),
          const SizedBox(height: 24),
          _buildRateInput('Daily Rate', dailyController),
          const SizedBox(height: 16),
          _buildRateInput('Weekly Rate', weeklyController, showSchedule: true, isWeekly: true),
          const SizedBox(height: 16),
          _buildRateInput('Monthly Rate', monthlyController, showSchedule: true, isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildRateInput(String label, TextEditingController txtController, {bool showSchedule = false, bool isWeekly = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(label, fontSize: 13, color: const Color(0xFF344054), fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFFD0D5DD))),
                  ),
                  child: const CommonText('\$', fontSize: 16, color: Color(0xFF667085)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: txtController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Price', 
                        border: InputBorder.none, 
                        hintStyle: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showSchedule) ...[
            const SizedBox(height: 16),
            const CommonText('Select your standard schedule', fontSize: 12, color: Color(0xFF475467)),
            const SizedBox(height: 8),
            Obx(() {
              final days = isWeekly ? weeklyDays.value : monthlyDays.value;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '5' : monthlyDays.value = '5',
                    child: _buildScheduleChip('5 days week', days == '5'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => isWeekly ? weeklyDays.value = '6' : monthlyDays.value = '6',
                    child: _buildScheduleChip('6 days week', days == '6'),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Additional Services', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
          const SizedBox(height: 4),
          const CommonText('Optional services offered in addition to your standard work', fontSize: 13, color: Color(0xFF667085)),
          const SizedBox(height: 24),
          Obx(() => additionalServices.isEmpty
              ? const CommonText('No additional services', color: Color(0xFF667085))
              : Column(
                  children: additionalServices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Obx(() => _buildServiceItem(
                        index,
                        s['name'] ?? 'Service',
                        s['description'] ?? 'Per horse',
                        s['price']?.toString() ?? '0',
                        (s['isSelected'] as RxBool).value,
                        onToggle: (val) => (s['isSelected'] as RxBool).value = val ?? false,
                      )),
                    );
                  }).toList(),
                )),
          const SizedBox(height: 12),
          _buildAddServiceLink('Add Service', () => _showAddSkillBS()),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : const Color(0xFFD0D5DD)),
      ),
      child: CommonText(
        label, 
        fontSize: 13, 
        color: isSelected ? const Color(0xFF000B48) : const Color(0xFF344054), 
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500
      ),
    );
  }

  Widget _buildScheduleChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: CommonText(
        label, 
        fontSize: 13, 
        color: isSelected ? Colors.white : const Color(0xFF344054), 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
      ),
    );
  }

  Widget _buildServiceItem(int index, String title, String subtitle, String price, bool isSelected, {required Function(bool?) onToggle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: onToggle,
            activeColor: const Color(0xFF000B48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(title, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF101828)),
                CommonText(subtitle, fontSize: 12, color: const Color(0xFF667085)),
              ],
            ),
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CommonText('\$ ', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF667085)),
                Expanded(child: CommonText(price, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF101828))),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF04438), size: 20),
            onPressed: () => additionalServices.removeAt(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAddServiceLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 18, color: Color(0xFF2E90FA)),
          const SizedBox(width: 8),
          CommonText(label, color: const Color(0xFF2E90FA), fontSize: 14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  void _showAddSkillBS() {
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const CommonText('Add Skill', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            CommonTextField(label: 'Skill', hintText: 'Enter your skill', controller: nameController),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText('Price per horse', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                  const SizedBox(height: 12),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: AppColors.borderLight)),
                          ),
                          child: const CommonText('\$', fontSize: AppTextSizes.size18, color: AppColors.textPrimary),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: priceController,
                              decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
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
                    onPressed: () {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        additionalServices.add({
                          'name': nameController.text,
                          'price': priceController.text,
                          'description': 'Per horse',
                          'isSelected': true.obs,
                        });
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Color(0xFFEAECF0)))
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD0D5DD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const CommonText('Cancel', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF344054)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                  final activeType = controller.activeServiceType.toLowerCase();
                  bool success = false;

                  if (activeType.contains('groom')) {
                    success = await controller.updateGroomingRates(
                      services: selectedGroomingSkills.toList(),
                      daily: dailyController.text,
                      weekly: weeklyController.text,
                      weeklyDays: weeklyDays.value,
                      monthly: monthlyController.text,
                      monthlyDays: monthlyDays.value,
                      additional: additionalServices
                          .where((s) => (s['isSelected'] as RxBool).value)
                          .map((s) => {
                                'name': s['name'],
                                'price': s['price'],
                                'description': s['description'],
                              })
                          .toList(),
                    );
                  } else if (activeType.contains('braid')) {
                    // Braiding tab handles its own local state usually or we can pull from its controller
                    // For now, if braiding is active, we might need a generic or specialized save.
                    // Usually tabs like BraidingServiceRatesTab should maybe handle their own save internally
                    // OR we pull from Get.find<BraidingController>()
                    Get.snackbar('Notice', 'Please use the save button within the tab.', backgroundColor: Colors.blue);
                    return;
                  } else if (activeType.contains('farrier')) {
                    final farrierCtrl = Get.find<fdc.FarrierDetailsController>();
                    success = await controller.updateFarrierServices(
                      services: farrierCtrl.farrierServices
                          .where((s) => s['isSelected'].value == true)
                          .map((s) => {
                                'name': s['name'],
                                'price': (s['price'] as TextEditingController).text,
                              })
                          .toList(),
                      addOns: farrierCtrl.addOns
                          .where((s) => s['isSelected'].value == true)
                          .map((s) => {
                                'name': s['name'],
                                'price': (s['price'] as TextEditingController).text,
                              })
                          .toList(),
                      );
                    } else if (activeType.contains('bodywork') || activeType.contains('body work')) {
                      final bodyworkCtrl = Get.find<bdc.BodyworkDetailsController>();
                      success = await controller.updateBodyworkServices(
                        services: bodyworkCtrl.services
                            .where((s) => s['isSelected'] == true)
                            .map((s) => {
                                  'name': s['name'],
                                  'rates': s['rates'],
                                  'note': s['note'],
                                  'trainerPresence': s['trainerPresence'],
                                  'vetApproval': s['vetApproval'],
                                })
                            .toList(),
                      );
                    }

                  if (success) {
                    Get.back();
                  }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF030D3B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const CommonText('Save', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: child,
    );
  }
}
