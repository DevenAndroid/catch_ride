import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

class GroomingServiceAndRatesView extends StatefulWidget {
  final Map groomingData;
  final String? location;
  final String? experience;
  final List<String>? disciplines;
  final List<String>? horseLevels;
  final List<String>? regionsCovered;
  final List<String>? travelPreferences;
  final List<String>? supportOptions;
  final List<String>? handlingOptions;

  const GroomingServiceAndRatesView({
    super.key,
    required this.groomingData,
    this.location,
    this.experience,
    this.disciplines,
    this.horseLevels,
    this.regionsCovered,
    this.travelPreferences,
    this.supportOptions,
    this.handlingOptions,
  });

  @override
  State<GroomingServiceAndRatesView> createState() => _GroomingServiceAndRatesViewState();
}

class _GroomingServiceAndRatesViewState extends State<GroomingServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
    final profileData = widget.groomingData['profileData'] ?? widget.groomingData;
    final Map rates = widget.groomingData['rates'] ?? profileData['rates'] ?? {};
    final List services = widget.groomingData['services'] ?? profileData['services'] ?? [];
    final List additionalServices = widget.groomingData['additionalServices'] ?? profileData['additionalServices'] ?? [];
    
    // Check if we have specialized priced services
    final List pricedServices = services.where((s) {
      if (s is! Map) return false;
      final p = s['price'];
      if (p == null) return false;
      if (p is num) return p != 0;
      return p.toString() != '0' && p.toString() != '0.0';
    }).toList();
    
    final List simpleServices = services.where((s) {
      if (s is! Map) return true;
      final p = s['price'];
      if (p == null) return true;
      if (p is num) return p == 0;
      return p.toString() == '0' || p.toString() == '0.0';
    }).toList();

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
              'Services & Rates',
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),

            // ── Base Rates (Row) ──────────────────────────────────────────
            if (rates.isNotEmpty && (rates['daily'] != null || rates['weekly'] != null)) ...[
              _buildBaseRatesRow(rates),
              const SizedBox(height: 20),
            ],

            // ── Core/Priced Services ──────────────────────────────────────
            if (pricedServices.isEmpty && simpleServices.isEmpty)
              _buildEmptyState('No services configured')
            else ...[
              ...pricedServices.map((s) => _buildServiceItem(s['name'] ?? 'Service', '\$ ${s['price']} / horse')),
              ...simpleServices.map((s) => _buildCheckItem(s is Map ? (s['name'] ?? 'Service') : s.toString())),
            ],

            // ── Additional Services ───────────────────────────────────────
            if (additionalServices.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...additionalServices.map((s) => _buildServiceItem(s is Map ? (s['name'] ?? 'Service') : s.toString(), '\$ ${s is Map ? (s['price'] ?? '0') : '0'} / horse')),
            ],

            const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),

            // ── Location & Experience ──────────────────────────────────────
            _buildTwoColumnDetails(
              'Location',
              widget.location ?? 'N/A',
              'Years of Experience',
              widget.experience ?? 'N/A',
            ),

            // ── View More / View Less ──────────────────────────────────────
            if (showMore) ...[
              const SizedBox(height: 20),
              if (widget.disciplines?.isNotEmpty ?? false)
                _buildDetailItem('Disciplines', widget.disciplines!.join(', ')),
              if (widget.horseLevels?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Typical Level of Horses', widget.horseLevels!.join(', ')),
              ],
              if (widget.supportOptions?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Show & Barn Support', widget.supportOptions!.join(', ')),
              ],
              if (widget.handlingOptions?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Horse Handling', widget.handlingOptions!.join(', ')),
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

  Widget _buildBaseRatesRow(Map rates) {
    final daily = rates['daily']?.toString() ?? 'N/A';
    final weekly = rates['weekly']?['price']?.toString() ?? 'N/A';
    final monthly = rates['monthly']?['price']?.toString() ?? 'N/A';
    final wDays = rates['weekly']?['days']?.toString() ?? '5';
    final mDays = rates['monthly']?['days']?.toString() ?? '5';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRateItem(daily != 'N/A' ? '\$ $daily' : 'N/A', 'Day Rate'),
          _buildSeparator(),
          _buildRateItem(weekly != 'N/A' ? '\$ $weekly' : 'N/A', 'Week ($wDays d)'),
          _buildSeparator(),
          _buildRateItem(monthly != 'N/A' ? '\$ $monthly' : 'N/A', 'Month ($mDays d)'),
        ],
      ),
    );
  }

  Widget _buildSeparator() => Container(width: 1, height: 20, color: AppColors.borderLight);

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(price, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C)),
        const SizedBox(height: 2),
        CommonText(label, fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ],
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

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CommonText(message, fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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
