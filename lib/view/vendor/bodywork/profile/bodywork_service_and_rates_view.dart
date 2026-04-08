import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';

class BodyworkServiceAndRatesView extends StatefulWidget {
  final Map bodyworkData;
  final String? location;
  final String? experience;
  final List<String>? disciplines;
  final List<String>? horseLevels;
  final List<String>? regionsCovered;
  final List<dynamic>? travelPreferences;
  final List<Map<String, dynamic>>? services;

  const BodyworkServiceAndRatesView({
    super.key,
    required this.bodyworkData,
    this.location,
    this.experience,
    this.disciplines,
    this.horseLevels,
    this.regionsCovered,
    this.travelPreferences,
    this.services,
  });

  @override
  State<BodyworkServiceAndRatesView> createState() => _BodyworkServiceAndRatesViewState();
}

class _BodyworkServiceAndRatesViewState extends State<BodyworkServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  @override
  Widget build(BuildContext context) {
    // Handle both flat and nested structures
    final profileData = widget.bodyworkData['profile']?['profileData'] ??
        widget.bodyworkData['profileData'] ??
        widget.bodyworkData;
    final applicationData = widget.bodyworkData['application']?['applicationData'] ??
        widget.bodyworkData['applicationData'] ??
        widget.bodyworkData;

    final List services = widget.services ?? profileData['services'] ?? [];
    final selectedServices = services
        .where((s) => s['isSelected'] == true || s['isSelected'] == null)
        .toList();

    // Location / experience
    final displayLocation = widget.location ??
        (applicationData['homeBase']?['city'] != null
            ? '${applicationData['homeBase']['city']}, ${applicationData['homeBase']['state'] ?? ''}'
            : 'N/A');
    final displayExperience = widget.experience ??
        (applicationData['experience'] != null
            ? '${applicationData['experience']} Years'
            : 'N/A');

    // Extra detail fields
    final List disciplines = widget.disciplines ?? applicationData['disciplines'] ?? [];
    final List horseLevels = widget.horseLevels ?? applicationData['horseLevels'] ?? [];
    final List travelPreferences = widget.travelPreferences ?? profileData['travelPreferences'] ?? [];
    final List regionsCovered =
        widget.regionsCovered ?? applicationData['regions'] ?? applicationData['regionsCovered'] ?? [];
    final String? scopeOfWork = applicationData['scopeOfWork']?.toString();

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

            // ── Service cards ──────────────────────────────────────────────
            if (selectedServices.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CommonText(
                  'No services configured.',
                  fontSize: AppTextSizes.size14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...selectedServices.map((s) => _buildServiceBlock(s)),

            const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),

            // ── Location & Experience ──────────────────────────────────────
            _buildTwoColumnDetails(
              'Location',
              displayLocation,
              'Years of Experience',
              displayExperience,
            ),

            // ── View More / View Less ──────────────────────────────────────
            if (showMore) ...[
              const SizedBox(height: 20),
              if (disciplines.isNotEmpty)
                _buildDetailItem(
                  'Disciplines',
                  disciplines.join(', '),
                ),
              if (horseLevels.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Typical Level of Horses',
                  horseLevels.join(', '),
                ),
              ],
              if (scopeOfWork != null && scopeOfWork.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailItem('Scope of Work', scopeOfWork),
              ],
              if (travelPreferences.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Travel Preferences',
                  travelPreferences
                      .map((t) => t is Map ? (t['type'] ?? '') : t.toString())
                      .join(', '),
                ),
              ],
              if (regionsCovered.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Regions Covered',
                  regionsCovered.join(', '),
                ),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showMoreDetails.value = false,
                child: const CommonText(
                  'View less',
                  color: AppColors.linkBlue,
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showMoreDetails.value = true,
                child: const CommonText(
                  'View More',
                  color: AppColors.linkBlue,
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 12),
            const CommonText(
              'All services are provided within the scope of the provider\'s certifications and are not a substitute for veterinary care.',
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  // ── Service block: name row + rate price-boxes ─────────────────────────
  Widget _buildServiceBlock(Map service) {
    final String name = service['name'] ?? 'Service';
    final Map rates = service['rates'] ?? {};

    // Collect non-empty rate entries sorted by duration value
    final activeRates = rates.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList()
      ..sort((a, b) {
        final aVal = int.tryParse(a.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bVal = int.tryParse(b.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aVal.compareTo(bVal);
      });

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CommonText(
                  name,
                  fontSize: AppTextSizes.size18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (activeRates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: activeRates.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  final isLast = idx == activeRates.length - 1;
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                right: BorderSide(color: AppColors.dividerColor),
                              ),
                      ),
                      child: Column(
                        children: [
                          CommonText(
                            '\$ ${e.value}',
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB91C1C),
                          ),
                          const SizedBox(height: 2),
                          CommonText(
                            '${e.key} mins',
                            fontSize: AppTextSizes.size12,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Two column row ──────────────────────────────────────────────────────
  Widget _buildTwoColumnDetails(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
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
        CommonText(
          label,
          fontSize: AppTextSizes.size12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 6),
        CommonText(
          value,
          fontSize: AppTextSizes.size14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        if (showDivider)
          const Divider(height: 24, color: AppColors.dividerColor),
      ],
    );
  }
}
