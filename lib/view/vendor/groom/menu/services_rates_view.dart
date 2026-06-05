import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../braiding/profile/braiding_service_rates_tab.dart';
import '../../clipping/profile/clipping_service_rates_tab.dart';
import '../../farrier/profile/farrier_service_rates_tab.dart';
import '../../bodywork/profile/bodywork_service_rates_tab.dart';
import '../../shipping/profile/service_price_view.dart';
import '../profile/grooming_service_rates_tab.dart';

class ServicesRatesView extends StatefulWidget {
  const ServicesRatesView({super.key});

  @override
  State<ServicesRatesView> createState() => _ServicesRatesViewState();
}

class _ServicesRatesViewState extends State<ServicesRatesView> with TickerProviderStateMixin {
  final controller = Get.put(GroomViewProfileController());
  TabController? _tabController;
  final RxBool isTabReady = false.obs;
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final hasData = controller.vendorData.isNotEmpty;
    if (hasData) {
      isInitialLoading = false;
      _syncTabController(controller.allAssignedServices);
    }

    try {
      await controller.fetchProfile();
      if (!mounted) return;
      _syncTabController(controller.allAssignedServices);
    } finally {
      if (mounted) {
        setState(() {
          isInitialLoading = false;
        });
      }
    }
  }

  void _onTabIndexChanged() {
    if (_tabController == null) return;
    if (_tabController!.indexIsChanging) return;
    controller.selectService(_tabController!.index);
  }

  void _syncTabController(List<dynamic> services) {
    if (services.isEmpty) {
      _tabController?.removeListener(_onTabIndexChanged);
      _tabController?.dispose();
      _tabController = null;
      isTabReady.value = false;
      return;
    }

    // Single service: no TabController needed.
    if (services.length == 1) {
      _tabController?.removeListener(_onTabIndexChanged);
      _tabController?.dispose();
      _tabController = null;
      isTabReady.value = true;
      return;
    }

    if (_tabController != null && _tabController!.length == services.length) {
      isTabReady.value = true;
      return;
    }

    _tabController?.removeListener(_onTabIndexChanged);
    _tabController?.dispose();
    _tabController = TabController(length: services.length, vsync: this);
    _tabController!.addListener(_onTabIndexChanged);
    isTabReady.value = true;
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabIndexChanged);
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildServiceTab(Map<String, dynamic> service) {
    final type = service['serviceType']?.toString().toLowerCase() ?? '';
    if (type.contains('braid')) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: BraidingServiceRatesTab(serviceType: service['serviceType'].toString()),
      );
    }
    if (type.contains('clip')) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: ClippingServiceRatesTab(serviceType: service['serviceType'].toString()),
      );
    }
    if (type.contains('farrier')) {
      return FarrierServiceRatesTab(serviceType: service['serviceType'].toString());
    }
    if (type.contains('bodywork') || type.contains('body work')) {
      return BodyworkServiceRatesTab(serviceType: service['serviceType'].toString());
    }
    if (type.contains('shipping')) {
      return const ServicePriceView();
    }
    if (type.contains('groom')) {
      return GroomingServiceRatesTab(serviceType: service['serviceType'].toString());
    }
    return const Center(child: CommonText('Service details not available'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Services & Rates', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isInitialLoading || controller.allAssignedServices.length <= 1 ? 0 : 48),
          child: isInitialLoading
              ? const SizedBox.shrink()
              : Obx(() {
                  if (!isTabReady.value || controller.allAssignedServices.length <= 1) {
                    return const SizedBox.shrink();
                  }
                  final tabCtrl = _tabController;
                  if (tabCtrl == null) return const SizedBox.shrink();
                  return TabBar(
                    controller: tabCtrl,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: controller.allAssignedServices
                        .map((s) => Tab(text: s['serviceType'].toString().capitalizeFirst))
                        .toList(),
                  );
                }),
        ),
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final assigned = controller.allAssignedServices;
              if (assigned.isEmpty) {
                return const Center(child: CommonText('No services assigned'));
              }

              // One service: render directly (no TabController).
              if (assigned.length == 1) {
                final row = assigned.first;
                if (row is Map<String, dynamic>) {
                  return _buildServiceTab(row);
                }
                return _buildServiceTab(Map<String, dynamic>.from(row as Map));
              }

              // Multiple services: wait until TabController exists.
              if (!isTabReady.value || _tabController == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: assigned.map((s) {
                  final map = s is Map<String, dynamic>
                      ? s
                      : Map<String, dynamic>.from(s as Map);
                  return _buildServiceTab(map);
                }).toList(),
              );
            }),
    );
  }
}
