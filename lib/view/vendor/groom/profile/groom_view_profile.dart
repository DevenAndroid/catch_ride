import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/view/vendor/groom/profile/payment_methods.dart';
import 'package:catch_ride/utils/url_helper.dart';
import 'package:catch_ride/view/vendor/upcoming_availability.dart';
import 'package:catch_ride/view/vendor/bodywork/profile/bodywork_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/groom/profile/grooming_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/shipping/profile/shipping_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/clipping/profile/clipping_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/braiding/profile/braiding_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/farrier/profile/farrier_service_and_rates_view.dart';
import 'package:catch_ride/view/vendor/groom/profile/general_service_and_rates_view.dart';
import 'package:catch_ride/widgets/common_media_viewer.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
import 'package:catch_ride/view/vendor/clipping/availability/add_clipping_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/add_farrier_availability_view.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_add_availability.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_add_availability.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';
import 'package:catch_ride/models/trip_model.dart';
import 'package:catch_ride/view/vendor/shipping/availability/shipping_trip_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shipping/trip/shipping_trip_view.dart';
import '../menu/edit_vendor_profile_view.dart';

class GroomViewProfile extends StatefulWidget {
  const GroomViewProfile({super.key});

  @override
  State<GroomViewProfile> createState() => _GroomViewProfileState();
}

