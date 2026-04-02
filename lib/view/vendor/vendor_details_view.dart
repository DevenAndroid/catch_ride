import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/vendor_details_controller.dart';
import 'package:catch_ride/view/bookings/send_booking_request_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailsView extends StatefulWidget {
  const VendorDetailsView({super.key});

  @override
  State<VendorDetailsView> createState() => _VendorDetailsViewState();
}

class _VendorDetailsViewState extends State<VendorDetailsView> {
  final controller = Get.put(VendorDetailsController());

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
            SingleChildScrollView(
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
                        _buildSocialsAndPayments(),
                        const SizedBox(height: 24),
                        _buildTabs(),
                        const SizedBox(height: 20),
                        _buildServiceDetails(),
                        const SizedBox(height: 24),
                        _buildPhotosSection(),
                        const SizedBox(height: 24),
                        _buildAvailabilitySection(),
                        const SizedBox(height: 24),
                        _buildCancellationPolicy(),
                        const SizedBox(height: 120), // Space for bottom buttons
                      ],
                    ),
                  ),
                ],
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
              top: 50,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  onPressed: () => Get.back(),
                ),
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
          padding: const EdgeInsets.only(left: 135, top: 8, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(controller.fullName, fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
              const SizedBox(height: 2),
              CommonText(controller.businessName, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.accentRedLight, size: 16),
                  const SizedBox(width: 4),
                  CommonText(controller.location, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ],
              ),
              const SizedBox(height: 6),
              CommonText(
                '${controller.availableServices.join(', ')}  •  10+ Years', // Experience should be dynamic if available
                fontSize: AppTextSizes.size14, 
                color: AppColors.textSecondary, 
                fontWeight: FontWeight.w600
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return CommonText(
      controller.bio,
      fontSize: AppTextSizes.size14,
      color: AppColors.textSecondary,
      height: 1.5,
    );
  }

  Widget _buildSocialsAndPayments() {
    return Column(
      children: [
        Row(
          children: [
            _buildSocialButton('Instagram', Icons.camera_alt_outlined, const Color(0xFFE1306C)),
            const SizedBox(width: 12),
            _buildSocialButton('Facebook', Icons.facebook, const Color(0xFF1877F2)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
             _buildPaymentIcons(),
             const SizedBox(width: 8),
             const CommonText('View all payment methods', fontSize: AppTextSizes.size12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
             const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
          ],
        )
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            CommonText(label, fontSize: AppTextSizes.size14, color: color, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcons() {
    final methods = controller.paymentMethods;
    // For demo, just show common icons
    return Row(
      children: [
        _buildSmallIcon(Icons.account_balance_wallet, const Color(0xFF3D95CE)), // Venmo placeholder
        const SizedBox(width: 4),
        _buildSmallIcon(Icons.currency_exchange, const Color(0xFF671BC4)), // Zelle placeholder
        const SizedBox(width: 4),
        _buildSmallIcon(Icons.payment, const Color(0xFF003087)), // PayPal
      ],
    );
  }

  Widget _buildSmallIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Row(
          children: controller.availableServices.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            final isSelected = controller.selectedTabIndex.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTabIndex.value = index,
                child: Column(
                  children: [
                    CommonText(
                      service, 
                      fontSize: AppTextSizes.size16, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildServiceDetails() {
    return Container(
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
              _buildRateBox('\$ ${controller.dailyRate}', 'Day Rate'),
              _buildRateBox('\$ ${controller.weeklyRate}', 'Week Rate (${controller.weeklyDays}d)'),
              _buildRateBox('\$ ${controller.monthlyRate}', 'Month Rate (${controller.monthlyDays}d)'),
            ],
          ),
          const SizedBox(height: 20),
          ...controller.includedServices.map((s) => _buildCheckItem(s)),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: AppColors.dividerColor),
          ),
          const SizedBox(height: 12),
          const CommonText('Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          ...controller.additionalServices.map((s) => _buildAdditionalService(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'} / horse')),
          const SizedBox(height: 16),
          const CommonText('View More', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildRateBox(String amount, String label) {
    return Container(
      width: Get.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          CommonText(amount, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.secondary),
          const SizedBox(height: 2),
          CommonText(label, fontSize: AppTextSizes.size10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
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
          Expanded(child: CommonText(name, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          CommonText(price, fontSize: AppTextSizes.size14, color: AppColors.secondary, fontWeight: FontWeight.bold),
        ],
      ),
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
                width: 110,
                height: 110,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: CommonImageView(url: url, fit: BoxFit.cover),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            CommonText('Upcoming Availability', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.isAvailabilityLoading.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.availabilityList.isEmpty)
          const Center(child: CommonText('No availability found', color: AppColors.textSecondary))
        else
          ...controller.availabilityList.map((avail) => _buildAvailabilityCard(avail)),
      ],
    );
  }

  Widget _buildAvailabilityCard(dynamic avail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText('Mar 10 - Mar 18, 2026', color: Colors.white, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                          SizedBox(width: 4),
                          CommonText('Wellington, WEC Ocala', color: Colors.white70, fontSize: AppTextSizes.size12),
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
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag('Show Week Support'),
                    _buildTag('Fill In Daily Show Support'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.work_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const CommonText('Max 6 Horses', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const CommonText('Max 5 Days', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Expanded(
                      child: CommonText(
                        'Prefer mornings. Experience with young horses.', 
                        fontSize: AppTextSizes.size12, 
                        color: AppColors.textSecondary
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCancellationPolicy() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoBoxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cancel_outlined, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              CommonText('Cancellation Policy', color: AppColors.secondary, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          CommonText(
            controller.cancellationPolicy,
            fontSize: AppTextSizes.size14,
            color: AppColors.secondary,
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _showServiceSelectionBottomSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const CommonText('Send Booking Request', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
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
        ),
      ),
    );
  }

  void _showServiceSelectionBottomSheet() {
    final RxString localSelected = controller.availableServices.isNotEmpty 
      ? controller.availableServices.first.obs 
      : ''.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            service, 
                            fontSize: 16, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.borderLight,
                                width: 2,
                              ),
                            ),
                            child: isSelected 
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                          ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
