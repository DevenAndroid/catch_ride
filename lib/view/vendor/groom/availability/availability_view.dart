import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/farrier/availability/add_farrier_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailabilityView extends StatefulWidget {
  const AvailabilityView({super.key});

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

    _tabController = TabController(length: _activeServices.length, vsync: this);
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
                  } else {
                    int addIndex = currentSvc == 'Grooming' ? 0 : (currentSvc == 'Braiding' ? 1 : (currentSvc == 'Clipping' ? 2 : 3));
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
                          onEdit: () => Get.to(() => const AddAvailabilityBlockView(), arguments: {'categoryIndex': 2, 'block': b}),
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
                              : _buildAvailabilityCard(b))),
                  )).toList(),
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

  Widget _buildAvailabilityCard(VendorAvailabilityModel b) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(b.dateDisplay, color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(child: CommonText(b.locationDisplay, color: Colors.white70, fontSize: 12, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'edit') {
                      final currentSvc = _activeServices[_tabController.index];
                      if (currentSvc == 'Farrier') {
                        Get.to(() => const AddFarrierAvailabilityView(), arguments: {'block': b});
                      } else {
                        int editIndex = currentSvc == 'Grooming' ? 0 : (currentSvc == 'Braiding' ? 1 : 2);
                        Get.to(() => const AddAvailabilityBlockView(), arguments: {
                          'categoryIndex': editIndex,
                          'block': b
                        });
                      }
                    } else if (value == 'delete') {
                      if (b.id != null) controller.deleteAvailabilityBlock(b.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: CommonText('Edit', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: CommonText('Delete', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.serviceTypes.where((t) => t != 'Grooming' && t != 'Braiding').map((t) => _buildChip(t)).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.pie_chart, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText('Max ${b.maxBookings} Horses', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    const SizedBox(width: 24),
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    CommonText('Available', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ],
                ),
                if (b.notes != null && b.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CommonText(b.notes!, fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: CommonText(label, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    );
  }
}

