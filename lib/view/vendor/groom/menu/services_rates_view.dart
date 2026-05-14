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
        controller.selectService(_tabController!.index);
      });
      isTabReady.value = true;
    }
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: BraidingServiceRatesTab(serviceType: s['serviceType'].toString()),
              );
            } else if (type.contains('clip')) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ClippingServiceRatesTab(serviceType: s['serviceType'].toString()),
              );
            } else if (type.contains('farrier')) {
              return FarrierServiceRatesTab(serviceType: s['serviceType'].toString());
            } else if (type.contains('bodywork') || type.contains('body work')) {
              return BodyworkServiceRatesTab(serviceType: s['serviceType'].toString());
            } else if (type.contains('shipping')) {
              return const ServicePriceView();
            } else if (type.contains('groom')) {
              return GroomingServiceRatesTab(serviceType: s['serviceType'].toString());
            }
            return const Center(child: CommonText('Service details not available'));
          }).toList(),
        );
      }),
    );
  }
}
