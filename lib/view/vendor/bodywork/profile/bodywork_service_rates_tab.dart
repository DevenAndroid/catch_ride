import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/grooming_rates_util.dart';
import 'package:catch_ride/utils/price_formatter.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bodywork rates editor for **Services & Rates** — uses [GroomViewProfileController]
/// and [GroomViewProfileController.updateBodyworkServiceRates] so saves match grooming:
/// `servicesData.bodywork.profileData`, service-document sync, and in-memory profile refresh.
class BodyworkServiceRatesTab extends StatefulWidget {
  final String serviceType;
  const BodyworkServiceRatesTab({super.key, this.serviceType = 'Bodywork'});

  @override
  State<BodyworkServiceRatesTab> createState() => _BodyworkServiceRatesTabState();
}

class _BodyworkServiceRatesTabState extends State<BodyworkServiceRatesTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GroomViewProfileController controller = Get.find<GroomViewProfileController>();

  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingServices = false.obs;

  static const List<String> _fallbackServiceNames = [
    'Sports massage',
    'Myofascial release',
    'PEMF',
    'Chiropractic',
    'Acupuncture',
    'Laser therapy',
    'Red Light',
  ];

  static const List<String> _sessionKeys = ['30', '45', '60', '90'];

  static const List<String> _trainerPresenceOptions = [
    'Required',
    'Preferred',
    'Not Required',
  ];

  static const List<String> _vetApprovalOptions = [
    'Required',
    'Sometimes Required',
    'Not Required',
  ];

  /// Prices that are empty or `0` are treated as "not configured" (no summary row, sheet unchecked).
  static bool _meaningfulBodyworkRate(dynamic v) {
    if (v == null) return false;
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return false;
    final n = double.tryParse(s);
    if (n != null && n <= 0) return false;
    return true;
  }

  static Map<String, dynamic> _sanitizeBodyworkRatesMap(dynamic raw) {
    final out = <String, dynamic>{};
    for (final k in _sessionKeys) {
      dynamic v;
      if (raw is Map) {
        final m = raw;
        v = m[k] ?? m[int.tryParse(k)];
      }
      out[k] = _meaningfulBodyworkRate(v) ? v.toString().trim() : '';
    }
    return out;
  }

  /// [DropdownButton] requires [value] to be null or exactly one [DropdownMenuItem.value].
  static String? _coerceBodyworkDropdownValue(String? raw, List<String> options) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    for (final o in options) {
      if (o == t) return o;
      if (o.toLowerCase() == t.toLowerCase()) return o;
    }
    return null;
  }

  /// Same logical service must match catalog + saved profile even when casing differs.
  static String _canonServiceKey(String? name) =>
      (name ?? '').toLowerCase().trim();

  static List<String> _dedupeNamesInsensitive(Iterable<String> names) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in names) {
      final n = raw.toString().trim();
      if (n.isEmpty) continue;
      final k = _canonServiceKey(n);
      if (seen.add(k)) out.add(n);
    }
    return out;
  }

  static Map<String, dynamic> _mergeSavedServiceRows(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final ratesA = a['rates'] is Map
        ? Map<String, dynamic>.from(a['rates'] as Map)
        : <String, dynamic>{};
    final ratesB = b['rates'] is Map
        ? Map<String, dynamic>.from(b['rates'] as Map)
        : <String, dynamic>{};
    final keys = {...ratesA.keys, ...ratesB.keys, ..._sessionKeys};
    final rates = <String, dynamic>{};
    for (final k in keys) {
      final va = ratesA[k]?.toString().trim() ?? '';
      final vb = ratesB[k]?.toString().trim() ?? '';
      rates[k] = vb.isNotEmpty ? ratesB[k] : (va.isNotEmpty ? ratesA[k] : '');
    }
    final na = a['note']?.toString().trim() ?? '';
    final nb = b['note']?.toString().trim() ?? '';
    final trainerCoerced = _coerceBodyworkDropdownValue(
      (b['trainerPresence'] ?? a['trainerPresence'])?.toString(),
      _trainerPresenceOptions,
    );
    final vetCoerced = _coerceBodyworkDropdownValue(
      (b['vetApproval'] ?? a['vetApproval'])?.toString(),
      _vetApprovalOptions,
    );
    return {
      'name': (b['name']?.toString().trim().isNotEmpty == true)
          ? b['name']
          : a['name'],
      'isSelected': a['isSelected'] == true || b['isSelected'] == true,
      'rates': _sanitizeBodyworkRatesMap(rates),
      'note': nb.isNotEmpty ? b['note'] : (na.isNotEmpty ? a['note'] : ''),
      'trainerPresence': trainerCoerced,
      'vetApproval': vetCoerced,
    };
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _fetchServiceCatalog();
    _hydrateFromVendorProfile();
  }

  Map<String, dynamic> _defaultRow(String name) => {
        'name': name,
        'isSelected': false,
        'rates': _sanitizeBodyworkRatesMap(null),
        'note': '',
        'trainerPresence': null,
        'vetApproval': null,
      };

  Map<String, dynamic> _rowFromSaved(Map<String, dynamic> saved) {
    final name = saved['name']?.toString() ?? '';
    return {
      'name': name,
      'isSelected': saved['isSelected'] == true,
      'rates': _sanitizeBodyworkRatesMap(saved['rates']),
      'note': saved['note']?.toString() ?? '',
      'trainerPresence': _coerceBodyworkDropdownValue(
        saved['trainerPresence']?.toString(),
        _trainerPresenceOptions,
      ),
      'vetApproval': _coerceBodyworkDropdownValue(
        saved['vetApproval']?.toString(),
        _vetApprovalOptions,
      ),
    };
  }

  Future<void> _fetchServiceCatalog() async {
    isLoadingServices.value = true;
    try {
      final api = Get.find<ApiService>();
      final response = await api.getRequest('/system-config/tag-types/with-values?category=Bodywork');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List types = response.body['data'] ?? [];
        dynamic serviceType;
        for (final t in types) {
          if (t is Map && (t['name'] == 'Bodywork Services' || t['name'] == 'Services')) {
            serviceType = t;
            break;
          }
        }
        if (serviceType is Map) {
          final st = Map<String, dynamic>.from(serviceType);
          final values = st['values'];
          if (values is List && values.isNotEmpty) {
            final List<String> names = List<String>.from(values.map((v) => v is Map ? v['name'] : v));
            final deduped = _dedupeNamesInsensitive(names.map((e) => e.toString()));
            services.assignAll(deduped.map(_defaultRow).toList());
          } else {
            services.assignAll(_fallbackServiceNames.map(_defaultRow).toList());
          }
        } else {
          services.assignAll(_fallbackServiceNames.map(_defaultRow).toList());
        }
      } else {
        services.assignAll(_fallbackServiceNames.map(_defaultRow).toList());
      }
    } catch (e) {
      debugPrint('BodyworkServiceRatesTab: catalog fetch failed: $e');
      services.assignAll(_fallbackServiceNames.map(_defaultRow).toList());
    } finally {
      isLoadingServices.value = false;
    }
  }

  Map<String, dynamic> _mergeCatalogDisplayName(
    String catalogDisplayName,
    Map<String, dynamic>? saved,
  ) {
    if (saved == null) return _defaultRow(catalogDisplayName);
    final row = _rowFromSaved(saved);
    row['name'] = catalogDisplayName;
    return row;
  }

  void _hydrateFromVendorProfile() {
    final raw = controller.getProfileDataByType(widget.serviceType);
    final savedList = coerceDynamicList(raw['services']);

    final savedByCanon = <String, Map<String, dynamic>>{};
    for (final e in savedList) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final name = m['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      final k = _canonServiceKey(name);
      if (savedByCanon.containsKey(k)) {
        savedByCanon[k] = _mergeSavedServiceRows(savedByCanon[k]!, m);
      } else {
        savedByCanon[k] = m;
      }
    }

    if (services.isEmpty) {
      for (final m in savedByCanon.values) {
        services.add(_rowFromSaved(m));
      }
      services.refresh();
      return;
    }

    final merged = <Map<String, dynamic>>[];
    for (final row in services) {
      final catalogName = row['name']?.toString() ?? '';
      final k = _canonServiceKey(catalogName);
      final saved = savedByCanon.remove(k);
      merged.add(_mergeCatalogDisplayName(catalogName, saved));
    }
    for (final m in savedByCanon.values) {
      merged.add(_rowFromSaved(m));
    }
    services.assignAll(merged);
    services.refresh();
  }

  Future<void> _onSave() async {
    if (!services.any((s) => s['isSelected'] == true)) {
      Get.snackbar(
        'Missing Info',
        'Please select at least one service',
        backgroundColor: AppColors.accentRed,
        colorText: Colors.white,
      );
      return;
    }

    final payload = services
        .map((s) => Map<String, dynamic>.from({
              ...s,
              'rates': _sanitizeBodyworkRatesMap(s['rates']),
              'trainerPresence': _coerceBodyworkDropdownValue(
                s['trainerPresence']?.toString(),
                _trainerPresenceOptions,
              ),
              'vetApproval': _coerceBodyworkDropdownValue(
                s['vetApproval']?.toString(),
                _vetApprovalOptions,
              ),
            }))
        .toList();

    final success = await controller.updateBodyworkServiceRates(services: payload);
    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Bodywork rates saved successfully',
        backgroundColor: AppColors.successPrimary,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGroupedSection(
            'Bodywork Services',
            description: 'Select all services you are trained and qualified to provide',
            children: [
              Obx(() {
                if (isLoadingServices.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Column(
                  children: [
                    ...services.map((service) => _buildServiceItem(service)),
                    _buildAddServiceLink(),
                  ],
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
          const SizedBox(height: 32),
          _buildBottomButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAddServiceLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: _showAddCustomServiceSheet,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18, color: AppColors.linkBlue),
            const SizedBox(width: 8),
            CommonText(
              'Add service',
              color: AppColors.linkBlue,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomServiceSheet() {
    final nameController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                controller: nameController,
                hintText: 'e.g. Cupping, Kinesiology taping',
                label: 'Service name',
              ),
              const SizedBox(height: 24),
              CommonButton(
                text: 'Add',
                onPressed: () {
                  final raw = nameController.text.trim();
                  if (raw.isEmpty) {
                    Get.snackbar(
                      'Missing Info',
                      'Please enter a service name',
                      backgroundColor: AppColors.accentRed,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  final k = _canonServiceKey(raw);
                  final exists = services.any((s) => _canonServiceKey(s['name']?.toString()) == k);
                  if (exists) {
                    Get.snackbar(
                      'Duplicate',
                      'That service is already in your list',
                      backgroundColor: AppColors.accentRed,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  services.add(_defaultRow(raw));
                  services.refresh();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            text: 'Cancel',
            backgroundColor: Colors.white,
            textColor: AppColors.textPrimary,
            borderColor: AppColors.borderLight,
            onPressed: () => Get.back(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => CommonButton(
              text: 'Save',
              isLoading: controller.isLoading.value,
              onPressed: _onSave,
              backgroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedSection(String title, {String? description, List<Widget> children = const []}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          if (description != null) ...[
            const SizedBox(height: 4),
            CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final isSelected = service['isSelected'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    service['isSelected'] = !isSelected;
                    services.refresh();
                  },
                  child: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? AppColors.primary : AppColors.borderMedium,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500)),
                if (isSelected)
                  GestureDetector(
                    onTap: () => _showRatesBottomSheet(service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CommonText('Configure Rates', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.lightGray.withValues(alpha: 0.1),
              child: _buildRatesSummary(service['rates'] as Map<String, dynamic>? ?? {}),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatesSummary(Map<String, dynamic> rates) {
    final activeRates = rates.entries
        .where((e) => _sessionKeys.contains(e.key.toString()) && _meaningfulBodyworkRate(e.value))
        .toList();

    if (activeRates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CommonText(
          'No rates configured. Tap to configure.',
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(activeRates.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(width: 1, height: 24, color: AppColors.borderLight);
          }
          final e = activeRates[index ~/ 2];
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonText('\$ ${e.value}', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentRed),
                const SizedBox(height: 4),
                CommonText('${e.key} mins', fontSize: 12, color: AppColors.textSecondary),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showRatesBottomSheet(Map<String, dynamic> service) {
    final editingRates = Map<String, dynamic>.from(_sanitizeBodyworkRatesMap(service['rates']));
    final editingNote = TextEditingController(text: service['note']?.toString() ?? '');
    final trainerPresence = RxnString(
      _coerceBodyworkDropdownValue(
        service['trainerPresence']?.toString(),
        _trainerPresenceOptions,
      ),
    );
    final vetApproval = RxnString(
      _coerceBodyworkDropdownValue(
        service['vetApproval']?.toString(),
        _vetApprovalOptions,
      ),
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              CommonText(service['name']?.toString() ?? '', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),
              const CommonText('Session Length & Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              ..._sessionKeys.map((mins) {
                final hasValue = _meaningfulBodyworkRate(editingRates[mins]);
                final isChecked = hasValue.obs;
                final textController = TextEditingController(
                  text: hasValue ? editingRates[mins]?.toString() ?? '' : '',
                );

                return Column(
                  children: [
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isChecked.value ? AppColors.primary : Colors.transparent),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isChecked.value) {
                                      editingRates[mins] = '';
                                      textController.clear();
                                    }
                                    isChecked.value = !isChecked.value;
                                  },
                                  child: Icon(
                                    isChecked.value ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: isChecked.value ? AppColors.primary : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CommonText('$mins minutes', fontSize: 14, fontWeight: FontWeight.w500),
                              ],
                            ),
                            if (isChecked.value) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: textController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [PriceInputFormatter()],
                                        onChanged: (val) => editingRates[mins] = val,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter price',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              const CommonText('Note', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              CommonTextField(label: '', hintText: 'Write here...', controller: editingNote, maxLines: 3),
              const SizedBox(height: 16),
              const CommonText('Trainer Presence', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown(
                  value: trainerPresence.value,
                  hint: 'Select Trainer Preference',
                  options: _trainerPresenceOptions,
                  onChanged: (val) => trainerPresence.value = val,
                ),
              ),
              const SizedBox(height: 16),
              const CommonText('Vet approval', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown(
                  value: vetApproval.value,
                  hint: 'Select Vet Preference',
                  options: _vetApprovalOptions,
                  onChanged: (val) => vetApproval.value = val,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      onPressed: () {
                        service['rates'] = _sanitizeBodyworkRatesMap(editingRates);
                        service['note'] = editingNote.text;
                        service['trainerPresence'] = _coerceBodyworkDropdownValue(
                          trainerPresence.value,
                          _trainerPresenceOptions,
                        );
                        service['vetApproval'] = _coerceBodyworkDropdownValue(
                          vetApproval.value,
                          _vetApprovalOptions,
                        );
                        service['isSelected'] = true;
                        services.refresh();
                        Get.back();
                      },
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdown({
    String? value,
    required String hint,
    required List<String> options,
    required void Function(String) onChanged,
  }) {
    final safeValue = _coerceBodyworkDropdownValue(value, options);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          hint: CommonText(hint, color: AppColors.textSecondary, fontSize: 14),
          isExpanded: true,
          items: options.map((v) => DropdownMenuItem(value: v, child: CommonText(v))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
