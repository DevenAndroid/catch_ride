import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/string_utils.dart';

class ShippingServiceAndRatesView extends StatefulWidget {
  final Map shippingData;
  final String location;
  final String experience;
  final String baseRate;
  final String fullyLoadedRate;
  final List<String> travelScope;
  final List<String> regionsCovered;
  final List<String> servicesOffered;
  final List<String> rigTypes;
  final String operationType;
  final String rigCapacity;
  final String equipmentSummary;
  /// Vendor shipping postform additional notes (`additionalNotes` / legacy `notes`).
  final String additionalNotes;
  final String? dotNumber;
  final bool? hasCDL;
  final String? businessName;
  final List<String> highlights;
  final String? noteForTrainer;
  final List<String>? additionalSkills;

  const ShippingServiceAndRatesView({
    super.key,
    required this.shippingData,
    required this.location,
    required this.experience,
    required this.baseRate,
    required this.fullyLoadedRate,
    required this.travelScope,
    required this.regionsCovered,
    required this.servicesOffered,
    required this.rigTypes,
    required this.operationType,
    required this.rigCapacity,
    required this.equipmentSummary,
    this.additionalNotes = '',
    this.dotNumber,
    this.hasCDL,
    this.businessName,
    this.highlights = const [],
    this.noteForTrainer,
    this.additionalSkills,
  });

  @override
  State<ShippingServiceAndRatesView> createState() => _ShippingServiceAndRatesViewState();
}

class _ShippingServiceAndRatesViewState extends State<ShippingServiceAndRatesView> {
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
          ),
        ],
      ),
      child: Obx(() {
        final showMore = _showMoreDetails.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText(
              'Pricing',
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            if (widget.baseRate == 'Inquire for price') ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const CommonText(
                    'Inquire for price',
                    fontSize: AppTextSizes.size16,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ] else ...[
              _buildPriceItem('Base Rate', '\$ ${NumberFormat('#,###').format(double.tryParse(widget.baseRate.replaceAll(',', '')) ?? 0)} / '),
              const SizedBox(height: 12),
              _buildPriceItem('Fully Loaded', '\$ ${NumberFormat('#,###').format(double.tryParse(widget.fullyLoadedRate.replaceAll(',', '')) ?? 0)} / '),
            ],

            const Divider(height: 32, thickness: 1, color: AppColors.dividerColor),

            // ── Location & Experience ──────────────────────────────────────
            _buildTwoColumnDetails(
              'Location',
              widget.location,
              'Years of Experience',
              widget.experience,
            ),



            const SizedBox(height: 20),

            // ── Travel Scope ──────────────────────────────────────────────
            _buildDetailItem(
              'Travel Scope',
              widget.travelScope.isEmpty ? 'N/A' : widget.travelScope.join(', '),
              showDivider: !showMore,
            ),

            // ── View More Content ──────────────────────────────────────────
            if (showMore) ...[
              if (widget.additionalSkills != null && widget.additionalSkills!.isNotEmpty) ...[
                _buildDetailItem('Additional Skills', widget.additionalSkills!.join(', ')),
                const SizedBox(height: 12),
              ],
              // ── Regions Covered ──────────────────────────────────────────────
              if (widget.regionsCovered.isNotEmpty) ...[
                _buildRegionsList('Regions Covered', widget.regionsCovered),
                const SizedBox(height: 12),
              ],
              if (widget.highlights.isNotEmpty) ...[
                _buildDetailItem('Experience Highlights', widget.highlights.join(' • ')),
                const SizedBox(height: 12),
              ],
              if (widget.noteForTrainer != null && widget.noteForTrainer!.isNotEmpty) ...[
                _buildDetailItem('Note for trainer', widget.noteForTrainer!),
                const SizedBox(height: 12),
              ],

              // ── Services Offered ──────────────────────────────────────────────
              if (widget.servicesOffered.isNotEmpty) ...[
                _buildDetailItem('Services Offered', widget.servicesOffered.map((e) => StringUtils.capitalizeServiceWords(e)).join(', ')),
                const SizedBox(height: 12),
              ],

              // ── Rig types ────────────────────────────────────────────────────
              if (widget.rigTypes.isNotEmpty) ...[
                _buildDetailItem('Rig types', widget.rigTypes.join(', ')),
                const SizedBox(height: 12),
              ],

              // ── Operation Type ───────────────────────────────────────────────
              _buildDetailItem('Operation Type', widget.operationType),
              const SizedBox(height: 12),

              // ── Capacity Range ───────────────────────────────────────────────
              _buildDetailItem(
                'Capacity Range',
                'Typical load: ${widget.rigCapacity} horses',
              ),

              const SizedBox(height: 20),

              // ── Equipment & CDL ──────────────────────────────────────────────
              _buildDetailItem('Equipment summary', widget.equipmentSummary),
              const SizedBox(height: 12),

              if (widget.additionalNotes.trim().isNotEmpty) ...[
                _buildDetailItem('Additional notes', widget.additionalNotes.trim()),
                const SizedBox(height: 12),
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
          ],
        );
      }),
    );
  }

  Widget _buildPriceItem(String label, String price) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            label,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        CommonText(
          price,
          fontSize: AppTextSizes.size16,
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
        CommonText(
          "per mile",
          fontSize: AppTextSizes.size16,
        ),
      ],
    );
  }

  Widget _buildTwoColumnDetails(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDetailItem(label1, value1, showDivider: false)),
            const SizedBox(width: 20),
            Expanded(child: _buildDetailItem(label2, value2, showDivider: false)),
          ],
        ),
        const Divider(height: 24, color: AppColors.dividerColor),
      ],
    );
  }

  Widget _buildRegionsList(String label, List<String> regions) {
    if (regions.isEmpty) return const SizedBox.shrink();
    final List<String> flatRegions = [];
    for (final r in regions) {
      if (r == null) continue;
      flatRegions.addAll(r.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    if (flatRegions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: AppTextSizes.size12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 6),
        ...flatRegions.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: CommonText(
                  r,
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        )),
        const Divider(height: 24, color: AppColors.dividerColor),
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

