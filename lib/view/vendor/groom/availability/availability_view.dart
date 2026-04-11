import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/clipping/availability/add_clipping_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/add_farrier_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_add_availability.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';

class AvailabilityView extends StatefulWidget {
  final dynamic initialTab;
  const AvailabilityView({super.key, this.initialTab = 0});

  @override
  State<AvailabilityView> createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<AvailabilityView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(VendorAvailabilityController());
  List<String> _activeServices = [];

  @override
  void initState() {
    super.initState();
    _activeServices = controller.authController.currentUser.value?.vendorServices 
      .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
      .toList() ?? ['Grooming', 'Braiding', 'Clipping', 'Farrier', 'Bodywork'];
    
    // Fallback if empty
    if (_activeServices.isEmpty) _activeServices = ['Grooming'];

    int startIndex = 0;
    if (widget.initialTab is int) {
      startIndex = widget.initialTab;
    } else if (widget.initialTab is String) {
      startIndex = _activeServices.indexWhere(
        (s) => s.toLowerCase() == widget.initialTab.toString().toLowerCase()
      );
      if (startIndex == -1) startIndex = 0;
    }

    if (startIndex >= _activeServices.length) startIndex = 0;

    _tabController = TabController(
      length: _activeServices.length, 
      vsync: this,
      initialIndex: startIndex,
    );
    _tabController.addListener(() {
      setState(() {}); // Re-build to filter correctly when tab changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Availability', fontSize: 24, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  final currentSvc = _activeServices[_tabController.index];
                  if (currentSvc == 'Farrier') {
                    Get.to(() => const AddFarrierAvailabilityView());
                  } else if (currentSvc == 'Clipping') {
                    Get.to(() => const AddClippingAvailabilityView());
                  } else if (currentSvc == 'Braiding') {
                    Get.to(() => const BraidingAddAvailabilityView());
                  } else {
                    int addIndex = currentSvc == 'Grooming' ? 0 : 2;
                    Get.to(() => const AddAvailabilityBlockView(), arguments: addIndex);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 4),
                    CommonText('Add', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ),
          )
        ],
        bottom: _activeServices.length > 1 ? PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabs(),
        ) : null,
      ),
      body: Obx(() {
        final currentService = _activeServices[_tabController.index];
        final filteredBlocks = controller.availabilityBlocks.where(
          (b) => b.serviceTypes.contains(currentService)
        ).toList();

        return RefreshIndicator(
          onRefresh: () async => controller.fetchAvailability(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText('Manage your availability for trainers to discover', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                const SizedBox(height: 16),
                _buildToggleCard(),
                const SizedBox(height: 24),
                const CommonText('Availability Blocks', fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 16),
                if (controller.isLoading.value && controller.availabilityBlocks.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (filteredBlocks.isEmpty)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const CommonText('No availability blocks for this service', color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredBlocks.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: currentService == 'Clipping' 
                      ? ClippingAvailabilityBlockCard(
                          block: b,
                          onEdit: () => Get.to(() => const AddClippingAvailabilityView(), arguments: {'block': b}),
                          onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                        )
                      : (currentService == 'Farrier'
                          ? FarrierAvailabilityBlockCard(
                              block: b,
                              onEdit: () => Get.to(() => const AddFarrierAvailabilityView(), arguments: {'block': b}),
                              onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                            )
                          : (currentService == 'Bodywork'
                              ? BodyworkAvailabilityBlockCard(
                                  block: b,
                                  onEdit: () => Get.to(() => const AddAvailabilityBlockView(), arguments: {'categoryIndex': 3, 'block': b}),
                                  onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                                )
                              : (currentService == 'Braiding'
                                  ? BraidingAvailabilityCard(
                                      availability: b,
                                      onEdit: () => Get.to(() => const BraidingAddAvailabilityView(), arguments: {'block': b}),
                                      onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                                    )
                                  : GroomingAvailabilityCard(
                                      availability: b,
                                      onEdit: () {
                                        final currentSvc = _activeServices[_tabController.index];
                                        int editIndex = currentSvc == 'Grooming' ? 0 : 2;
                                        Get.to(() => const AddAvailabilityBlockView(), arguments: {
                                          'categoryIndex': editIndex,
                                          'block': b
                                        });
                                      },
                                      onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                                    ))))),
                  ).toList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.textPrimary,
        indicatorWeight: 2,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: _activeServices.map((s) => Tab(child: CommonText(s, fontSize: 16, fontWeight: FontWeight.bold))).toList(),
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CommonText('Accepting new requests', fontSize: 16, fontWeight: FontWeight.bold),
                SizedBox(height: 4),
                CommonText('Trainers can send bookings requests', fontSize: 12, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => Switch(
            value: controller.isAcceptingRequests.value,
            onChanged: (val) => controller.toggleAcceptingRequests(val),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF13CA8B),
          )),
        ],
      ),
    );
  }

}

