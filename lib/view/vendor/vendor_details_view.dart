import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_details_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/url_helper.dart';
import 'package:catch_ride/view/vendor/send_booking_request_view.dart';
import 'package:catch_ride/view/vendor/upcoming_availability.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';
import 'package:catch_ride/view/vendor/shipping/availability/shipping_trip_card.dart';
import 'package:catch_ride/models/trip_model.dart';
import '../../models/vendor_availability_model.dart';

import 'bodywork/profile/bodywork_service_and_rates_view.dart';
import 'groom/profile/grooming_service_and_rates_view.dart';
import 'shipping/profile/shipping_service_and_rates_view.dart';
import 'clipping/profile/clipping_service_and_rates_view.dart';
import 'braiding/profile/braiding_service_and_rates_view.dart';
import 'farrier/profile/farrier_service_and_rates_view.dart';
import 'groom/profile/general_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/groom/profile/payment_methods.dart';

class VendorDetailsView extends StatefulWidget {
  const VendorDetailsView({super.key});

  @override
  State<VendorDetailsView> createState() => _VendorDetailsViewState();
}

class _VendorDetailsViewState extends State<VendorDetailsView> with TickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(VendorDetailsController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  void _setupTabController(int length) {
    if (_tabController.length != length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.length != length) {
          _tabController.dispose();
          _tabController = TabController(length: length, vsync: this);
          _tabController.addListener(() {
            if (!_tabController.indexIsChanging) {
              controller.selectedTabIndex.value = _tabController.index;
            }
          });
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => controller.fetchVendorDetails(controller.vendorId.value),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildBio(),
                          const SizedBox(height: 16),
                          _buildSocials(),
                          const SizedBox(height: 16),
                          _buildPaymentMethods(),
                          const SizedBox(height: 24),
                          Obx(() {
                            if (controller.availableServices.isNotEmpty) {
                              _setupTabController(controller.availableServices.length);
                            }
                            return _buildTabs();
                          }),
                          const SizedBox(height: 20),
                          Obx(() => _buildDetailsCard()),
                          const SizedBox(height: 24),
                          _buildPhotosSection(),
                          const SizedBox(height: 24),
                          _buildAvailabilitySection(),
                          const SizedBox(height: 24),
                          Obx(() => _buildCancellationPolicy()),
                          const SizedBox(height: 140), // Space for buttons
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CommonImageView(
                url: controller.coverImage,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: const Icon(Icons.more_vert, color: Colors.black, size: 20),
              ),
            ),
            Positioned(
              bottom: -45,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CommonImageView(
                  url: controller.profilePhoto,
                  height: 100,
                  width: 100,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 135, top: 4, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(controller.fullName, fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
              const SizedBox(height: 1),
              CommonText(controller.businessName, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(Icons.location_on, color: Color(0xFFE11D48), size: 14),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: CommonText(controller.location, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Obx(() => CommonText(
                '${controller.availableServices.isNotEmpty ? controller.availableServices[controller.selectedTabIndex.value] : ''}  •  ${controller.experienceStr} Years', 
                fontSize: AppTextSizes.size14, 
                color: AppColors.textSecondary, 
                fontWeight: FontWeight.w600
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CommonText(
        controller.bio,
        fontSize: AppTextSizes.size14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildSocials() {
    final instagram = controller.instagramUrl;
    final facebook = controller.facebookUrl;
    if (instagram.isEmpty && facebook.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        if (instagram.isNotEmpty) _buildSocialButton('Instagram', Icons.camera_alt_outlined, AppColors.accentRedLight, () => UrlHelper.launchInstagram(instagram)),
        if (instagram.isNotEmpty && facebook.isNotEmpty) const SizedBox(width: 12),
        if (facebook.isNotEmpty) _buildSocialButton('Facebook', Icons.facebook, AppColors.linkBlue, () => UrlHelper.launchFacebook(facebook)),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            CommonText(label, fontSize: AppTextSizes.size14, color: color, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return GestureDetector(
      onTap: () => Get.to(() => const PaymentMethods()),
      child: Obx(() {
        final methods = controller.paymentMethods;
        if (methods.isEmpty) return const SizedBox.shrink();
        return Row(
          children: [
            SizedBox(
              width: methods.length > 1 ? (22.0 + (methods.take(3).length - 1) * 15.0) : 26,
              height: 26,
              child: Stack(
                children: [
                  ...methods.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final pm = entry.value;
                    IconData icon = Icons.payments_outlined;
                    Color color = AppColors.secondary;
                    if (pm.toLowerCase().contains('venmo')) { icon = Icons.account_balance_wallet_outlined; color = const Color(0xFF3D95CE); }
                    else if (pm.toLowerCase().contains('paypal')) { icon = Icons.payment; color = const Color(0xFF003087); }
                    else if (pm.toLowerCase().contains('zelle')) { icon = Icons.currency_exchange; color = const Color(0xFF671BC4); }
                    else if (pm.toLowerCase().contains('cash')) { icon = Icons.money; color = const Color(0xFF22C55E); }
                    else if (pm.toLowerCase().contains('card')) { icon = Icons.credit_card; color = const Color(0xFF1E3A8A); }
                    return Positioned(
                      left: index * 15.0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
                        child: Icon(icon, size: 20, color: color),
                      ),
                    );
                  }).toList().reversed,
                ],
              ),
            ),
            const SizedBox(width: 8),
            CommonText(
              methods.length > 3 ? 'View all ${methods.length} payment methods' : 'View payment methods',
              fontSize: AppTextSizes.size12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
          ],
        );
      }),
    );
  }

  Widget _buildTabs() {
    if (controller.availableServices.isEmpty) return const SizedBox.shrink();
    
    final services = controller.availableServices;
    final isSingle = services.length == 1;

    if (isSingle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Details', fontSize: 18, fontWeight: FontWeight.bold),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.textPrimary,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: services.map((s) {
            return Tab(child: CommonText(s, fontSize: 16, fontWeight: FontWeight.bold));
          }).toList(),
          onTap: (index) => controller.selectedTabIndex.value = index,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildDetailsCard() {
    final String activeService = controller.availableServices.isNotEmpty 
        ? controller.availableServices[controller.selectedTabIndex.value] 
        : '';
    final String activeServiceKey = activeService.toLowerCase().replaceAll(' ', '');
    final Map servicesData = controller.vendorData.value?['servicesData'] ?? {};

    // Bridging logic to find the correct data from controller and vendorData
    final dynamic assignedService = (controller.vendorData['assignedServices'] as List?)?.firstWhereOrNull(
      (s) => s['serviceType'] == activeService);
    final platformProfile = assignedService?['profile'] ?? {};

    if (activeServiceKey.contains('bodywork')) {
       final Map bodyworkData = servicesData['bodywork'] ?? servicesData['body work'] ?? platformProfile;
       return BodyworkServiceAndRatesView(
         bodyworkData: bodyworkData,
         location: controller.location,
         experience: '${controller.experienceStr} Years',
         disciplines: controller.disciplinesSelected,
         horseLevels: controller.horseLevels,
         regionsCovered: controller.operatingRegions,
         travelPreferences: controller.travelPreferences,
         services: controller.coreServices.map((s) => s is Map ? s.cast<String, dynamic>() : {'name': s.toString(), 'price': '0', 'isSelected': true}).toList(),
       );
    }
    
    if (activeServiceKey == 'shipping' || activeServiceKey == 'transportation') {
      final Map shippingData = servicesData['shipping'] ?? servicesData['transportation'] ?? platformProfile;
      // Note: VendorDetailsController might lack some specific shipping getters, 
      // but we can extract them from the profile data directly or refine the controller later.
      final pData = platformProfile['profileData'] ?? {};
      final aData = assignedService?['application']?['applicationData'] ?? {};
      
      return ShippingServiceAndRatesView(
        shippingData: shippingData,
        location: controller.location,
        experience: '${controller.experienceStr} Years',
        baseRate: pData['rates']?['baseRate']?.toString() ?? 'N/A',
        fullyLoadedRate: pData['rates']?['loadedRate']?.toString() ?? 'N/A',
        travelScope: List<String>.from(aData['travelScope'] ?? []),
        regionsCovered: controller.operatingRegions,
        servicesOffered: List<String>.from(pData['services'] ?? []),
        rigTypes: List<String>.from(aData['rigTypes'] ?? []),
        operationType: aData['operationType'] ?? 'N/A',
        rigCapacity: aData['rigCapacity']?.toString() ?? 'N/A',
        equipmentSummary: pData['equipmentSummary'] ?? 'N/A',
        dotNumber: aData['businessInfo']?['dotNumber']?.toString() ?? 'N/A',
        hasCDL: aData['confirmLicense'] ?? false,
        businessName: controller.businessName,
        highlights: List<String>.from(controller.vendorData['highlights'] ?? []),
      );
    }
    
    if (activeServiceKey == 'grooming') {
       final Map groomingData = servicesData['grooming'] ?? platformProfile;
       return GroomingServiceAndRatesView(
         groomingData: groomingData,
         location: controller.location,
         experience: '${controller.experienceStr} Years',
         disciplines: controller.disciplinesSelected,
         horseLevels: controller.horseLevels,
         regionsCovered: controller.operatingRegions,
         travelPreferences: controller.travelPreferences,
         supportOptions: controller.supportOptions,
         handlingOptions: controller.handlingOptions,
         additionalSkills: List<String>.from(controller.vendorData['highlights'] ?? []),
       );
    }
    
    if (activeServiceKey == 'clipping') {
       final Map clippingData = servicesData['clipping'] ?? platformProfile;
       return ClippingServiceAndRatesView(
         clippingData: clippingData,
         location: controller.location,
         experience: '${controller.experienceStr} Years',
         disciplines: controller.disciplinesSelected,
         horseLevels: controller.horseLevels,
         regionsCovered: controller.operatingRegions,
         travelPreferences: controller.travelPreferences,
       );
    }
    
    if (activeServiceKey == 'braiding') {
       final Map braidingData = servicesData['braiding'] ?? platformProfile;
       return BraidingServiceAndRatesView(
         braidingData: braidingData,
         location: controller.location,
         experience: '${controller.experienceStr} Years',
         disciplines: controller.disciplinesSelected,
         horseLevels: controller.horseLevels,
         regionsCovered: controller.operatingRegions,
         travelPreferences: controller.travelPreferences,
       );
    }

    if (activeServiceKey == 'farrier') {
      return FarrierServiceAndRatesView(
        farrierData: servicesData['farrier'] ?? platformProfile,
        location: controller.location,
        experience: '${controller.experienceStr} Years',
        disciplines: controller.disciplinesSelected,
        horseLevels: controller.horseLevels,
        scopeOfWork: List<String>.from(assignedService?['application']?['applicationData']?['scopeOfWork'] ?? []),
        regionsCovered: controller.operatingRegions,
        travelPreferences: controller.travelPreferences,
        services: controller.coreServices,
        addOns: controller.additionalServices,
      );
    }

    return GeneralServiceAndRatesView(
      title: activeService,
      dailyRate: controller.dailyRate,
      weeklyRate: controller.weeklyRate,
      weeklyDays: controller.weeklyDays,
      monthlyRate: controller.monthlyRate,
      monthlyDays: controller.monthlyDays,
      services: controller.coreServices,
      additionalServices: controller.additionalServices,
      supportOptions: controller.supportOptions,
      handlingOptions: controller.handlingOptions,
      location: controller.location,
      experience: '${controller.experienceStr} Years',
      disciplines: controller.disciplinesSelected,
      horseLevels: controller.horseLevels,
      travelPreferences: controller.travelPreferences,
      operatingRegions: controller.operatingRegions,
      isClipping: activeServiceKey.contains('clip'),
    );
  }

  Widget _buildPhotosSection() {
    final media = controller.photos;
    if (media.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Photos', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: media.map((url) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: Get.width * 0.28, height: 100, 
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), 
                clipBehavior: Clip.antiAlias, child: CommonImageView(url: url, fit: BoxFit.cover),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const UpcomingAvailability(), arguments: {'vendorId': controller.vendorId.value}),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CommonText('Upcoming Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isAvailabilityLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.availabilityList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: CommonText('No upcoming availability found.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary)),
            );
          }
          return Column(
            children: controller.availabilityList.take(3).map((avail) {
              // Note: Availability list in VendorDetailsController is VendorAvailabilityModel
              final serviceTypes = avail.serviceTypes;

              if (serviceTypes.contains('Braiding')) {
                return BraidingAvailabilityCard(availability: avail);
              }
              if (serviceTypes.contains('Clipping')) {
                return ClippingAvailabilityBlockCard(block: avail);
              }
              if (serviceTypes.contains('Farrier')) {
                return FarrierAvailabilityBlockCard(block: avail);
              }
              if (serviceTypes.contains('Bodywork')) {
                return BodyworkAvailabilityBlockCard(block: avail);
              }
              return GroomingAvailabilityCard(availability: avail);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFEE2E2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
              SizedBox(width: 8),
              CommonText('Cancellation Policy', color: Colors.red, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          CommonText(controller.cancellationPolicy, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4444)),
          const SizedBox(height: 4),
          CommonText(
            'Cancellations must be made at least ${controller.cancellationPolicy} in advance. Late cancellations may incur a fee or may not be eligible for a refund.',
            fontSize: AppTextSizes.size12,
            color: const Color(0xFF8B4444),
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Obx(() => Row(
          children: [
            Expanded(
              flex: controller.canMessage.value ? 2 : 1,
              child: ElevatedButton(
                onPressed: () => _showServiceSelectionBottomSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const CommonText('Send Booking Request', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            if (controller.canMessage.value) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_bubble_outline, size: 18),
                      SizedBox(width: 8),
                      CommonText('Message', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ],
        )),
      ),
    );
  }

  void _showServiceSelectionBottomSheet() {
    final RxString localSelected = controller.availableServices.isNotEmpty ? controller.availableServices.first.obs : ''.obs;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const CommonText('Choose Service', fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            Obx(() => Column(
              children: controller.availableServices.map((service) {
                final isSelected = localSelected.value == service;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => localSelected.value = service,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(service, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: AppColors.textPrimary),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const SendBookingRequestView(), arguments: {
                    'vendorData': controller.vendorData.value,
                    'service': localSelected.value,
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const CommonText('Continue', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
