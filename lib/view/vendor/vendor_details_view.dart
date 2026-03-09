import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_button.dart';

import 'package:catch_ride/models/vendor_model.dart';

class VendorDetailsView extends StatelessWidget {
  final VendorModel vendor;
  const VendorDetailsView({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildBasicInfo(),
                    _buildAboutSection(),
                    _buildDetailsSection(),
                    _buildUpcomingAvailability(),
                    _buildCancelationPolicy(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CommonImageView(
          url: vendor.coverImage ?? AppConstants.dummyImageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 44,
          left: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CommonImageView(
              url: vendor.profilePhoto ?? AppConstants.dummyImageUrl,
              width: 100,
              height: 100,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(vendor.fullName, fontSize: 24, fontWeight: FontWeight.bold),
              const SizedBox(width: 8),
              if (vendor.yearsExperience != null)
                CommonText('• ${vendor.yearsExperience} years', fontSize: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          if (vendor.phone != null)
            CommonText(vendor.phone!, fontSize: 14, color: AppColors.textSecondary),
          CommonText(vendor.email, fontSize: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('About', fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          CommonText(
            vendor.bio ?? "No bio provided.",
            fontSize: 14,
            color: AppColors.textPrimary.withOpacity(0.7),
            height: 1.5,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFF04438), size: 16),
              const SizedBox(width: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Outfit'),
                  children: [
                    TextSpan(text: '${vendor.businessName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '• ${vendor.location ?? "Wellington, FL"}', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Details', fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _buildDetailRow('Services', vendor.services.isNotEmpty ? vendor.services.map((s) => s.name).join(", ") : vendor.serviceType),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEAECF0)),
                ),
                _buildDetailRow('Business Name', vendor.businessName),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEAECF0)),
                ),
                _buildDetailRow('Operating Regions', vendor.location ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        CommonText(value, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildUpcomingAvailability() {
    if (vendor.serviceAvailability.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CommonText('Upcoming Availability', fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...vendor.serviceAvailability.map((avail) => _buildAvailabilityCard(avail)).toList(),
      ],
    );
  }

  Widget _buildAvailabilityCard(VendorAvailability avail) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B4242).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF8B4242),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('${avail.startDate ?? ""} - ${avail.endDate ?? ""}', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    CommonText(avail.serviceRegion ?? 'General Area', color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ],
                ),
              ],
            ),
          ),
// ...
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Show Week Support'),
                      const SizedBox(width: 8),
                      _buildChip('Full - in/ Daily Show Support'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildIconText(Icons.pets_outlined, 'Max 6 Horses'),
                    const SizedBox(width: 24),
                    _buildIconText(Icons.calendar_today_outlined, 'Max 8 Days'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CommonText(
                        'Prefer mornings. Experience with warmbloods.',
                        fontSize: 12,
                        color: AppColors.textSecondary,
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

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CommonText(text, fontSize: 11, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        CommonText(text, fontSize: 13, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildCancelationPolicy() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE4E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF04438), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText('Cancelation Policy', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB42318)),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,',
            fontSize: 13,
            color: Color(0xFFB42318),
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CommonButton(
              text: 'Send Booking Request',
              backgroundColor: const Color(0xFF00083B),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4242),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    CommonText('Message', color: Colors.white, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
