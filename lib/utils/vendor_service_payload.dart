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

/// Mongo `_id` of the [VendorService] row (assigned service entry), or null when missing / synthetic fallback rows.
/// Backend: `VendorServiceModel` — must match `/vendors/:vendorId/services/:serviceId/profile|application`.
String? vendorServiceDocumentId(dynamic assignedServiceRow) {
  if (assignedServiceRow is! Map) return null;
  final m = Map<String, dynamic>.from(assignedServiceRow);
  final dynamic id = m['_id'] ?? m['id'];
  if (id == null) return null;
  if (id is Map && id[r'$oid'] != null) return id[r'$oid'].toString();
  final s = id.toString().trim();
  return s.isEmpty ? null : s;
}

/// Vendor Mongo id from GET `/vendors/me` payload (`_id` or `id`).
String? vendorMongoIdFromRoot(Map<String, dynamic> vendor) {
  final dynamic id = vendor['_id'] ?? vendor['id'];
  if (id == null) return null;
  if (id is Map && id[r'$oid'] != null) return id[r'$oid'].toString();
  final s = id.toString().trim();
  return s.isEmpty ? null : s;
}

/// [VendorModel] preform subdocument key for a [serviceType] label (e.g. `Grooming` → `grooming`).
String vendorPreformSubdocKey(String serviceType) {
  final n = serviceType.toLowerCase().replaceAll(' ', '');
  switch (n) {
    case 'grooming':
      return 'grooming';
    case 'braiding':
      return 'braiding';
    case 'clipping':
      return 'clipping';
    case 'farrier':
      return 'farrier';
    case 'bodywork':
      return 'bodywork';
    case 'shipping':
    case 'transportation':
      return 'shipping';
    default:
      return serviceType.toLowerCase();
  }
}

Map<String, dynamic>? _mapFrom(dynamic v) {
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

Map<String, dynamic>? _vendorSubdoc(Map<String, dynamic> vendorRoot, String subKey) {
  final direct = _mapFrom(vendorRoot[subKey]);
  if (direct != null) return direct;
  final vm = _mapFrom(vendorRoot['vendorModel']);
  if (vm == null) return null;
  return _mapFrom(vm[subKey]);
}

String _firstNonEmptyStr(List<dynamic> candidates) {
  for (final c in candidates) {
    final t = c == null ? '' : c.toString().trim();
    if (t.isNotEmpty) return t;
  }
  return '';
}

String? _socialNested(Map<String, dynamic>? m, String field) {
  if (m == null) return null;
  final sm = m['socialMedia'];
  if (sm is Map && sm[field] != null) {
    final s = sm[field].toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

/// Instagram URL/handle for edit profile: ServiceProfile, application, legacy `*Link`, [VendorModel] subdoc.
String resolveServiceInstagram({
  required String serviceType,
  required Map<String, dynamic> vendorRoot,
  required Map<String, dynamic> profileData,
  required Map<String, dynamic> appData,
  Map<String, dynamic>? draftBlock,
}) {
  final sub = _vendorSubdoc(vendorRoot, vendorPreformSubdocKey(serviceType));
  final draftPd = draftBlock != null ? _mapFrom(draftBlock['profileData']) : null;
  final draftAd = draftBlock != null ? _mapFrom(draftBlock['applicationData']) : null;

  return _firstNonEmptyStr([
    _socialNested(profileData, 'instagram'),
    _socialNested(appData, 'instagram'),
    _socialNested(draftPd, 'instagram'),
    _socialNested(draftAd, 'instagram'),
    appData['instagramLink'],
    profileData['instagramLink'],
    sub?['instagramLink'],
    vendorRoot['instagram'],
  ]);
}

/// Facebook URL for edit profile (same sources as [resolveServiceInstagram]).
String resolveServiceFacebook({
  required String serviceType,
  required Map<String, dynamic> vendorRoot,
  required Map<String, dynamic> profileData,
  required Map<String, dynamic> appData,
  Map<String, dynamic>? draftBlock,
}) {
  final sub = _vendorSubdoc(vendorRoot, vendorPreformSubdocKey(serviceType));
  final draftPd = draftBlock != null ? _mapFrom(draftBlock['profileData']) : null;
  final draftAd = draftBlock != null ? _mapFrom(draftBlock['applicationData']) : null;

  return _firstNonEmptyStr([
    _socialNested(profileData, 'facebook'),
    _socialNested(appData, 'facebook'),
    _socialNested(draftPd, 'facebook'),
    _socialNested(draftAd, 'facebook'),
    appData['facebookLink'],
    profileData['facebookLink'],
    sub?['facebookLink'],
    vendorRoot['facebook'],
  ]);
}

/// Portfolio image keys/URLs from API (strings or `{ url, filename, key, ... }`).
List<String> normalizeProfileMediaUrls(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    final out = <String>[];
    for (final e in raw) {
      if (e == null) continue;
      if (e is String) {
        final t = e.trim();
        if (t.isNotEmpty) out.add(t);
      } else if (e is Map) {
        for (final k in ['url', 'src', 'filename', 'key', 'path']) {
          final v = e[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            out.add(v.toString().trim());
            break;
          }
        }
      }
    }
    return out;
  }
  if (raw is Map) {
    final nested = raw['photos'] ?? raw['images'] ?? raw['urls'] ?? raw['gallery'];
    if (nested != null) return normalizeProfileMediaUrls(nested);
  }
  return [];
}

/// Merges profile, application (list only), draft, and [VendorModel] subdoc `media` for one service.
List<String> mergeServicePortfolioMediaUrls({
  required String serviceType,
  required Map<String, dynamic> vendorRoot,
  required Map<String, dynamic> profileData,
  required Map<String, dynamic> appData,
  Map<String, dynamic>? draftBlock,
}) {
  final sub = _vendorSubdoc(vendorRoot, vendorPreformSubdocKey(serviceType));
  final draftPd = draftBlock != null ? _mapFrom(draftBlock['profileData']) : null;
  final draftAd = draftBlock != null ? _mapFrom(draftBlock['applicationData']) : null;

  final appMedia = appData['media'];
  final draftAppMedia = draftAd?['media'];

  final merged = <String>[
    ...normalizeProfileMediaUrls(profileData['media']),
    ...normalizeProfileMediaUrls(draftPd?['media']),
    if (appMedia is List) ...normalizeProfileMediaUrls(appMedia),
    if (draftAppMedia is List) ...normalizeProfileMediaUrls(draftAppMedia),
    ...normalizeProfileMediaUrls(sub?['media']),
  ];

  final seen = <String>{};
  final out = <String>[];
  for (final u in merged) {
    final t = u.trim();
    if (t.isEmpty) continue;
    if (seen.add(t)) out.add(t);
  }
  return out;
}
