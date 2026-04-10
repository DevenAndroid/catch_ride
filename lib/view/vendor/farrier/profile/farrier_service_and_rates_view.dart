import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

class FarrierServiceAndRatesView extends StatefulWidget {
  final Map farrierData;
  final String? location;
  final String? experience;
  final List<String>? disciplines;
  final List<String>? horseLevels;
  final List<String>? regionsCovered;
  final List<String>? travelPreferences;
  final List<dynamic>? services;
  final List<dynamic>? addOns;

  const FarrierServiceAndRatesView({
    super.key,
    required this.farrierData,
    this.location,
    this.experience,
    this.disciplines,
    this.horseLevels,
    this.regionsCovered,
    this.travelPreferences,
    this.services,
    this.addOns,
  });

  @override
  State<FarrierServiceAndRatesView> createState() => _FarrierServiceAndRatesViewState();
}

class _FarrierServiceAndRatesViewState extends State<FarrierServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
    final List services = widget.services ?? widget.farrierData['services'] ?? [];
    final List addOns = widget.addOns ?? widget.farrierData['addOns'] ?? [];

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

            if (services.isEmpty && addOns.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CommonText('No farrier services configured', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                ),
              )
            else ...[
              ...services.map((s) => _buildPricedItem(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'}')),
              if (addOns.isNotEmpty) ...[
                const SizedBox(height: 20),
                const CommonText('Add-ons', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                const SizedBox(height: 16),
                ...addOns.map((s) => _buildPricedItem(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'}')),
              ],
            ],

            const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),

            // ── Location & Experience ──────────────────────────────────────
            _buildTwoColumnDetails(
              'Location',
              widget.location ?? 'N/A',
              'Years of Experience',
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
