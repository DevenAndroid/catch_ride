import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/vendor_travel_preference_payload.dart';

/// Read-only card: bodywork **services, session rates, travel, disciplines**, etc.
///
/// [bodyworkData] should be the **merged** service map from
/// [mergedVendorServiceDisplayData] / `getProfileDataByType('Bodywork')` (same as groom profile
/// card): `servicesData` + assigned profile + optional [VendorModel] `bodywork` embed.
/// Shapes supported:
/// - Postform: `profileData.services[]` with `name`, `rates` (`"30"` → price), `session`, `isSelected`
/// - Legacy embed: `bodyworkServices[]` with `label` + `session[{min,price}]`
/// - Preform: `applicationData` / root `disciplines`, `modalities` / `modalityOffered`, `homeBase`, …
class BodyworkServiceAndRatesView extends StatefulWidget {
  final Map bodyworkData;
  final String? location;
  final String? experience;
  final List<String>? disciplines;
  final List<String>? horseLevels;
  final List<String>? regionsCovered;
  final List<dynamic>? travelPreferences;
  /// Optional override; if **null** or **empty**, services are read from [bodyworkData] (merged profile).
  final List<dynamic>? services;
  final String? noteForTrainer;
  final List<String>? additionalSkills;

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
    this.noteForTrainer,
    this.additionalSkills,
  });

  @override
  State<BodyworkServiceAndRatesView> createState() => _BodyworkServiceAndRatesViewState();
}

