import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Re-build to filter correctly when tab changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Availability', fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: GestureDetector(
                onTap: () => Get.to(() => const AddAvailabilityBlockView()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      CommonText('Add', color: Colors.white, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        final currentService = _tabController.index == 0 ? 'Grooming' : 'Braiding';
        final filteredBlocks = controller.availabilityBlocks.where(
          (b) => b.serviceTypes.contains(currentService)
        ).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => controller.fetchAvailability(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText('Manage your availability for trainers to discover', fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                      const SizedBox(height: 16),
                      _buildToggleCard(),
                      const SizedBox(height: 24),
                      const CommonText('Availability Blocks', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
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
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAvailabilityCard(b),
                        )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.textPrimary,
          indicatorWeight: 3,
          tabs: const [
            Tab(child: CommonText('Grooming', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
            Tab(child: CommonText('Braiding', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CommonText('Accepting new requests', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              SizedBox(height: 4),
              CommonText('Trainers can send bookings requests', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
            ],
          ),
          Obx(() => Switch(
            value: controller.isAcceptingRequests.value,
            onChanged: (val) => controller.toggleAcceptingRequests(val),
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(b.dateDisplay, color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        CommonText(b.locationDisplay, color: Colors.white70, fontSize: AppTextSizes.size12),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Handled edit
                    } else if (value == 'delete') {
                      if (b.id != null) controller.deleteAvailabilityBlock(b.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit_outlined, color: AppColors.linkBlue, size: 20),
                          SizedBox(width: 12),
                          CommonText('Edit', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, color: AppColors.accentRed, size: 20),
                          SizedBox(width: 12),
                          CommonText('Delete', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                        ],
                      ),
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
                  children: b.serviceTypes.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: CommonText(t, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.pie_chart_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText('Max ${b.maxBookings} Horses', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    const SizedBox(width: 20),
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText('Available', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                  ],
                ),
                if (b.notes != null && b.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: CommonText(b.notes!, fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
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
}

