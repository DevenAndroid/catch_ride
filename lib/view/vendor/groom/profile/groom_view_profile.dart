import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/view/vendor/groom/profile/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroomViewProfile extends StatefulWidget {
  const GroomViewProfile({super.key});

  @override
  State<GroomViewProfile> createState() => _GroomViewProfileState();
}

class _GroomViewProfileState extends State<GroomViewProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _showMoreDetails = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroomViewProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(controller),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildBio(controller),
                      const SizedBox(height: 16),
                      _buildHighlights(controller),
                      const SizedBox(height: 16),
                      _buildSocials(controller),
                      const SizedBox(height: 16),
                      _buildPaymentMethods(controller),
                      const SizedBox(height: 24),
                      _buildTabs(),
                      const SizedBox(height: 20),
                      _buildDetailsCard(controller),
                      const SizedBox(height: 24),
                      _buildPhotosSection(controller),
                      const SizedBox(height: 24),
                      _buildAvailabilitySection(controller),
                      const SizedBox(height: 24),
                      _buildCancellationPolicy(controller),
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

  Widget _buildHeader(GroomViewProfileController controller) {
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
              CommonText(controller.businessNameDisplay, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFE11D48), size: 14),
                  const SizedBox(width: 4),
                  Obx(() => CommonText(controller.locationStr.value, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Obx(() => CommonText('Grooming  •  ${controller.experienceStr.value}', fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBio(GroomViewProfileController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CommonText(
        controller.bioDisplay,
        fontSize: AppTextSizes.size14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildSocials(GroomViewProfileController controller) {
    if (controller.instagramUrl.isEmpty && controller.facebookUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Row(
          children: [
            if (controller.instagramUrl.isNotEmpty) _buildSocialButton('Instagram', Icons.camera_alt_outlined, AppColors.accentRedLight),
            if (controller.instagramUrl.isNotEmpty && controller.facebookUrl.isNotEmpty) const SizedBox(width: 12),
            if (controller.facebookUrl.isNotEmpty) _buildSocialButton('Facebook', Icons.facebook, AppColors.linkBlue),
          ],
        ),
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

  Widget _buildPaymentMethods(GroomViewProfileController controller) {
    return GestureDetector(
      onTap: () => Get.to(() => const PaymentMethods()),
      child: Obx(() {
        final methods = controller.paymentMethods;
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
                  }).toList().reversed, // Reverse to show first on top if needed, or normal for standard stack
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
          ],
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildDetailsCard(GroomViewProfileController controller) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRateItem('\$ ${controller.dailyRate}', 'Day Rate'),
              _buildRateItem('\$ ${controller.weeklyRate}', 'Week Rate (${controller.weeklyDays}d)'),
              _buildRateItem('\$ ${controller.monthlyRate}', 'Month Rate (${controller.monthlyDays}d)'),
            ],
          ),
          const SizedBox(height: 20),
          ..._buildCapabilityItems(controller),
          const SizedBox(height: 20),
          const CommonText('Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          if (controller.additionalServices.isEmpty)
            const CommonText('No additional services', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          ...controller.additionalServices.map((s) => _buildAdditionalService(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'} / horse')),
          const SizedBox(height: 16),
          _buildViewMoreSection(controller),
        ],
      ),
    );
  }

  List<Widget> _buildCapabilityItems(GroomViewProfileController controller) {
    final List<String> items = {
      ...controller.groomingServices,
      ...controller.supportOptions,
      ...controller.handlingOptions,
    }.toList();
    return items.map((it) => _buildCheckItem(it)).toList();
  }

  Widget _buildViewMoreSection(GroomViewProfileController controller) {
    return Obx(() {
      if (_showMoreDetails.value) {
        return Column(
          children: [
            const Divider(height: 32, color: AppColors.dividerColor),
            _buildTwoColumnDetails(
              'Location',
              controller.locationStr.value,
              'Years of Experience',
              controller.experienceStr.value,
            ),
            const SizedBox(height: 20),
            _buildTwoColumnDetails(
              'Disciplines',
              controller.disciplinesSelected.isEmpty ? 'N/A' : controller.disciplinesSelected.join(', '),
              'Horse Levels',
              controller.horseLevels.isEmpty ? 'N/A' : controller.horseLevels.join(', '),
            ),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Show & Barn Support', controller.supportOptions.isEmpty ? 'N/A' : controller.supportOptions.join(', ')),
            const SizedBox(height: 20),
            _buildTwoColumnDetails(
              'Horse Handling',
              controller.handlingOptions.isEmpty ? 'N/A' : controller.handlingOptions.join(', '),
              'Travel Preferences',
              controller.travelPreferences.isEmpty ? 'N/A' : controller.travelPreferences.join(', '),
            ),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Operating Regions', controller.operatingRegions.isEmpty ? 'N/A' : controller.operatingRegions.join(', ')),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showMoreDetails.value = false,
              child: const CommonText('View Less', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }
      return GestureDetector(
        onTap: () => _showMoreDetails.value = true,
        child: const CommonText('View More', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
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

  Widget _buildPhotosSection(GroomViewProfileController controller) {
    final media = controller.allMedia;
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
              child: _buildPhotoItem(url),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String url) {
    return Container(
      width: Get.width * 0.28,
      height: 100,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: CommonImageView(url: url, fit: BoxFit.cover),
    );
  }

  Widget _buildAvailabilitySection(GroomViewProfileController controller) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            CommonText('Upcoming Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isAvailabilityLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.availabilityList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: CommonText('No upcoming availability found.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary)),
            );
          }
          return Column(
            children: controller.availabilityList.map((avail) {
              final String startDate = avail['startDate'] != null ? DateUtil.formatDisplayDate(DateTime.parse(avail['startDate'])) : 'N/A';
              final String endDate = avail['endDate'] != null ? DateUtil.formatDisplayDate(DateTime.parse(avail['endDate'])) : '';
              final String range = endDate.isNotEmpty ? '$startDate - $endDate' : startDate;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAvailabilityCard(
                  dates: range,
                  location: avail['location']?['city'] != null ? '${avail['location']['city']}, ${avail['location']['state'] ?? ''}' : 'Multiple Locations',
                  tags: List<String>.from(avail['serviceTypes'] ?? ['Grooming']),
                  maxHorses: 'Max ${avail['maxBookings'] ?? 1} Horses',
                  maxDays: 'Available',
                  note: avail['notes'] ?? 'Contact vendor for more details.',
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAvailabilityCard({
    required String dates,
    required String location,
    required List<String> tags,
    required String maxHorses,
    required String maxDays,
    required String note,
    bool showMore = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
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
                    CommonText(dates, color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        CommonText(location, color: Colors.white70, fontSize: AppTextSizes.size12),
                      ],
                    ),
                  ],
                ),
                if (showMore) const Icon(Icons.more_vert, color: Colors.white),
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
                  children: tags.map((t) => Container(
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
                    CommonText(maxHorses, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    const SizedBox(width: 20),
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText(maxDays, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(note, fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy(GroomViewProfileController controller) {
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
            controller.cancellationPolicy,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4444),
          ),
          const SizedBox(height: 4),
          const CommonText(
            'Late cancellations may incur a fee or may not be eligible for a refund as per vendor rules.',
            fontSize: AppTextSizes.size12,
            color: Color(0xFF8B4444),
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(GroomViewProfileController controller) {
    if (controller.highlights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Professional Highlights', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        ...controller.highlights.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.star_outline, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(child: CommonText(h, fontSize: AppTextSizes.size14, color: AppColors.textSecondary)),
            ],
          ),
        )),
      ],
    );
  }
}
