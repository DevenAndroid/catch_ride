import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

class BraidingServiceAndRatesView extends StatefulWidget {
  final Map braidingData;
  final String? location;
  final String? experience;
  final List<String>? disciplines;
  final List<String>? horseLevels;
  final List<String>? regionsCovered;
  final List<String>? travelPreferences;

  const BraidingServiceAndRatesView({
    super.key,
    required this.braidingData,
    this.location,
    this.experience,
    this.disciplines,
    this.horseLevels,
    this.regionsCovered,
    this.travelPreferences,
  });

  @override
  State<BraidingServiceAndRatesView> createState() => _BraidingServiceAndRatesViewState();
}

class _BraidingServiceAndRatesViewState extends State<BraidingServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
    final profileData = widget.braidingData['profileData'] ?? widget.braidingData;
    final List services = widget.braidingData['services'] ?? profileData['services'] ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final showMore = _showMoreDetails.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText(
              'Braiding Services & Rates',
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),

            if (services.isEmpty)
              const Center(child: CommonText('No braiding services configured', fontSize: 13, color: AppColors.textSecondary))
            else
              ...services.map((s) => _buildServiceItem(s['name'] ?? 'Service', '\$ ${s['price'] ?? '0'} / horse')),

            const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),

            _buildTwoColumnDetails(
              'Location',
              widget.location ?? 'N/A',
              'Experience',
              widget.experience ?? 'N/A',
            ),

            if (showMore) ...[
              const SizedBox(height: 20),
              if (widget.disciplines?.isNotEmpty ?? false)
                _buildDetailItem('Disciplines', widget.disciplines!.join(', ')),
              if (widget.horseLevels?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Typical Level of Horses', widget.horseLevels!.join(', ')),
              ],
              if (widget.travelPreferences?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Travel Preferences', widget.travelPreferences!.join(', ')),
              ],
              if (widget.regionsCovered?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Regions Covered', widget.regionsCovered!.join(', ')),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showMoreDetails.value = false,
                child: const CommonText('View less', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
              ),
            ] else ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showMoreDetails.value = true,
                child: const CommonText('View More', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildServiceItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: CommonText(name, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          CommonText(price, fontSize: AppTextSizes.size14, color: const Color(0xFFB91C1C), fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDetailItem(label1, value1, showDivider: false)),
        const SizedBox(width: 20),
        Expanded(child: _buildDetailItem(label2, value2, showDivider: false)),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        const SizedBox(height: 6),
        CommonText(value, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        if (showDivider) const Divider(height: 24, color: AppColors.dividerColor),
      ],
    );
  }
}
