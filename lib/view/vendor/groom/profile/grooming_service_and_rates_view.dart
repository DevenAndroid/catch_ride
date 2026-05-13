import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/utils/grooming_rates_util.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  final List<String>? additionalSkills;

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
    this.additionalSkills,
  });

  @override
  State<GroomingServiceAndRatesView> createState() => _GroomingServiceAndRatesViewState();
}

class _GroomingServiceAndRatesViewState extends State<GroomingServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> groomingRoot =
        Map<String, dynamic>.from(widget.groomingData as Map);
    final dynamic profileDataRaw = groomingRoot['profileData'];
    final Map<String, dynamic> profileData = profileDataRaw is Map
        ? Map<String, dynamic>.from(profileDataRaw as Map)
        : groomingRoot;

    final Map<String, dynamic> rates = normalizeGroomingRatesMap(
      profileData['rates'] ?? groomingRoot['rates'],
    );
    final List<dynamic> services =
        coerceDynamicList(profileData['services'] ?? groomingRoot['services']);
    final List<dynamic> additionalServices = coerceDynamicList(
      profileData['additionalServices'] ?? groomingRoot['additionalServices'],
    );
    final List<dynamic> highlights = coerceDynamicList(
      profileData['experienceHighlights'] ?? groomingRoot['experienceHighlights'],
    );
    
    // Core services are usually simple boolean checks or priced
    final List coreServices = services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),

                // ── Rates Row ──────────────────────────────────────────────
                if (rates.isNotEmpty) ...[
                  _buildBaseRatesRow(rates),
                  const SizedBox(height: 20),
                ],

                // ── Core Services (Wrapped Grid) ──────────────────────────────
                if (coreServices.isNotEmpty) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: coreServices.map((s) {
                      final name = s is Map ? (s['name'] ?? s['label'] ?? 'Service') : s.toString();
                      return SizedBox(
                     //   width: (MediaQuery.of(context).size.width - 100) / 2,
                        child: _buildCheckItem(name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(height: 1, color: AppColors.dividerColor),
                const SizedBox(height: 20),

                if (highlights.isNotEmpty) ...[
                  _buildDetailItem('Experience Highlights', highlights.join(', ')),
                  const SizedBox(height: 12),
                ],

                // ── Additional Services ───────────────────────────────────────
                if (additionalServices.isNotEmpty) ...[
                  const CommonText(
                    'Additional Services',
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  ...additionalServices.map((s) {
                    final name = s is Map ? (s['name'] ?? s['label'] ?? 'Service') : s.toString();
                    final price = s is Map ? (s['price']?.toString() ?? '0') : '0';
                    final formattedPrice = NumberFormat('#,###').format(double.tryParse(price.replaceAll(',', '')) ?? 0);
                    return _buildPricedServiceItem(name, formattedPrice);
                  }),
                  const SizedBox(height: 8),
                ],

                // ── Extra Details (Show More) ──────────────────────────────────
                if (showMore) ...[
                  const Divider(height: 32, color: AppColors.dividerColor),
                  _buildTwoColumnDetails(
                    'Location', widget.location ?? '',
                    'Years of Experience', widget.experience ?? '',
                  ),
                  const SizedBox(height: 20),
                  _buildTwoColumnDetails(
                    'Disciplines', (widget.disciplines?.isEmpty ?? true) ? '' : widget.disciplines!.join(', '),
                    'Typical Level of Horses', (widget.horseLevels?.isEmpty ?? true) ? '' : widget.horseLevels!.join(', '),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem('Show & Barn Support', (widget.supportOptions?.isEmpty ?? true) ? '' : widget.supportOptions!.join(', ')),
                  const SizedBox(height: 20),
                  _buildTwoColumnDetails(
                    'Horse Handling', (widget.handlingOptions?.isEmpty ?? true) ? '' : widget.handlingOptions!.join(', '),
                    'Additional Skills', (widget.additionalSkills?.isEmpty ?? true) ? '' : widget.additionalSkills!.join(', '),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem('Travel Preferences', (widget.travelPreferences?.isEmpty ?? true) ? '' : widget.travelPreferences!.join(', ')),
                  const SizedBox(height: 20),
                  _buildDetailItem('Regions Covered', (widget.regionsCovered?.isEmpty ?? true) ? '' : widget.regionsCovered!.join(', ')),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => _showMoreDetails.value = false,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: const CommonText(
                      'View Less',
                      color: AppColors.linkBlue,
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _showMoreDetails.value = true,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: const CommonText(
                      'View More',
                      color: AppColors.linkBlue,
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBaseRatesRow(Map<String, dynamic> rates) {
    final daily = rates['daily']?.toString() ?? '';
    final weekly = rates['weekly']?['price']?.toString() ?? '';
    final weeklyDays = rates['weekly']?['days']?.toString() ?? '6';
    final monthly = rates['monthly']?['price']?.toString() ?? '';
    final String formattedDaily = (daily.isNotEmpty && daily != 'N/A') ? NumberFormat('#,###').format(double.tryParse(daily.replaceAll(',', '')) ?? 0) : '';
    final String formattedWeekly = (weekly.isNotEmpty && weekly != 'N/A') ? NumberFormat('#,###').format(double.tryParse(weekly.replaceAll(',', '')) ?? 0) : '';
    final String formattedMonthly = (monthly.isNotEmpty && monthly != 'N/A') ? NumberFormat('#,###').format(double.tryParse(monthly.replaceAll(',', '')) ?? 0) : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (formattedDaily.isNotEmpty) ...[
            _buildRateItem('\$ $formattedDaily', 'Day Rate'),
            if (formattedWeekly.isNotEmpty || formattedMonthly.isNotEmpty) _buildSeparator(),
          ],
          if (formattedWeekly.isNotEmpty) ...[
            _buildRateItem('\$ $formattedWeekly', 'Week Rate (${weeklyDays}d)'),
            if (formattedMonthly.isNotEmpty) _buildSeparator(),
          ],
          if (formattedMonthly.isNotEmpty) ...[
            _buildRateItem('\$ $formattedMonthly', 'Month Rate'),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator() => Container(width: 1, height: 24, color: AppColors.dividerColor.withValues(alpha: 0.5));

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(
          price,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 4),
        CommonText(
          label,
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPricedServiceItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: CommonText(
              name,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$ $price ',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const TextSpan(
                  text: '/ horse',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(String label1, String value1, String label2, String value2) {
    if (value1.isEmpty && value2.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: value1.isEmpty
                  ? const SizedBox.shrink()
                  : _buildDetailItem(label1, value1, showDivider: false),
            ),
            if (value1.isNotEmpty && value2.isNotEmpty) const SizedBox(width: 16),
            Expanded(
              child: value2.isEmpty
                  ? const SizedBox.shrink()
                  : _buildDetailItem(label2, value2, showDivider: false),
            ),
          ],
        ),
        const Divider(height: 24, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {bool showDivider = true}) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 6),
        CommonText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.dividerColor),
        ],
      ],
    );
  }
}
