// Maps VendorService-shaped API payloads (serviceType, profile/application subdocs)
// and lean vendor roots (services + servicesData) into a consistent structure for controllers.

Map<String, dynamic> _asStringKeyedMap(dynamic value) {
  if (value is! Map) return <String, dynamic>{};
  return Map<String, dynamic>.from(value);
}

/// Picks a `servicesData` block for a service type, including common aliases.
Map<String, dynamic> servicesDataBlockForType(
  Map<String, dynamic> servicesData,
  String serviceType,
) {
  final norm = serviceType.toLowerCase().replaceAll(' ', '');
  final candidates = <String>{
    norm,
    serviceType.toLowerCase(),
    serviceType,
  };
  if (norm == 'shipping' || norm == 'transportation') {
    candidates.addAll({'shipping', 'transportation'});
  }
  if (norm == 'bodywork') {
    candidates.addAll({'bodywork', 'body work'});
  }
  for (final key in candidates) {
    final v = servicesData[key];
    if (v is Map) return Map<String, dynamic>.from(v);
  }
  return <String, dynamic>{};
}

Map<String, dynamic> effectiveApplicationData(dynamic assignedService) {
  if (assignedService is! Map) return <String, dynamic>{};
  final svc = Map<String, dynamic>.from(assignedService);
  // Flat ApplicationData on synthetic rows
  final top = svc['applicationData'];
  if (top is Map) return Map<String, dynamic>.from(top);
  final app = svc['application'];
  if (app is Map) {
    final nested = app['applicationData'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    final copy = Map<String, dynamic>.from(app);
    copy.remove('_id');
    copy.remove('vendorServiceId');
    copy.remove('createdAt');
    copy.remove('updatedAt');
    copy.remove('__v');
    copy.remove('status');
    copy.remove('isSubmitted');
    copy.remove('submittedAt');
    copy.remove('adminNotes');
    return copy;
  }
  return <String, dynamic>{};
}

Map<String, dynamic> effectiveProfileData(dynamic assignedService) {
  if (assignedService is! Map) return <String, dynamic>{};
  final svc = Map<String, dynamic>.from(assignedService);
  final top = svc['profileData'];
  if (top is Map) return Map<String, dynamic>.from(top);
  final prof = svc['profile'];
  if (prof is Map) {
    final nested = prof['profileData'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    final skip = {
      '_id',
      'vendorServiceId',
      'createdAt',
      'updatedAt',
      '__v',
      'isPublished',
      'isCompleted',
      'views',
    };
    final copy = Map<String, dynamic>.from(prof);
    copy.removeWhere((k, _) => skip.contains(k));
    return copy;
  }
  return <String, dynamic>{};
}

/// Collects service type strings from root vendor fields (VendorModel + GET /vendors/me).
List<String> serviceTypesFromVendorRoot(Map<String, dynamic> vendor) {
  final out = <String>[];

  void addFrom(dynamic source) {
    if (source == null) return;
    if (source is List) {
      for (final e in source) {
        final s = e?.toString().trim();
        if (s != null && s.isNotEmpty) out.add(s);
      }
    } else if (source is String && source.trim().isNotEmpty) {
      out.add(source.trim());
    }
  }

  addFrom(vendor['services']);
  if (out.isEmpty) addFrom(vendor['serviceType']);

  return out.toSet().toList();
}

/// Returns a list of maps shaped like populated VendorService rows for UI/controllers.
List<Map<String, dynamic>> normalizeAssignedServices(Map<String, dynamic> vendor) {
  final raw = vendor['assignedServices'];
  final parsed = <Map<String, dynamic>>[];

  if (raw is List) {
    for (final item in raw) {
      if (item is Map && item['serviceType'] != null) {
        parsed.add(Map<String, dynamic>.from(item));
      }
    }
  }

  if (parsed.isNotEmpty) return parsed;

  final servicesData = _asStringKeyedMap(vendor['servicesData']);
  final types = serviceTypesFromVendorRoot(vendor);

  for (final t in types) {
    final block = servicesDataBlockForType(servicesData, t);
    final profileData = _profileDataFromServicesDataBlock(block);
    final applicationData = _applicationDataFromServicesDataBlock(block);
    parsed.add({
      'serviceType': t,
      'status': vendor['status'] ?? 'active',
      'isApproved': vendor['isProfileApprove'] ?? true,
      'profile': {'profileData': profileData},
      'application': {'applicationData': applicationData},
    });
  }

  return parsed;
}

Map<String, dynamic> _profileDataFromServicesDataBlock(Map<String, dynamic> block) {
  final pd = block['profileData'];
  if (pd is Map) return Map<String, dynamic>.from(pd);
  final copy = Map<String, dynamic>.from(block);
  copy.remove('applicationData');
  return copy;
}

Map<String, dynamic> _applicationDataFromServicesDataBlock(Map<String, dynamic> block) {
  final ad = block['applicationData'];
  if (ad is Map) return Map<String, dynamic>.from(ad);
  return <String, dynamic>{};
}

bool assignedServiceMatchesTab(
  dynamic assignedEntry,
  String selectedServiceType,
) {
  if (assignedEntry is! Map) return false;
  final st = assignedEntry['serviceType']?.toString() ?? '';
  if (st.isEmpty) return false;
  final a = st.toLowerCase().replaceAll(' ', '');
  final b = selectedServiceType.toLowerCase().replaceAll(' ', '');
  return a == b;
}