class _BodyworkServiceAndRatesViewState extends State<BodyworkServiceAndRatesView> {
  final _showMoreDetails = false.obs;

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(v);
  }

  static bool _meaningfulRate(dynamic v) {
    if (v == null) return false;
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return false;
    final n = double.tryParse(s);
    if (n != null && n <= 0) return false;
    return true;
  }

  static bool _hasDisplayableRatesOrSession(Map<String, dynamic> m) {
    final r = m['rates'];
    if (r is Map) {
      for (final v in r.values) {
        if (_meaningfulRate(v)) return true;
      }
    }
    final sess = m['session'];
    return sess is List && sess.isNotEmpty;
  }

  /// Resolves [VendorModel]-style + `servicesData` service rows into a uniform map list.
  static List<Map<String, dynamic>> _normalizeServiceRows(List<dynamic> raw) {
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is! Map) {
        out.add({'name': e.toString(), 'rates': <String, dynamic>{}, 'isSelected': true});
        continue;
      }
      final m = Map<String, dynamic>.from(e);
      final name = (m['name'] ?? m['label'])?.toString() ?? '';
      if (name.isEmpty) continue;
      m['name'] = name;
      if (m['rates'] == null && m['session'] != null) {
        m['rates'] = <String, dynamic>{};
      }
      out.add(m);
    }
    return out;
  }

  /// Picks services list: explicit [widget.services] only if non-empty; else merged [bodyworkData].
  static List<Map<String, dynamic>> _resolveServicesList({
    required Map<String, dynamic> root,
    required Map<String, dynamic> profileLike,
    required List<dynamic>? widgetServices,
  }) {
    if (widgetServices != null && widgetServices.isNotEmpty) {
      return _normalizeServiceRows(widgetServices);
    }
    for (final bucket in <List<dynamic>?>[
      root['services'] is List ? List<dynamic>.from(root['services'] as List) : null,
      profileLike['services'] is List ? List<dynamic>.from(profileLike['services'] as List) : null,
      root['bodyworkServices'] is List ? List<dynamic>.from(root['bodyworkServices'] as List) : null,
      profileLike['bodyworkServices'] is List ? List<dynamic>.from(profileLike['bodyworkServices'] as List) : null,
    ]) {
      if (bucket != null && bucket.isNotEmpty) {
        return _normalizeServiceRows(bucket);
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final root = _asMap(widget.bodyworkData);

    // Nested assigned-service row vs flat merged map from getProfileDataByType
    final profileNested = _asMap(root['profile']?['profileData']);
    final profileData = profileNested.isNotEmpty ? profileNested : _asMap(root['profileData']);
    final profileLike = profileData.isNotEmpty ? profileData : root;

    final applicationNested = _asMap(root['application']?['applicationData']);
    final applicationData = applicationNested.isNotEmpty
        ? applicationNested
        : _asMap(root['applicationData']);

    final services = _resolveServicesList(
      root: root,
      profileLike: profileLike,
      widgetServices: widget.services,
    );

    final selectedServices = services.where((m) {
      if (m['isSelected'] == false) {
        return _hasDisplayableRatesOrSession(m);
      }
      return m['isSelected'] == true || m['isSelected'] == null || _hasDisplayableRatesOrSession(m);
    }).toList();

    // Location / experience — VendorModel preform + applicationData + overrides
    final displayLocation = widget.location ??
        _locationFromApplication(applicationData, root);
    final displayExperience = widget.experience ?? _experienceFromApplication(applicationData, root);

    // Disciplines / levels / regions — commonPreform + applicationData (typo desciplines)
    final List<dynamic> disciplines = widget.disciplines ??
        _coerceStringList(
          applicationData['disciplines'] ??
              applicationData['desciplines'] ??
              root['disciplines'] ??
              root['desciplines'],
        );
    final List<dynamic> horseLevels = widget.horseLevels ??
        _coerceStringList(
          applicationData['horseLevels'] ??
              applicationData['typicalLevelOfHorses'] ??
              root['horseLevels'] ??
              root['typicalLevelOfHorses'],
        );
    final List<dynamic> travelPreferences = widget.travelPreferences ??
        (profileLike['travelPreferences'] is List
            ? List<dynamic>.from(profileLike['travelPreferences'] as List)
            : root['travelPreferences'] is List
                ? List<dynamic>.from(root['travelPreferences'] as List)
                : <dynamic>[]);

    final List<dynamic> regionsCovered = widget.regionsCovered ??
        _coerceStringList(
          applicationData['regions'] ??
              applicationData['regionsCovered'] ??
              root['regions'] ??
              root['regionsCovered'],
        );

    final String? scopeOfWork = applicationData['scopeOfWork']?.toString();

    final List<dynamic> highlights = applicationData['experienceHighlights'] is List
        ? List<dynamic>.from(applicationData['experienceHighlights'] as List)
        : profileLike['experienceHighlights'] is List
            ? List<dynamic>.from(profileLike['experienceHighlights'] as List)
            : root['experienceHighlights'] is List
                ? List<dynamic>.from(root['experienceHighlights'] as List)
                : widget.bodyworkData['experienceHighlights'] is List
                    ? List<dynamic>.from(widget.bodyworkData['experienceHighlights'] as List)
                    : <dynamic>[];

    // VendorModel preform: modalityOffered / application modalities
    final List<dynamic> modalities = _coerceStringList(
      applicationData['modalities'] ?? applicationData['modalityOffered'] ?? root['modalityOffered'],
    );

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

            _buildTwoColumnDetails(
              'Location',
              displayLocation,
              'Years of Experience',
              displayExperience,
            ),



            if (disciplines.isNotEmpty) ...[
              _buildDetailItem(
                'Disciplines',
                disciplines.map((e) => e.toString()).join(', '),
              ),
              const SizedBox(height: 16),
            ],
            if (horseLevels.isNotEmpty) ...[
              _buildDetailItem(
                'Typical Level of Horses',
                horseLevels.map((e) => e.toString()).join(', '),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.additionalSkills?.isNotEmpty ?? false) ...[
              _buildDetailItem('Additional Skills', widget.additionalSkills!.join(', ')),
              const SizedBox(height: 16),
            ],
            if (regionsCovered.isNotEmpty) ...[
              _buildRegionsList(
                'Regions Covered',
                regionsCovered.map((e) => e.toString()).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (highlights.isNotEmpty) ...[
              _buildDetailItem('Experience Highlights', highlights.map((e) => e.toString()).join(', ')),
              const SizedBox(height: 16),
            ],
            if (widget.noteForTrainer != null && widget.noteForTrainer!.isNotEmpty) ...[
              _buildDetailItem('Note for trainer', widget.noteForTrainer!),
              const SizedBox(height: 16),
            ],

            if (showMore) ...[
              const SizedBox(height: 4),
              if (modalities.isNotEmpty)
                _buildDetailItem(
                  'Modalities offered',
                  modalities.map((e) => e.toString()).join(', '),
                ),
              if (modalities.isNotEmpty &&
                  ((scopeOfWork != null && scopeOfWork.isNotEmpty) ||
                      travelPreferences.isNotEmpty))
                const SizedBox(height: 16),
              if (scopeOfWork != null && scopeOfWork.isNotEmpty) ...[
                _buildDetailItem('Scope of Work', scopeOfWork),
                const SizedBox(height: 16),
              ],
              if (travelPreferences.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Travel Preferences',
                  travelPreferences
                      .map((t) =>
                          VendorTravelPreferencePayload.summaryForListItem(t))
                      .where((s) => s.trim().isNotEmpty)
                      .join(', '),
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
          ],
        );
      }),
    );
  }

  static List<dynamic> _coerceStringList(dynamic v) {
    if (v == null) return <dynamic>[];
    if (v is List) return List<dynamic>.from(v);
    if (v is String && v.trim().isNotEmpty) return [v];
    return <dynamic>[];
  }

  static String _locationFromApplication(Map<String, dynamic> app, Map<String, dynamic> root) {
    final hb = app['homeBase'];
    if (hb is Map) {
      final city = hb['city']?.toString() ?? '';
      final state = hb['state']?.toString() ?? '';
      if (city.isNotEmpty) {
        return state.isNotEmpty ? '$city, $state' : city;
      }
    }
    final hbl = root['homeBaseLocation'];
    if (hbl is Map) {
      final city = hbl['city']?.toString() ?? '';
      final state = hbl['state']?.toString() ?? '';
      if (city.isNotEmpty) {
        return state.isNotEmpty ? '$city, $state' : city;
      }
    }
    return 'N/A';
  }

  static String _experienceFromApplication(Map<String, dynamic> app, Map<String, dynamic> root) {
    final exp = app['experience'] ?? app['yearsExperience'] ?? root['yearsExperience'] ?? root['experience'];
    if (exp == null) return 'N/A';
    final t = exp.toString().trim();
    if (t.isEmpty) return 'N/A';
    return t.toLowerCase().contains('year') ? t : '$t Years';
  }

  Widget _buildServiceBlock(Map<String, dynamic> service) {
    final String name = service['name'] ?? service['label'] ?? 'Service';
    final Map<String, dynamic> ratesMap = service['rates'] is Map
        ? Map<String, dynamic>.from(service['rates'] as Map)
        : <String, dynamic>{};
    final List? sessionsList = service['session'] is List ? service['session'] as List : null;

    List<MapEntry<String, dynamic>> activeRates = [];

    if (ratesMap.isNotEmpty) {
      activeRates = ratesMap.entries
          .where((e) => _meaningfulRate(e.value))
          .map((e) => MapEntry(e.key.toString(), e.value))
          .toList();
    } else if (sessionsList != null && sessionsList.isNotEmpty) {
      activeRates = sessionsList
          .whereType<Map>()
          .where((s) => s['min'] != null && _meaningfulRate(s['price']))
          .map((s) => MapEntry(s['min'].toString(), s['price']))
          .toList();
    }

    activeRates.sort((a, b) {
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
                            '\$ ${NumberFormat('#,###').format(double.tryParse(e.value.toString().replaceAll(',', '')) ?? 0)}',
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: AppTextSizes.size12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 6),
        ...regions.map((r) => Padding(
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

