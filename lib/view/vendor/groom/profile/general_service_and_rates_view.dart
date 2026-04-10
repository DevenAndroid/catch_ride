import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

class GeneralServiceAndRatesView extends StatefulWidget {
  final String title;
  final String dailyRate;
  final String weeklyRate;
  final String weeklyDays;
  final String monthlyRate;
  final String monthlyDays;
  final List<dynamic> services;
  final List<dynamic> additionalServices;
  final List<String> supportOptions;
  final List<String> handlingOptions;
  final String location;
  final String experience;
  final List<String> disciplines;
  final List<String> horseLevels;
  final List<String> travelPreferences;
  final List<String> operatingRegions;
  final bool isClipping;

  const GeneralServiceAndRatesView({
    super.key,
    this.title = 'Services & Rates',
    required this.dailyRate,
    required this.weeklyRate,
    required this.weeklyDays,
    required this.monthlyRate,
    required this.monthlyDays,
    required this.services,
    required this.additionalServices,
    required this.supportOptions,
    required this.handlingOptions,
    required this.location,
    required this.experience,
    required this.disciplines,
    required this.horseLevels,
    required this.travelPreferences,
    required this.operatingRegions,
    this.isClipping = false,
  });

  @override
  State<GeneralServiceAndRatesView> createState() => _GeneralServiceAndRatesViewState();
}

class _GeneralServiceAndRatesViewState extends State<GeneralServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(widget.title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          
          if (widget.dailyRate != 'N/A' || widget.weeklyRate != 'N/A' || widget.monthlyRate != 'N/A') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRateItem('\$ ${widget.dailyRate}', 'Day Rate'),
                _buildRateItem('\$ ${widget.weeklyRate}', 'Week Rate (${widget.weeklyDays}d)'),
                _buildRateItem('\$ ${widget.monthlyRate}', 'Month Rate (${widget.monthlyDays}d)'),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (widget.isClipping)
            ...widget.services.map((s) => _buildPricedItem(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'} / horse'))
          else
            ..._buildCapabilityItems(),
          
          if (widget.additionalServices.isNotEmpty) ...[
            const SizedBox(height: 20),
            const CommonText('Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            ...widget.additionalServices.map((s) => _buildPricedItem(s['name'] ?? 'N/A', '\$ ${s['price'] ?? '0'} / horse')),
          ],

          const SizedBox(height: 20),
          _buildViewMoreSection(),
        ],
      ),
    );
  }

  List<Widget> _buildCapabilityItems() {
    final List<Widget> items = [];

    for (var s in widget.services) {
      if (s is Map) {
        items.add(_buildPricedItem(s['name'] ?? 'N/A', '\$${s['price'] ?? '0'}/horse'));
      } else {
        items.add(_buildCheckItem(s.toString()));
      }
    }

    for (var it in widget.supportOptions) {
      items.add(_buildCheckItem(it));
    }

    for (var it in widget.handlingOptions) {
      items.add(_buildCheckItem(it));
    }

    return items;
  }

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(price, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.secondary),
        CommonText(label, fontSize: AppTextSizes.size10, color: AppColors.textSecondary),
      ],
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

  Widget _buildViewMoreSection() {
    return Obx(() {
      if (_showMoreDetails.value) {
        return Column(
          children: [
            _buildTwoColumnDetails('Location', widget.location, 'Years of experience', widget.experience),
            const SizedBox(height: 20),
            _buildTwoColumnDetails(
              'Disciplines',
              widget.disciplines.isEmpty ? 'N/A' : widget.disciplines.join(', '),
              'Typical Level of Horses',
              widget.horseLevels.isEmpty ? 'N/A' : widget.horseLevels.join(', '),
            ),
            const SizedBox(height: 20),
            if (!widget.isClipping) ...[
              _buildSingleColumnDetail('Show & barn support', widget.supportOptions.isEmpty ? 'N/A' : widget.supportOptions.join(', ')),
              const SizedBox(height: 20),
              _buildTwoColumnDetails(
                'Horse handling',
                widget.handlingOptions.isEmpty ? 'N/A' : widget.handlingOptions.join(', '),
                'Travel preferences',
                widget.travelPreferences.isEmpty ? 'N/A' : widget.travelPreferences.join(', '),
              ),
            ] else ...[
              _buildSingleColumnDetail('Travel Preferences', widget.travelPreferences.isEmpty ? 'N/A' : widget.travelPreferences.join(', ')),
            ],
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Regions Covered', widget.operatingRegions.isEmpty ? 'N/A' : widget.operatingRegions.join(', ')),
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
          _buildTwoColumnDetails('Location', widget.location, 'Years of experience', widget.experience),
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
}
