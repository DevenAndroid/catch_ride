import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';

class GroomingServiceAndRatesView extends StatelessWidget {
  final Map groomingData;
  final String? location;
  final String? experience;

  const GroomingServiceAndRatesView({
    super.key,
    required this.groomingData,
    this.location,
    this.experience,
  });

  @override
  Widget build(BuildContext context) {
    final Map rates = groomingData['rates'] ?? {};
    final List coreServices = groomingData['services'] ?? [];
    final List additionalServices = groomingData['additionalServices'] ?? [];
    final Map? capabilities = groomingData['capabilities'];
    final List travelPreferences = groomingData['travelPreferences'] ?? [];

    final String dailyRate = rates['daily']?.toString() ?? 'N/A';
    final String weeklyRate = rates['weekly']?['price']?.toString() ?? 'N/A';
    final String monthlyRate = rates['monthly']?['price']?.toString() ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Base Rates'),
          _buildRatesCard(dailyRate, weeklyRate, monthlyRate, rates['weekly']?['days']?.toString() ?? '5', rates['monthly']?['days']?.toString() ?? '5'),

          const SizedBox(height: 24),
          _buildSectionHeader('Core Services'),
          if (coreServices.isEmpty)
            _buildEmptyState('No core services configured')
          else
            _buildServicesList(coreServices),

          if (additionalServices.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Additional Services'),
            _buildServicesList(additionalServices),
          ],

          const SizedBox(height: 24),
          _buildSectionHeader('Experience & Location'),
          _buildExperienceLocationCard(),

          if (capabilities != null) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Capabilities'),
            _buildCapabilitiesCard(capabilities),
          ],

          const SizedBox(height: 24),
          _buildSectionHeader('Travel Preferences'),
          if (travelPreferences.isEmpty)
            _buildEmptyState('No travel preferences set')
          else
            _buildTravelCard(travelPreferences),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: CommonText(
        title,
        fontSize: AppTextSizes.size16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: CommonText(message, fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildRatesCard(String daily, String weekly, String monthly, String wDays, String mDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRateItem(daily != 'N/A' ? '\$ $daily' : 'N/A', 'Day Rate'),
          _buildRateItem(weekly != 'N/A' ? '\$ $weekly' : 'N/A', 'Week ($wDays d)'),
          _buildRateItem(monthly != 'N/A' ? '\$ $monthly' : 'N/A', 'Month ($mDays d)'),
        ],
      ),
    );
  }

  Widget _buildRateItem(String price, String label) {
    return Column(
      children: [
        CommonText(price, fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C)),
        const SizedBox(height: 4),
        CommonText(label, fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _buildServicesList(List services) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: services.map((s) {
          final isMap = s is Map;
          final String name = isMap ? (s['name'] ?? 'N/A') : s.toString();
          final String price = isMap ? (s['price']?.toString() ?? '0') : '0';
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF15803D)),
                const SizedBox(width: 12),
                Expanded(child: CommonText(name, fontSize: 14, fontWeight: FontWeight.w600)),
                if (price != '0')
                   CommonText('\$$price', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfoColumn('Primary Location', location ?? 'N/A', Icons.location_on_outlined)),
          Container(width: 1, height: 40, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(child: _buildInfoColumn('Experience', experience ?? 'N/A', Icons.auto_graph_outlined)),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            CommonText(label, fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        CommonText(value, fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ],
    );
  }

  Widget _buildCapabilitiesCard(Map cap) {
    final List support = List.from(cap['support'] ?? []);
    final List handling = List.from(cap['handling'] ?? []);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (support.isNotEmpty) ...[
            const CommonText('Show & Barn Support', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: support.map((s) => _buildSimpleTag(s.toString())).toList()),
          ],
          if (support.isNotEmpty && handling.isNotEmpty) const SizedBox(height: 16),
          if (handling.isNotEmpty) ...[
            const CommonText('Horse Handling', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: handling.map((h) => _buildSimpleTag(h.toString())).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelCard(List travel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: travel.map((t) {
          final isMap = t is Map;
          final String title = isMap ? (t['region'] ?? t['name'] ?? 'Travel Area') : t.toString();
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.drive_eta_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: CommonText(title, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSimpleTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: CommonText(label, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
