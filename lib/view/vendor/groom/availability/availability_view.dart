import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/models/user_model.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/clipping/availability/add_clipping_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/add_farrier_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_add_availability.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_add_availability.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';

/// Same source as [GroomViewProfile] / [normalizeAssignedServices]: prefer
/// [UserModel.vendorSelectedServiceTypes] ([VendorModel.serviceType]), not every
/// denormalized type in [UserModel.vendorServices].
List<String> _resolveActiveServiceLabels(UserModel? user) {
  if (user == null) return [];

  final selected = user.vendorSelectedServiceTypes.isNotEmpty
      ? List<String>.from(user.vendorSelectedServiceTypes)
      : List<String>.from(user.vendorServices);

  if (selected.isEmpty) return [];

  final map = <String, dynamic>{
    'serviceType': selected,
    'assignedServices':
        selected.map((t) => <String, dynamic>{'serviceType': t}).toList(),
  };

  final normalized = normalizeAssignedServices(map);
  if (normalized.isEmpty) return [];

  return normalized
      .map((m) => (m['serviceType']?.toString() ?? '').trim())
      .where((s) => s.isNotEmpty)
      .map(_titleCaseServiceLabel)
      .toList();
}

String _titleCaseServiceLabel(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return raw;
  return t[0].toUpperCase() + t.substring(1).toLowerCase();
}

class AvailabilityView extends StatelessWidget {
  final dynamic initialTab;
  const AvailabilityView({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VendorAvailabilityController());
    return Obx(() {
      final services = _resolveActiveServiceLabels(controller.authController.currentUser.value);

      if (services.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const CommonText('Availability', fontSize: 24, fontWeight: FontWeight.bold),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: CommonText(
                'Your selected services will appear here after your profile loads. Pull to refresh or open Profile and try again.',
                fontSize: 14,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      return _AvailabilityKeyedBody(
        key: ValueKey<String>(services.join('|')),
        services: services,
        initialTab: initialTab,
      );
    });
  }
}

class _AvailabilityKeyedBody extends StatefulWidget {
  final List<String> services;
  final dynamic initialTab;

  const _AvailabilityKeyedBody({
    super.key,
    required this.services,
    required this.initialTab,
  });

  @override
  State<_AvailabilityKeyedBody> createState() => _AvailabilityKeyedBodyState();
}

class _AvailabilityKeyedBodyState extends State<_AvailabilityKeyedBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VendorAvailabilityController controller = Get.find<VendorAvailabilityController>();

  @override
  void initState() {
    super.initState();
    final labels = widget.services;
    int startIndex = 0;
    if (widget.initialTab is int) {
      startIndex = widget.initialTab as int;
    } else if (widget.initialTab is String) {
      startIndex = labels.indexWhere(
        (s) => s.toLowerCase() == widget.initialTab.toString().toLowerCase(),
      );
      if (startIndex < 0) startIndex = 0;
    }
    if (startIndex >= labels.length) startIndex = 0;

    _tabController = TabController(
      length: labels.length,
      vsync: this,
      initialIndex: startIndex,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.services;
    final showTabs = labels.length > 1;
    final currentService = labels[_tabController.index];

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
                  if (currentService == 'Farrier') {
                    Get.to(() => const AddFarrierAvailabilityView());
                  } else if (currentService == 'Clipping') {
                    Get.to(() => const AddClippingAvailabilityView());
                  } else if (currentService == 'Braiding') {
                    Get.to(() => const BraidingAddAvailabilityView());
                  } else if (currentService == 'Bodywork') {
                    Get.to(() => const BodyworkAddAvailabilityView());
                  } else {
                    Get.to(() => const AddAvailabilityBlockView(), arguments: 0);
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
          ),
        ],
        bottom: showTabs
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: _buildTabs(labels),
              )
            : null,
      ),
      body: Obx(() {
        final filteredBlocks = controller.availabilityBlocks.where(
          (b) => b.serviceTypes.contains(currentService),
        ).toList();

        return RefreshIndicator(
          onRefresh: () async => controller.fetchAvailability(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showTabs) ...[
                  const CommonText('Details', fontSize: 18, fontWeight: FontWeight.bold),
                  const SizedBox(height: 16),
                ],
                const CommonText(
                  'Manage your availability for trainers to discover',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
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
                                        onEdit: () => Get.to(() => const BodyworkAddAvailabilityView(), arguments: {'block': b}),
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
                                              final svc = labels[_tabController.index];
                                              final editIndex = svc == 'Grooming' ? 0 : 2;
                                              Get.to(() => const AddAvailabilityBlockView(), arguments: {
                                                'categoryIndex': editIndex,
                                                'block': b,
                                              });
                                            },
                                            onDelete: () => b.id != null ? controller.deleteAvailabilityBlock(b.id!) : null,
                                          )))),
                      )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabs(List<String> labels) {
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: labels.map((s) => Tab(child: CommonText(s, fontSize: 16, fontWeight: FontWeight.bold))).toList(),
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
                activeTrackColor: const Color(0xFF13CA8B),
                thumbColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected) ? Colors.white : null),
              )),
        ],
      ),
    );
  }
}
