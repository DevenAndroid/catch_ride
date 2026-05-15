/// Canonical travel-preference rows for VendorModel (`grooming` / `braiding` / … `travelPreferences[]`):
/// `{ label, note, fees, flatFee, perMile, variesByLocation }`.
/// Use this helper so PUT /vendors/me matches the backend schema.
class VendorTravelPreferencePayload {
  VendorTravelPreferencePayload._();

  static const Set<String> _feeTypeTokens = {
    'No travel fee',
    'Flat fee',
    'Per-mile',
    'Varies by location',
    'Travel fee',
    'none',
    'flat',
  };

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    return double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
  }

  static String _moneyStr(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toString();
  }

  /// Zone label for Farrier / Bodywork / canonical VendorModel rows (not fee-type strings).
  static String labelFromRow(dynamic row) {
    if (row is String) return row.trim();
    if (row is! Map) return '';
    final m = Map<String, dynamic>.from(row);

    final lab = m['label']?.toString().trim();
    if (lab != null && lab.isNotEmpty) return lab;

    final cat = m['category']?.toString().trim();
    if (cat != null && cat.isNotEmpty) return cat;

    final region = m['region']?.toString().trim();
    if (region != null && region.isNotEmpty) return region;

    final typeStr = m['type']?.toString().trim() ?? '';
    if (typeStr.isNotEmpty &&
        !_feeTypeTokens.contains(typeStr) &&
        !_feeTypeTokens.contains(typeStr.toLowerCase())) {
      return typeStr;
    }

    return m['name']?.toString().trim() ?? '';
  }

  /// UI dropdown + fields used by Farrier / Bodywork edit flows.
  static Map<String, String> toUiEditingState(dynamic row) {
    if (row is! Map) {
      return {'feeType': 'No travel fee', 'price': '', 'disclaimer': ''};
    }
    final m = Map<String, dynamic>.from(row);

    // Clipping legacy: region + feeStructure
    if (m['region'] != null && m['feeStructure'] is Map) {
      final fs = Map<String, dynamic>.from(m['feeStructure'] as Map);
      return {
        'feeType': fs['type']?.toString() ?? 'No travel fee',
        'price': fs['price']?.toString() ?? '',
        'disclaimer':
            fs['notes']?.toString() ?? fs['note']?.toString() ?? '',
      };
    }

    final hasCanonical = m.containsKey('fees') ||
        m.containsKey('flatFee') ||
        m.containsKey('perMile') ||
        m.containsKey('variesByLocation');

    if (hasCanonical) {
      final varies = m['variesByLocation'] == true;
      final note = m['note']?.toString() ?? '';
      if (varies) {
        return {
          'feeType': 'Varies by location',
          'price': '',
          'disclaimer': note,
        };
      }
      final per = _parseDouble(m['perMile']);
      final flat = _parseDouble(m['flatFee']);
      if (per > 0) {
        return {
          'feeType': 'Per-mile',
          'price': _moneyStr(per),
          'disclaimer': note,
        };
      }
      if (flat > 0) {
        return {
          'feeType': 'Flat fee',
          'price': _moneyStr(flat),
          'disclaimer': note,
        };
      }
      if (m['fees'] == true) {
        return {
          'feeType': 'Flat fee',
          'price': '',
          'disclaimer': note,
        };
      }
      return {
        'feeType': 'No travel fee',
        'price': '',
        'disclaimer': note,
      };
    }

    var feeType = m['feeType']?.toString() ?? 'No travel fee';
    if (feeType == 'Travel fee' || feeType == 'flat') feeType = 'Flat fee';
    if (feeType.toLowerCase() == 'none') feeType = 'No travel fee';

    return {
      'feeType': feeType,
      'price': m['price']?.toString() ?? '',
      'disclaimer': m['disclaimer']?.toString() ?? '',
    };
  }

  /// One VendorModel.travelPreferences[] element from Farrier / Bodywork UI state.
  static Map<String, dynamic> fromUiZone({
    required String label,
    required String feeType,
    String price = '',
    String disclaimer = '',
  }) {
    var norm = feeType.trim();
    if (norm == 'Travel fee') norm = 'Flat fee';
    if (norm.toLowerCase() == 'none') norm = 'No travel fee';

    final lower = norm.toLowerCase();
    final p = _parseDouble(price);
    final variesByLocation = lower == 'varies by location';
    final fees = lower == 'flat fee' || lower == 'per-mile';
    final flatFee = lower == 'flat fee' ? p : 0.0;
    final perMile = lower == 'per-mile' ? p : 0.0;

    return {
      'label': label.trim(),
      'note': disclaimer.trim(),
      'fees': fees,
      'flatFee': flatFee,
      'perMile': perMile,
      'variesByLocation': variesByLocation,
    };
  }

  static Map<String, dynamic> labelOnly(String label) =>
      fromUiZone(label: label, feeType: 'No travel fee');

  /// Grooming / Braiding / edit-profile clipping (label-only checklist).
  static List<String> groomBraidLabelsFromApiList(List<dynamic> raw) {
    return raw
        .map((e) {
          if (e is String) return e.trim();
          if (e is Map) return labelFromRow(e);
          return '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<Map<String, dynamic>> groomBraidTravelToApi(List<String> labels) =>
      labels.map(labelOnly).toList();

  /// Clipping UI stores `travelFees[region]` → feeStructure `{ type, price, notes }`.
  static Map<String, dynamic> fromClippingRegionEntry(
    String regionLabel,
    Map<String, dynamic> feeStructure,
  ) {
    final type = feeStructure['type']?.toString() ?? 'No travel fee';
    final price = feeStructure['price']?.toString() ?? '';
    final notes = feeStructure['notes']?.toString() ??
        feeStructure['note']?.toString() ??
        '';
    return fromUiZone(
      label: regionLabel,
      feeType: type,
      price: price,
      disclaimer: notes,
    );
  }

  /// Hydrate clipping `travelFees` map from API row (canonical or legacy).
  static Map<String, dynamic> clippingFeeStructureFromRow(
    Map<String, dynamic> row,
  ) {
    final ui = toUiEditingState(row);
    return {
      'type': ui['feeType'],
      'price': ui['price'],
      'notes': ui['disclaimer'],
    };
  }

  /// One readable line for profile / details views (canonical or legacy row).
  static String summaryForListItem(dynamic row) {
    if (row is String) return row.trim();
    if (row is! Map) return '';
    final m = Map<String, dynamic>.from(row);
    final label = labelFromRow(m);
    if (label.isEmpty) return '';
    final ui = toUiEditingState(m);
    final ft = ui['feeType'] ?? 'No travel fee';
    final price = ui['price'] ?? '';
    final disc = ui['disclaimer'] ?? '';
    if (ft == 'Varies by location') {
      return disc.isNotEmpty
          ? '$label: Varies by location — $disc'
          : '$label: Varies by location';
    }
    if (ft == 'Per-mile' && price.isNotEmpty) {
      return disc.isNotEmpty
          ? '$label: Per-mile \$$price — $disc'
          : '$label: Per-mile \$$price';
    }
    if (ft == 'Flat fee' && price.isNotEmpty) {
      return disc.isNotEmpty
          ? '$label: Flat fee \$$price — $disc'
          : '$label: Flat fee \$$price';
    }
    if (disc.isNotEmpty) return '$label — $disc';
    if (ft != 'No travel fee') return '$label: $ft';
    return label;
  }
}
