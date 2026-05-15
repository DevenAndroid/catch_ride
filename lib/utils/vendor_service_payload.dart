// Normalizes [VendorModel]-root payloads from GET /vendors/me (and similar): `serviceType`,
// `servicesData`, `assignedServices` (each entry may carry nested profile/application maps).

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

/// Onboarding / profile selection: [VendorModel.serviceType] (preferred over denormalized `services`).
List<String> vendorSelectedServiceTypes(Map<String, dynamic> vendor) {
  final st = vendor['serviceType'];
  final out = <String>[];
  if (st is List) {
    for (final e in st) {
      final s = e?.toString().trim() ?? '';
      if (s.isNotEmpty) out.add(s);
    }
  } else if (st is String && st.trim().isNotEmpty) {
    out.add(st.trim());
  }
  return out;
}

String _canonicalServiceTypeKey(String? type) {
  if (type == null) return '';
  var k = type.toLowerCase().replaceAll(' ', '');
  if (k == 'transportation') k = 'shipping';
  return k;
}

/// When [selected] is non-empty, keep only types the vendor actually selected (root `serviceType`).
bool _serviceTypeMatchesVendorSelection(
  String? assignedType,
  List<String> selected,
) {
  if (selected.isEmpty) return true;
  final a = _canonicalServiceTypeKey(assignedType);
  if (a.isEmpty) return false;
  for (final s in selected) {
    if (_canonicalServiceTypeKey(s) == a) return true;
  }
  return false;
}