class _GroomViewProfileState extends State<GroomViewProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  final GroomViewProfileController groomController = Get.put(GroomViewProfileController());
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
            final groomController = Get.find<GroomViewProfileController>();
            if (!_tabController.indexIsChanging) {
              groomController.selectService(_tabController.index);
            }
          });
          setState(() {});
        }
      });
    }
  }

  /// Prefer [GroomViewProfileController.getProfileDataByType] (VendorModel embed + merged
  /// `servicesData` + ServiceProfile) so Services & Rates edits match this card; raw `servicesData[svc]`
  /// alone can lag behind populated profile / sync after `PUT /vendors/me`.
  Map<String, dynamic> _detailBlockForActiveService(
    GroomViewProfileController c,
    Map<dynamic, dynamic> servicesData,
    List<String> legacyKeys,
  ) {
    final merged = c.getProfileDataByType(c.activeServiceType);
    if (merged.isNotEmpty) return Map<String, dynamic>.from(merged);
    for (final k in legacyKeys) {
      final raw = servicesData[k];
      if (raw is Map) return Map<String, dynamic>.from(raw);
    }
    return Map<String, dynamic>.from(c.activeServiceProfile);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (groomController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final activeService = groomController.activeServiceType.toLowerCase().replaceAll(' ', '');
        return RefreshIndicator(
          onRefresh: groomController.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(groomController),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      if(activeService=="shipping")
                      ...[
                        Row(
                          children: [
                            if (groomController.hasDotNumber) ...[
                              BadgeChip(
                                text: "USDOT REGISTERED",
                                icon: Icons.verified,
                                borderColor: const Color(0xFF2E7D32),
                                backgroundColor: const Color(0xFFE8F5E9),
                                textColor: const Color(0xFF2E7D32),
                              ),
                              if (groomController.isInsured) const SizedBox(width: 10),
                            ],
                            if (groomController.isInsured)
                              BadgeChip(
                                text: "INSURED",
                                icon: LucideIcons.shieldCheck,
                                borderColor: const Color(0xFF1565C0),
                                backgroundColor: const Color(0xFFE3F2FD),
                                textColor: const Color(0xFF1565C0),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                      if(groomController.bioDisplay.isNotEmpty )
                      ...[
                        _buildBio(groomController),
                        const SizedBox(height: 16),
                      ],


                      _buildSocials(groomController),
                      const SizedBox(height: 16),
                      _buildPaymentMethods(groomController),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (groomController.allAssignedServices.isNotEmpty) {
                           _setupTabController(groomController.allAssignedServices.length);
                        }
                        return _buildTabs(groomController);
                      }),
                      const SizedBox(height: 20),
                      Obx(() => _buildDetailsCard(groomController)),
                      const SizedBox(height: 24),
                      _buildPhotosSection(groomController),
                      const SizedBox(height: 24),
                      _buildAvailabilitySection(groomController),
                      const SizedBox(height: 24),
                      _buildHighlights(groomController),
                      const SizedBox(height: 16),
                      if(groomController.cancellationPolicy != "")
                      Obx(() => _buildCancellationPolicy(groomController)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(GroomViewProfileController groomController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                if (groomController.coverImage.isNotEmpty) {
                  Get.to(() => CommonMediaViewer(
                    mediaSources: [groomController.coverImage],
                    initialIndex: 0,
                  ));
                }
              },
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: CommonImageView(
                  url: groomController.coverImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              bottom: -45,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  if (groomController.profilePhoto.isNotEmpty) {
                    Get.to(() => CommonMediaViewer(
                      mediaSources: [groomController.profilePhoto],
                      initialIndex: 0,
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CommonImageView(
                    url: groomController.profilePhoto,
                    height: 100,
                    width: 100,
                    shape: BoxShape.circle,
                    isUserImage: true,
                  ),
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
              CommonText(groomController.fullName, fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 1),
              CommonText(groomController.businessNameDisplay, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: const Icon(Icons.location_on, color: Color(0xFFE11D48), size: 14),
                  ),
                  const SizedBox(width: 4),
                  Obx(() => Expanded(child: CommonText(groomController.locationStr.value, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600,))),
                ],
              ),
              const SizedBox(height: 4),
              Obx(() {
                final serviceType = groomController.activeServiceType;
                final experience = groomController.experienceStr.value;
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(serviceType, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        if (experience.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const CommonText('•', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (experience.isNotEmpty)
                      CommonText(experience, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBio(GroomViewProfileController groomController) {
    return CommonText(
      groomController.bioDisplay,
      fontSize: AppTextSizes.size14,
      color: AppColors.textSecondary,
      height: 1.5,
    );
  }

  Widget _buildSocials(GroomViewProfileController groomController) {
    if (groomController.instagramUrl.isEmpty && groomController.facebookUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Row(
          children: [
            if (groomController.instagramUrl.isNotEmpty) 
              _buildSocialButton('Instagram', Icons.camera_alt_outlined, AppColors.accentRedLight, () => UrlHelper.launchInstagram(groomController.instagramUrl)),
            if (groomController.instagramUrl.isNotEmpty && groomController.facebookUrl.isNotEmpty) const SizedBox(width: 12),
            if (groomController.facebookUrl.isNotEmpty) 
              _buildSocialButton('Facebook', Icons.facebook, AppColors.linkBlue, () => UrlHelper.launchFacebook(groomController.facebookUrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 8),
            CommonText(label, fontSize: AppTextSizes.size14, color: color, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(GroomViewProfileController groomController) {
    return GestureDetector(
      onTap: () => Get.to(() => const PaymentMethods()),
      child: Obx(() {
        final methods = groomController.paymentMethods;
        if (methods.isEmpty) {
          return const SizedBox.shrink();
        }
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
                    
                    if (pm.toLowerCase().contains('venmo')) {
                      icon = Icons.account_balance_wallet_outlined;
                      color = const Color(0xFF3D95CE);
                    } else if (pm.toLowerCase().contains('paypal')) {
                      icon = Icons.payment;
                      color = const Color(0xFF003087);
                    } else if (pm.toLowerCase().contains('zelle')) {
                      icon = Icons.currency_exchange;
                      color = const Color(0xFF671BC4);
                    } else if (pm.toLowerCase().contains('cash')) {
                      icon = Icons.money;
                      color = const Color(0xFF22C55E);
                    } else if (pm.toLowerCase().contains('card')) {
                      icon = Icons.credit_card;
                      color = const Color(0xFF1E3A8A);
                    }
                    
                    return Positioned(
                      left: index * 15.0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Icon(icon, size: 20, color: color),
                      ),
                    );
                  }).toList().reversed,
                ],
              ),
            ),
            const SizedBox(width: 8),
            CommonText(
              methods.length > 3 
                ? 'View all ${methods.length} payment methods' 
                : 'View payment methods',
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

  Widget _buildTabs(GroomViewProfileController groomController) {
    if (groomController.allAssignedServices.isEmpty) return const SizedBox.shrink();

    final services = groomController.allAssignedServices;
    final isSingle = services.length == 1;

    if (isSingle) {
      if (_tabController.length != 1) {
        _setupTabController(1);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Details', fontSize: 18, fontWeight: FontWeight.bold),
        ],
      );
    }

    if (_tabController.length != services.length) {
      _setupTabController(services.length);
      return const SizedBox(height: 48);
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
            String label = s['serviceType'] ?? 'Details';
            return Tab(child: CommonText(label, fontSize: 16, fontWeight: FontWeight.bold));
          }).toList(),
          onTap: (index) {
            groomController.selectService(index);
          },
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildDetailsCard(GroomViewProfileController groomController) {
    final activeService = groomController.activeServiceType.toLowerCase().replaceAll(' ', '');
    final vendor = groomController.vendorData;
    final Map<dynamic, dynamic> servicesData = vendor['servicesData'] ?? {};

    if (activeService.contains('bodywork')) {
        final Map bodyworkData = _detailBlockForActiveService(
          groomController,
          servicesData,
          ['bodywork', 'body work'],
        );
       return BodyworkServiceAndRatesView(
         bodyworkData: bodyworkData,
         location: groomController.locationStr.value,
         experience: groomController.experienceStr.value,
         disciplines: groomController.disciplinesSelected,
         horseLevels: groomController.horseLevels,
         regionsCovered: groomController.operatingRegions,
         travelPreferences: groomController.travelPreferences,
         services: groomController.bodyworkServices,
       );
    }
    
    if (activeService == 'shipping' || activeService == 'transportation') {
       final Map shippingData = _detailBlockForActiveService(
         groomController,
         servicesData,
         ['shipping', 'transportation'],
       );
      return ShippingServiceAndRatesView(
        shippingData: shippingData,
        location: groomController.locationStr.value,
        experience: groomController.experienceStr.value,
        baseRate: groomController.shippingBaseRate,
        fullyLoadedRate: groomController.shippingLoadedRate,
        travelScope: groomController.shippingTravelScope.toList(),
        regionsCovered: groomController.shippingRegionsCovered.toList(),
        servicesOffered: groomController.shippingServicesOffered.toList(),
        rigTypes: groomController.shippingRigTypes.toList(),
        operationType: groomController.shippingOperationType,
        rigCapacity: groomController.shippingRigCapacity,
        equipmentSummary: groomController.shippingEquipmentSummary,
        additionalNotes: groomController.shippingAdditionalNotes,
        dotNumber: groomController.shippingDotNumber,
        hasCDL: groomController.shippingHasCDL,
        businessName: groomController.shippingBusinessName,
        highlights: groomController.highlights,
      );
    }
    
    if (activeService == 'grooming') {
        final Map groomingData = _detailBlockForActiveService(
          groomController,
          servicesData,
          ['grooming'],
        );
       return GroomingServiceAndRatesView(
         groomingData: groomingData,
         location: groomController.locationStr.value,
         experience: groomController.experienceStr.value,
         disciplines: groomController.disciplinesSelected,
         horseLevels: groomController.horseLevels,
         regionsCovered: groomController.operatingRegions,
         travelPreferences: groomController.travelPreferences,
         supportOptions: groomController.supportOptions,
         handlingOptions: groomController.handlingOptions,
         additionalSkills: groomController.highlights,
       );
    }
    
    if (activeService == 'clipping') {
        final Map clippingData = _detailBlockForActiveService(
          groomController,
          servicesData,
          ['clipping'],
        );
       return ClippingServiceAndRatesView(
         clippingData: clippingData,
         location: groomController.locationStr.value,
         experience: groomController.experienceStr.value,
         disciplines: groomController.disciplinesSelected,
         horseLevels: groomController.horseLevels,
         regionsCovered: groomController.operatingRegions,
         travelPreferences: groomController.travelPreferences,
       );
    }
    
    if (activeService == 'braiding') {
        final Map braidingData = _detailBlockForActiveService(
          groomController,
          servicesData,
          ['braiding'],
        );
       return BraidingServiceAndRatesView(
         braidingData: braidingData,
         location: groomController.locationStr.value,
         experience: groomController.experienceStr.value,
         disciplines: groomController.disciplinesSelected,
         horseLevels: groomController.horseLevels,
         regionsCovered: groomController.operatingRegions,
         travelPreferences: groomController.travelPreferences,
       );
    }

    if (activeService == 'farrier') {
      return FarrierServiceAndRatesView(
        farrierData: _detailBlockForActiveService(
          groomController,
          servicesData,
          ['farrier'],
        ),
        location: groomController.locationStr.value,
        experience: groomController.experienceStr.value,
        disciplines: groomController.disciplinesSelected,
        horseLevels: groomController.horseLevels,
        scopeOfWork: groomController.farrierScopeOfWork,
        regionsCovered: groomController.operatingRegions,
        travelPreferences: groomController.travelPreferences,
        services: groomController.farrierServices,
        addOns: groomController.farrierAddOns,
      );
    }

    return GeneralServiceAndRatesView(
      title: groomController.activeServiceType,
      dailyRate: groomController.dailyRate,
      weeklyRate: groomController.weeklyRate,
      weeklyDays: groomController.weeklyDays,
      monthlyRate: groomController.monthlyRate,
      monthlyDays: groomController.monthlyDays,
      services: groomController.groomingServices,
      additionalServices: groomController.additionalServices,
      supportOptions: groomController.supportOptions,
      handlingOptions: groomController.handlingOptions,
      location: groomController.locationStr.value,
      experience: groomController.experienceStr.value,
      disciplines: groomController.disciplinesSelected,
      horseLevels: groomController.horseLevels,
      travelPreferences: groomController.travelPreferences,
      operatingRegions: groomController.operatingRegions,
      isClipping: groomController.activeServiceType.toLowerCase().contains('clip'),
    );
  }


  Widget _buildPhotosSection(GroomViewProfileController groomController) {
    final media = groomController.allMedia;
    if (media.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Photos', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: media.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildPhotoItem(url, media, index),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String url, List<String> allMedia, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CommonMediaViewer(
          mediaSources: allMedia,
          initialIndex: index,
        ));
      },
      child: Container(
        width: Get.width * 0.28,
        height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: CommonImageView(url: url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAvailabilitySection(GroomViewProfileController groomController) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if( groomController.activeServiceType.toLowerCase().contains('shipping')){
              Get.to(() => const ShippingTripView());
              return;
            }
      Get.to(() => const UpcomingAvailability(), arguments: {
        'vendorId': groomController.vendorData['_id'],
        'serviceType': groomController.activeServiceType,
      });
    },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              CommonText( groomController.activeServiceType.toLowerCase().contains('shipping') ? "Active / Upcoming Loads": 'Upcoming Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (groomController.isAvailabilityLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = groomController.filteredAvailabilityList;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: CommonText('No upcoming availability found.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary)),
            );
          }
          return Column(
            children: list.take(3).map((avail) {
              if (avail['isTrip'] == true) {
                return ShippingTripCard(trip: TripModel.fromJson(avail));
              }
              
              final b = VendorAvailabilityModel.fromJson(avail);
              final serviceTypes = b.serviceTypes;

              final authController = Get.find<AuthController>();
              final isOwner = b.vendorId == authController.currentUser.value?.vendorProfileId;
              
              final onEdit = isOwner ? () {
                final type = serviceTypes.firstOrNull ?? 'Grooming';
                if (type == 'Farrier') {
                  Get.to(() => const AddFarrierAvailabilityView(), arguments: {'block': b});
                } else if (type == 'Clipping') {
                  Get.to(() => const AddClippingAvailabilityView(), arguments: {'block': b});
                } else if (type == 'Braiding') {
                  Get.to(() => const BraidingAddAvailabilityView(), arguments: {'block': b});
                } else if (type == 'Bodywork') {
                  Get.to(() => const BodyworkAddAvailabilityView(), arguments: {'block': b});
                } else {
                  Get.to(() => const AddAvailabilityBlockView(), arguments: {
                    'categoryIndex': 0,
                    'block': b
                  });
                }
              } : null;

              final onDelete = isOwner ? () {
                if (b.id != null) {
                  final availabilityController = Get.isRegistered<VendorAvailabilityController>() 
                      ? Get.find<VendorAvailabilityController>() 
                      : Get.put(VendorAvailabilityController());
                  availabilityController.deleteAvailabilityBlock(b.id!);
                }
              } : null;

              if (serviceTypes.contains('Clipping')) {
                return ClippingAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
              }
              if (serviceTypes.contains('Farrier')) {
                return FarrierAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
              }
              if (serviceTypes.contains('Braiding')) {
                return BraidingAvailabilityCard(availability: b, onEdit: onEdit, onDelete: onDelete);
              }
              if (serviceTypes.contains('Bodywork')) {
                return BodyworkAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
              }
              return GroomingAvailabilityCard(availability: b, onEdit: onEdit, onDelete: onDelete);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCancellationPolicy(GroomViewProfileController groomController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
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
          CommonText(
            groomController.cancellationPolicy,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4444),
          ),
          const SizedBox(height: 4),
           CommonText(
            'Cancellations must be made at least ${ groomController.cancellationPolicy} in advance. Late cancellations may incur a fee or may not be eligible for a refund.',
            fontSize: AppTextSizes.size12,
            color: Color(0xFF8B4444),
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(GroomViewProfileController groomController) {
    if (groomController.highlights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Professional Highlights', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        ...groomController.highlights.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.star_outline, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(child: CommonText(h, fontSize: AppTextSizes.size14, color: AppColors.textPrimary)),
            ],
          ),
        )),
      ],
    );
  }
}


class BadgeChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const BadgeChip({
    super.key,
    required this.text,
    required this.icon,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor,),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}