import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';

class BodyworkProfileCard extends StatelessWidget {
  final Map bodyworkData;
  final String location;
  final String experience;

  const BodyworkProfileCard({
    super.key,
    required this.bodyworkData,
    required this.location,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    final showMore = false.obs;

    // Extract data from the bodywork service object
    final List services = bodyworkData['services'] ?? [];
    final Map? insurance = bodyworkData['insurance'];
    final List travelPreferences = bodyworkData['travelPreferences'] ?? [];
    final Map? cancellationPolicy = bodyworkData['cancellationPolicy'];
    
    // Application level data (should be available in the main vendor object usually, but passed here)
    // For now we assume these come from the parent or the root of the service data
    final List disciplines = bodyworkData['disciplines'] ?? [];
    final List horseLevels = bodyworkData['horseLevels'] ?? [];
    final List regionsCovered = bodyworkData['regionsCovered'] ?? [];
    final List scopeOfWork = bodyworkData['scopeOfWork'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Services & Rates', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          const SizedBox(height: 16),

          ...services.map((s) => _buildServiceItem(s, showMore.value)).toList(),

          if (!showMore.value) ...[
             const SizedBox(height: 8),
             _buildNoteBox(),
          ],

          const Divider(height: 32, color: AppColors.dividerColor),

          _buildTwoColumnDetails(
            'Location', location, 
            'Years of Experience', experience
          ),

          if (showMore.value) ...[
            const SizedBox(height: 20),
            _buildTwoColumnDetails(
              'Disciplines', 
              disciplines.isEmpty ? 'N/A' : disciplines.join(', '),
              'Typical Level of Horses', 
              horseLevels.isEmpty ? 'N/A' : horseLevels.join(', ')
            ),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Scope of Work', scopeOfWork.isEmpty ? 'N/A' : scopeOfWork.join(', ')),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Travel Preferences', travelPreferences.isEmpty ? 'N/A' : travelPreferences.join(', ')),
            const SizedBox(height: 20),
            _buildSingleColumnDetail('Regions Covered', regionsCovered.isEmpty ? 'N/A' : regionsCovered.join(', ')),
            const SizedBox(height: 24),
          //  _buildDisclaimerBox(),
          ],

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => showMore.value = !showMore.value,
            child: CommonText(
              showMore.value ? 'View Less' : 'View More',
              color: AppColors.linkBlue,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildServiceItem(Map service, bool isExpanded) {
    final String name = service['name'] ?? 'Service';
    final Map rates = service['rates'] ?? {};
    
    if (isExpanded) {
      // Find a default price for expanded view, or just show its first available rate
      final String firstRate = rates.values.firstWhere((v) => v != null && v.toString().isNotEmpty, orElse: () => '0');
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: CommonText(name, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600)),
                CommonText('\$ $firstRate', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommonText(
                  'Sessions: ${rates.keys.join(', ')} mins', 
                  fontSize: 12, 
                  color: AppColors.textSecondary
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            CommonText(name, fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: rates.entries.map((e) => _buildRateBox(e.key, e.value)).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRateBox(String mins, dynamic price) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CommonText('\$ ${price ?? '0'}', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentRed),
          CommonText('$mins mins', fontSize: 10, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(String label1, String val1, String label2, String val2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDetailItem(label1, val1)),
        const SizedBox(width: 20),
        Expanded(child: _buildDetailItem(label2, val2)),
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

  Widget _buildNoteBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 4, color: Color(0xFF8B4444)),
          SizedBox(width: 6),
          CommonText(
            'Need vet approval & Trainer presence', 
            fontSize: 12, 
            color: Color(0xFF8B4444),
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const CommonText(
        'All services are provided within the scope of the provider’s certifications and are not a substitute for veterinary care.',
        fontSize: 12,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
        textAlign: TextAlign.center,
      ),
    );
  }
}
