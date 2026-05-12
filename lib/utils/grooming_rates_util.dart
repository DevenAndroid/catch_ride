/// Vendor API may store grooming [rates] as a list of `{ label, rate, daysofweek }`
/// (see VendorModel `grooming.rates`) or as a legacy map `{ daily, weekly, monthly }`.
Map<String, dynamic> normalizeGroomingRatesMap(dynamic raw) {
  if (raw == null) return {};
  if (raw is Map) {
    return Map<String, dynamic>.from(raw as Map);
  }
  if (raw is! List) return {};

  final out = <String, dynamic>{};
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item as Map);
    final label = (m['label'] ?? '').toString().toLowerCase();
    final rate = (m['rate'] ?? '').toString().trim();
    if (rate.isEmpty) continue;
    final daysRaw = m['daysofweek'] ?? m['days'] ?? 5;
    final days = daysRaw is num
        ? daysRaw.toInt()
        : int.tryParse(daysRaw.toString()) ?? 5;

    if (label.contains('daily')) {
      out['daily'] = rate;
    } else if (label.contains('weekly')) {
      out['weekly'] = <String, dynamic>{'price': rate, 'days': days.toString()};
    } else if (label.contains('monthly')) {
      out['monthly'] = <String, dynamic>{'price': rate, 'days': days.toString()};
    }
  }
  return out;
}

List<dynamic> coerceDynamicList(dynamic v) {
  if (v == null) return [];
  if (v is List<dynamic>) return v;
  if (v is List) return List<dynamic>.from(v);
  return [];
}
