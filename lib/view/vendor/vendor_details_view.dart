import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_details_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/view/vendor/send_booking_request_view.dart';
import 'package:catch_ride/view/vendor/upcoming_availability.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/vendor_availability_model.dart';

class VendorDetailsView extends StatefulWidget {
  const VendorDetailsView({super.key});

  @override
  State<VendorDetailsView> createState() => _VendorDetailsViewState();
}

class _VendorDetailsViewState extends State<VendorDetailsView> with TickerProviderStateMixin {
  late TabController _tabController;
  final _showMoreDetails = false.obs;
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
                          _buildHighlights(),
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
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFE11D48), size: 14),
                  const SizedBox(width: 4),
                  CommonText(controller.location, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ],
              ),
              const SizedBox(height: 4),
              Obx(() => CommonText(
                '${controller.availableServices.join(', ')}  ${controller.experienceStr.isNotEmpty ? '  •  ${controller.experienceStr} Years' : ''}', 
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
        if (instagram.isNotEmpty) _buildSocialButton('Instagram', Icons.camera_alt_outlined, AppColors.accentRedLight),
        if (instagram.isNotEmpty && facebook.isNotEmpty) const SizedBox(width: 12),
        if (facebook.isNotEmpty) _buildSocialButton('Facebook', Icons.facebook, AppColors.linkBlue),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Container(
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
    );
  }

  Widget _buildPaymentMethods() {
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
        const CommonText('View payment methods', fontSize: AppTextSizes.size12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildTabs() {
    if (controller.availableServices.isEmpty) return const SizedBox.shrink();
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
          tabs: controller.availableServices.map((s) {
            final String label = controller.availableServices.length == 1 ? 'Details' : s;
            return Tab(child: CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold));
          }).toList(),
          onTap: (index) => controller.selectedTabIndex.value = index,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Services & Rates', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          if (controller.dailyRate != 'N/A' || controller.weeklyRate != 'N/A' || controller.monthlyRate != 'N/A') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRateItem(controller.dailyRate != 'N/A' ? '\$ ${controller.dailyRate}' : 'N/A', 'Day Rate'),
                _buildRateItem(
                  controller.weeklyRate != 'N/A' ? '\$ ${controller.weeklyRate}' : 'N/A', 
                  'Week Rate (${controller.weeklyDays}d)'
                ),
                _buildRateItem(
                  controller.monthlyRate != 'N/A' ? '\$ ${controller.monthlyRate}' : 'N/A', 
                  'Month Rate (${controller.monthlyDays}d)'
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          Obx(() => Column(
                children: _buildCapabilityItems(),
              )),
          const SizedBox(height: 20),
          const CommonText('Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          if (controller.additionalServices.isEmpty)
            const CommonText('No additional services', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          ...controller.additionalServices.map((s) => _buildAdditionalService(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'} / horse')),
          const SizedBox(height: 20),
          _buildTwoColumnDetails('Location', controller.location, 'Years of experience', '${controller.experienceStr} Years'),
          _buildViewMoreSection(),
        ],
      ),
    );
  }

  List<Widget> _buildCapabilityItems() {
    final List<dynamic> rawServices = controller.coreServices;
    final List<Widget> items = [];

    // 1. Process Core Services
    for (var s in rawServices) {
      if (s is Map) {
         items.add(_buildPricedItem(s['name'] ?? 'N/A', '\$${s['price'] ?? '0'}/horse'));
      } else {
        items.add(_buildCheckItem(s.toString()));
      }
    }

    // 2. Process Support Options
    for (var it in controller.supportOptions) {
      items.add(_buildCheckItem(it));
    }

    // 3. Process Handling Options
    for (var it in controller.handlingOptions) {
      items.add(_buildCheckItem(it));
    }

    return items;
  }

  Widget _buildPricedItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: CommonText(name, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          CommonText(price, fontSize: AppTextSizes.size14, color: AppColors.secondary, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(price, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.secondary),
        CommonText(label, fontSize: AppTextSizes.size10, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildAdditionalService(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: CommonText(name, fontSize: AppTextSizes.size14, color: AppColors.textPrimary)),
          CommonText(price, fontSize: AppTextSizes.size14, color: AppColors.secondary, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildViewMoreSection() {
    return Obx(() {
      if (_showMoreDetails.value) {
        return Column(
          children: [
            const SizedBox(height: 20),
             _buildTwoColumnDetails(
              'Disciplines',
              controller.disciplinesSelected.isEmpty ? 'N/A' : controller.disciplinesSelected.join(', '),
              'Horse levels',
              controller.horseLevels.isEmpty ? 'N/A' : controller.horseLevels.join(', '),
            ),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Show & barn support', controller.supportOptions.isEmpty ? 'N/A' : controller.supportOptions.join(', ')),
            const SizedBox(height: 20),
            _buildTwoColumnDetails(
              'Horse handling',
              controller.handlingOptions.isEmpty ? 'N/A' : controller.handlingOptions.join(', '),
              'Travel preferences',
              controller.travelPreferences.isEmpty ? 'N/A' : controller.travelPreferences.join(', '),
            ),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Operating regions', controller.operatingRegions.isEmpty ? 'N/A' : controller.operatingRegions.join(', ')),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showMoreDetails.value = false,
              child: const CommonText('View less', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }
      return Column(
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showMoreDetails.value = true,
            child: const CommonText('View more', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          ),
        ],
      );
    });
  }

  Widget _buildTwoColumnDetails(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDetailItem(label1, value1)),
        const SizedBox(width: 20),
        Expanded(child: _buildDetailItem(label2, value2)),
      ],
    );
  }

  Widget _buildSingleColumnDetail(String label, String value) {
    return _buildDetailItem(label, value);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        const SizedBox(height: 6),
        CommonText(value, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const Divider(height: 24, color: AppColors.dividerColor),
      ],
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
                width: 110, height: 110, 
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
          if (controller.availabilityList.isEmpty) return const SizedBox.shrink();
          return Column(
            children: controller.availabilityList.take(3).map((avail) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAvailabilityCard(avail),
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAvailabilityCard(VendorAvailabilityModel b) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(b.dateDisplay, color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(child: CommonText(b.locationDisplay, color: Colors.white70, fontSize: AppTextSizes.size12, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: b.serviceTypes.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: CommonText(t, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.catching_pokemon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText('Max ${b.maxBookings} Horses', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(b.notes ?? '', fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return const SizedBox.shrink(); // Place for highlights
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