/// Collects service type strings from root vendor fields (VendorModel + GET /vendors/me).
///
/// Prefers [vendorSelectedServiceTypes] so tabs reflect onboarding selection, not the
/// denormalized `services` list on [VendorModel] (which may mirror every assigned-service entry).
List<String> serviceTypesFromVendorRoot(Map<String, dynamic> vendor) {
  final preferred = vendorSelectedServiceTypes(vendor);
  if (preferred.isNotEmpty) return preferred;

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

/// Returns a list of maps shaped like [VendorModel.assignedServices] entries for UI/controllers.
///
/// Tabs and details only include services the vendor selected ([VendorModel.serviceType]),
/// not every linked assigned-service entry or legacy `services` mirror on the vendor root.
List<Map<String, dynamic>> normalizeAssignedServices(Map<String, dynamic> vendor) {
  final raw = vendor['assignedServices'];
  final fromApi = <Map<String, dynamic>>[];

  if (raw is List) {
    for (final item in raw) {
      if (item is Map && item['serviceType'] != null) {
        fromApi.add(Map<String, dynamic>.from(item));
      }
    }
  }

  final selected = vendorSelectedServiceTypes(vendor);

  var parsed = fromApi;
  if (selected.isNotEmpty) {
    parsed = fromApi
        .where(
          (m) => _serviceTypeMatchesVendorSelection(
            m['serviceType']?.toString(),
            selected,
          ),
        )
        .toList();
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

/// Whether normalized assigned rows include **Shipping** ([VendorModel.serviceType] includes `Shipping`;
/// legacy `Transportation` counts via [_canonicalServiceTypeKey]). Uses [normalizeAssignedServices]
/// so Trips vs Availability matches profile tabs and [VendorModel.serviceType] selection.
bool vendorPayloadIncludesShipping(Map<String, dynamic> vendorRoot) {
  for (final m in normalizeAssignedServices(vendorRoot)) {
    if (_canonicalServiceTypeKey(m['serviceType']?.toString()) == 'shipping') {
      return true;
    }
  }
  return false;
}

/// Same as [vendorPayloadIncludesShipping] when only [UserModel.vendorServices]-style strings exist.
bool userVendorServicesIncludeShipping(List<String> vendorServices) {
  if (vendorServices.isEmpty) return false;
  return vendorPayloadIncludesShipping(<String, dynamic>{
    'serviceType': List<String>.from(vendorServices),
    'assignedServices': vendorServices
        .map((t) => <String, dynamic>{'serviceType': t})
        .toList(),
  });
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

/// Merged profile for one [serviceType]: **[VendorModel]** embedded subdoc (`grooming`, `braiding`, …),
/// then **VendorModel.assignedServices** → `profile.profileData`, then **VendorModel.servicesData**
/// (`profileData` from `servicesData` wins on key conflict for edited postform fields).
///
/// Single source for groom profile card, **Services & Rates**, and **Edit Profile** hydration.
Map<String, dynamic> mergedVendorServiceDisplayData(
  Map<String, dynamic> vendorRoot,
  String serviceType,
) {
  final vendor = Map<String, dynamic>.from(vendorRoot);
  final assigned = normalizeAssignedServices(vendor);

  dynamic serviceRow;
  for (final s in assigned) {
    if (assignedServiceMatchesTab(s, serviceType)) {
      serviceRow = s;
      break;
    }
  }

  final rawSd = vendor['servicesData'];
  final Map<String, dynamic> servicesData =
      rawSd is Map ? Map<String, dynamic>.from(rawSd) : <String, dynamic>{};

  final Map<String, dynamic> directServiceData =
      servicesDataBlockForType(servicesData, serviceType);

  final profileSource =
      serviceRow is Map ? serviceRow['profile'] : null;
  final Map<String, dynamic> profile = profileSource is Map
      ? Map<String, dynamic>.from(profileSource)
      : <String, dynamic>{};

  final pNested = profile['profileData'];
  final Map<String, dynamic> pProfileData = pNested is Map
      ? Map<String, dynamic>.from(pNested)
      : <String, dynamic>{};

  final dNestedProf = directServiceData['profileData'];
  final Map<String, dynamic> dProfileData = dNestedProf is Map
      ? Map<String, dynamic>.from(dNestedProf)
      : <String, dynamic>{};

  final vendorSubdoc = _vendorSubdoc(vendor, vendorPreformSubdocKey(serviceType));
  final Map<String, dynamic> vmBase = vendorSubdoc != null
      ? Map<String, dynamic>.from(vendorSubdoc)
      : <String, dynamic>{};
  _normalizeVendorModelSubdocForDisplay(serviceType, vmBase);

  final Map<String, dynamic> mergedProfileData = {
    ...vmBase,
    ...pProfileData,
    ...dProfileData,
  };

  final Map<String, dynamic> merged = {
    ...profile,
    ...directServiceData,
    ...mergedProfileData,
    'profileData': mergedProfileData,
  };

  void mergeList(String key) {
    final List<dynamic> list1 = mergedProfileData[key] is List
        ? List<dynamic>.from(mergedProfileData[key] as List)
        : <dynamic>[];
    final List<dynamic> list2 =
        merged[key] is List ? List<dynamic>.from(merged[key] as List) : <dynamic>[];

    if (list1.isNotEmpty || list2.isNotEmpty) {
      final uniqueMap = <String, dynamic>{};
      for (final item in [...list1, ...list2]) {
        String? name;
        if (item is Map) {
          name = (item['name'] ?? item['label'])?.toString().toLowerCase().trim();
        } else if (item is String && item.toString().isNotEmpty) {
          name = item.toString().toLowerCase().trim();
        }
        if (name != null && name.isNotEmpty) {
          uniqueMap[name] = item;
        }
      }
      final mergedList = uniqueMap.values.toList();
      merged[key] = mergedList;
      mergedProfileData[key] = mergedList;
    }
  }

  mergeList('services');
  mergeList('additionalServices');
  mergeList('addOns');

  // Per-service wizard fields (disciplines, homeBase, modalities, …) live on
  // `assignedServices[].application` and/or `servicesData.<type>.applicationData`.
  // Include them on [merged] so profile cards read one map without losing data when
  // the legacy vendor embed has stale partial lists.
  final Map<String, dynamic> appFromBlock =
      _applicationDataFromServicesDataBlock(directServiceData);
  final Map<String, dynamic> appFromRow = serviceRow is Map
      ? effectiveApplicationData(serviceRow)
      : <String, dynamic>{};
  final Map<String, dynamic> mergedApplicationData = {
    ...appFromBlock,
    ...appFromRow,
  };
  if (mergedApplicationData.isNotEmpty) {
    merged['applicationData'] = mergedApplicationData;
    merged['application'] = <String, dynamic>{
      'applicationData': mergedApplicationData,
    };
  }

  merged['profileData'] = mergedProfileData;
  return merged;
}

/// Mongo `_id` of one [VendorModel.assignedServices] map (per-service row), or null when missing / synthetic.
/// Used as `serviceId` in `/vendors/:vendorMongoId/services/:serviceId/profile|application` (backend `VendorModel` aggregate + linked service profile sync).
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

/// Maps [VendorModel] embedded keys (e.g. `groomingServices`, `braidlingServices`) into the
/// flattened shapes used by profile tabs (`services`, `capabilities`, `disciplines`).
void _normalizeVendorModelSubdocForDisplay(String serviceType, Map<String, dynamic> b) {
  if (b.isEmpty) return;
  final n = serviceType.toLowerCase().replaceAll(' ', '');
  if (b.containsKey('desciplines') && !b.containsKey('disciplines')) {
    b['disciplines'] = b['desciplines'];
  }
  if (n == 'grooming') {
    final gs = b['groomingServices'];
    if (gs is List &&
        gs.isNotEmpty &&
        (!(b['services'] is List) || (b['services'] as List).isEmpty)) {
      b['services'] = gs
          .map(
            (e) => <String, dynamic>{
              'name': e.toString(),
              'isSelected': true,
            },
          )
          .toList();
    }
    final support = b['showAndBarnSupport'];
    final handling = b['horseHandling'];
    final caps = _mapFrom(b['capabilities']) ?? <String, dynamic>{};
    var changed = false;
    if (support is List &&
        support.isNotEmpty &&
        (caps['support'] == null ||
            (caps['support'] is List && (caps['support'] as List).isEmpty))) {
      caps['support'] = List<String>.from(support.map((e) => e.toString()));
      changed = true;
    }
    if (handling is List &&
        handling.isNotEmpty &&
        (caps['handling'] == null ||
            (caps['handling'] is List && (caps['handling'] as List).isEmpty))) {
      caps['handling'] = List<String>.from(handling.map((e) => e.toString()));
      changed = true;
    }
    if (changed) b['capabilities'] = caps;
  }
  if (n == 'braiding' || n == 'clipping') {
    final raw = n == 'braiding'
        ? (b['braidlingServices'] ?? b['braidingServices'])
        : b['clippingServices'];
    if (raw is List &&
        raw.isNotEmpty &&
        (!(b['services'] is List) || (b['services'] as List).isEmpty)) {
      b['services'] = raw.map((e) {
        if (e is Map) {
          return <String, dynamic>{
            'name': e['label'] ?? e['name'] ?? '',
            'price': (e['ratePerHour'] ?? e['rate'] ?? e['price'] ?? '').toString(),
            'isSelected': true,
          };
        }
        return <String, dynamic>{
          'name': e.toString(),
          'price': '0',
          'isSelected': true,
        };
      }).toList();
    }
  }
  if (n == 'farrier') {
    List<Map<String, dynamic>> mapRateItems(List<dynamic> raw) {
      return raw.map((e) {
        if (e is Map) {
          return <String, dynamic>{
            'name': e['label'] ?? e['name'] ?? '',
            'price': (e['ratePerHour'] ?? e['rate'] ?? e['price'] ?? '')
                .toString(),
            'isSelected': true,
          };
        }
        return <String, dynamic>{
          'name': e.toString(),
          'price': '0',
          'isSelected': true,
        };
      }).toList();
    }

    final fs = b['farrierServices'];
    if (fs is List &&
        fs.isNotEmpty &&
        (!(b['services'] is List) || (b['services'] as List).isEmpty)) {
      b['services'] = mapRateItems(fs);
    }
    final addons = b['addOns'];
    if (addons is List &&
        addons.isNotEmpty &&
        addons.every((e) => e is Map && (e['label'] != null || e['ratePerHour'] != null))) {
      b['addOns'] = mapRateItems(addons);
    }
    final cis = b['clientIntakePlusScheduling'];
    if (cis is Map && b['clientIntake'] == null) {
      final m = Map<String, dynamic>.from(cis);
      String policy = '';
      if (m['notAcceptingNewClients'] == true) {
        policy = 'not accepting';
      } else if (m['referralOnly'] == true) {
        policy = 'referral';
      } else if (m['limitedAvailability'] == true) {
        policy = 'limited';
      } else if (m['acceptingNewClients'] == true) {
        policy = 'accepting';
      }
      b['clientIntake'] = {
        'policy': policy,
        'minHorses': m['minHorsesPerStop'] ?? m['minHorses'],
        'emergencySupport': m['emergencySupport'],
      };
    }
    if (b['relevantCertifications'] is List &&
        (!(b['certifications'] is List) ||
            (b['certifications'] as List).isEmpty)) {
      b['certifications'] = List<String>.from(b['relevantCertifications'] as List);
    }
  }
  if (n == 'bodywork') {
    final bw = b['bodyworkServices'];
    if (bw is List &&
        bw.isNotEmpty &&
        (!(b['services'] is List) || (b['services'] as List).isEmpty)) {
      b['services'] = bw.map((e) {
        if (e is Map) {
          final ratesMap = <String, dynamic>{};
          final session = e['session'];
          if (session is List) {
            for (final s in session) {
              if (s is Map && s['min'] != null && s['price'] != null) {
                ratesMap[s['min'].toString()] = s['price'];
              }
            }
          }
          return <String, dynamic>{
            'name': e['label'] ?? e['name'] ?? '',
            'rates': ratesMap,
            'session': session, // Keep for fallback
            'isSelected': true,
          };
        }
        return e;
      }).toList();
    }
  }
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

/// Reduces signed URLs / full paths to storage keys (`uploads/...`) for PUT payloads.
String portfolioMediaStorageKeyForSave(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('data:')) return trimmed;

  var path = trimmed.replaceAll('\\', '/');
  if (path.startsWith('//')) path = 'https:$path';

  final uploadsIdx = path.indexOf('uploads/');
  if (uploadsIdx >= 0) {
    return path.substring(uploadsIdx).split('?').first;
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    try {
      final uri = Uri.parse(path);
      final segment = uri.pathSegments
          .skipWhile((s) => s != 'uploads')
          .join('/');
      if (segment.startsWith('uploads/')) return segment;
    } catch (_) {}
  }

  return path.split('?').first;
}

/// Existing + new portfolio entries as storage keys for [VendorModel] `media` arrays.
List<String> portfolioMediaStorageKeysForSave(Iterable<String> values) {
  final seen = <String>{};
  final out = <String>[];
  for (final value in values) {
    final key = portfolioMediaStorageKeyForSave(value);
    if (key.isEmpty) continue;
    if (seen.add(key)) out.add(key);
  }
  return out;
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

/// [VendorModel.js] `profile` — falls back to legacy `profilePhoto` from older API payloads.
String vendorProfileImageFromRoot(Map<dynamic, dynamic> data) {
  final profile = data['profile']?.toString();
  if (profile != null && profile.isNotEmpty) return profile;
  return data['profilePhoto']?.toString() ?? '';
}

/// [VendorModel.js] `bannerImage` — falls back to legacy `coverImage` from older API payloads.
String vendorBannerImageFromRoot(Map<dynamic, dynamic> data) {
  final banner = data['bannerImage']?.toString();
  if (banner != null && banner.isNotEmpty) return banner;
  return data['coverImage']?.toString() ?? '';
}
