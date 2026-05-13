import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/vendor_service_payload.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';

class SendBookingRequestController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxMap vendorData = {}.obs;
  final RxString selectedService = ''.obs;
  final RxList availabilityList = [].obs;
  final RxBool isLoadingAvailability = false.obs;
  final RxBool isSending = false.obs;

  // Form fields
  final RxnString selectedRateType = RxnString();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxnString selectedNumHorses = RxnString();
  final RxnString selectedLocation = RxnString();
  final RxnString selectedOrigin = RxnString();
  final RxnString selectedDestination = RxnString();
  final RxList<String> intermediateStops = <String>[].obs;
  final notesController = TextEditingController();
  final originController = TextEditingController();
  final destinationController = TextEditingController();

  final RxList<Map<String, dynamic>> additionalServicesList =
      <Map<String, dynamic>>[].obs;
  final RxList<String> selectedAdditionalIds = <String>[].obs;

  final RxList<Map<String, dynamic>> coreServicesList =
      <Map<String, dynamic>>[].obs;
  final RxList<String> selectedCoreServiceIds = <String>[].obs;

  final RxBool isSummaryVisible = false.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxDouble basePrice = 0.0.obs;
  final RxDouble additionalTotal = 0.0.obs;
  final RxList<Map<String, dynamic>> bookedServices =
      <Map<String, dynamic>>[].obs;

  /// Hydrated merge of [VendorModel] subdoc + `assignedServices.profile` + `servicesData` (vendor details parity).
  Map<String, dynamic> mergedProfileForSelectedType = {};

  double _parsePrice(dynamic v) {
    if (v == null) return 0.0;
    String s = v.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 0.0;
  }

  /// VendorModel `grooming.rates` is `[{ label, rate, daysofweek }]`; legacy profile used a single object.
  Map<String, dynamic> _groomRatesAsLegacyMap(Map<String, dynamic> pd) {
    final r = pd['rates'];
    if (r is Map) return Map<String, dynamic>.from(r);
    if (r is List) {
      final out = <String, dynamic>{};
      for (final row in r) {
        if (row is! Map) continue;
        final label = row['label']?.toString().toLowerCase() ?? '';
        final rateStr = row['rate'];
        final dow = row['daysofweek'];
        if (label.contains('daily') || label == 'day') {
          out['daily'] = rateStr;
        } else if (label.contains('week')) {
          out['weekly'] = {
            'price': rateStr,
            'days': dow is num ? dow.toInt() : int.tryParse('$dow') ?? 6,
          };
        } else if (label.contains('month')) {
          out['monthly'] = {
            'price': rateStr,
            'days': dow is num ? dow.toInt() : int.tryParse('$dow') ?? 30,
          };
        }
      }
      return out;
    }
    return {};
  }

  List<Map<String, dynamic>> _labelRateItemsToCore(
    List? raw,
    String idPrefix,
  ) {
    if (raw == null) return [];
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < raw.length; i++) {
      final e = raw[i];
      if (e is! Map) continue;
      final label = e['label'] ?? e['name'];
      final name = label?.toString().trim() ?? '';
      if (name.isEmpty) continue;
      out.add({
        'id': '$idPrefix$i',
        'name': name,
        'price':
            _parsePrice(e['ratePerHour'] ?? e['rate'] ?? e['price']),
        'rates': <String, dynamic>{},
      });
    }
    return out;
  }

  List<Map<String, dynamic>> _mapSelectableCoreRows({
    required Map<String, dynamic> pd,
    required Map<String, dynamic> flatShippingBlock,
    required Map<String, dynamic> appData,
  }) {
    final svc = selectedService.value;
    final List coreRaw = pd['services'] is List ? List.from(pd['services']!) : [];
    final List<Map<String, dynamic>> mapped = [];

    for (var i = 0; i < coreRaw.length; i++) {
      final row = coreRaw[i];
      if (row is! Map) continue;
      final s = Map<String, dynamic>.from(row);
      final name =
          (s['name'] ?? s['label'])?.toString().trim() ?? '';
      if (name.isEmpty) continue;

      if (s['session'] is List) {
        final Map<String, dynamic> rates = {};
        for (final sess in s['session'] as List) {
          if (sess is! Map) continue;
          final min = sess['min'];
          final price = sess['price'];
          if (min != null && price != null) {
            rates['$min'] = price;
          }
        }
        final activeRates = rates.entries
            .where((e) => e.value != null && e.value.toString().isNotEmpty)
            .toList();
        final rawId = (s['id'] ?? '').toString().trim();
        final rowId =
            (rawId.isNotEmpty && !rawId.contains('_')) ? rawId : 'bw$i';
        mapped.add({
          'id': rowId,
          'name': name,
          'price': activeRates.length == 1
              ? _parsePrice(activeRates.first.value)
              : _parsePrice(s['price']),
          'rates': rates,
          if (activeRates.length == 1) 'session': activeRates.first.key,
        });
        continue;
      }

      final Map rates = {};
      final rawRates = s['rates'];
      if (rawRates is Map) {
        rates.addAll(Map<String, dynamic>.from(rawRates));
      }

      final activeRates = rates.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .toList();

      final rawId = (s['id'] ?? name).toString().trim();
      final rowId =
          (rawId.isNotEmpty && !rawId.contains('_')) ? rawId : 'r$i';
      mapped.add({
        'id': rowId,
        'name': name,
        'price': activeRates.length == 1
            ? _parsePrice(activeRates.first.value)
            : _parsePrice(
                s['price'] ?? s['ratePerHour'] ?? s['rate'],
              ),
        'rates': rates,
        if (activeRates.length == 1) 'session': activeRates.first.key,
      });
    }

    bool isShip() =>
        svc.toLowerCase().contains('ship') ||
        svc.toLowerCase().contains('transport');
    bool braid() => svc.toLowerCase().contains('braid');
    bool clip() => svc.toLowerCase().contains('clip');
    bool far() => svc.toLowerCase().contains('farrier');

    if (mapped.isEmpty && braid()) {
      final br =
          pd['braidlingServices'] ?? pd['braidingServices'];
      mapped.addAll(_labelRateItemsToCore(br is List ? br : null, 'braid'));
    }
    if (mapped.isEmpty && clip()) {
      mapped.addAll(
        _labelRateItemsToCore(
          pd['clippingServices'] is List ? pd['clippingServices'] as List : null,
          'clip',
        ),
      );
      mapped.addAll(
        _labelRateItemsToCore(
          pd['addOns'] is List ? pd['addOns'] as List : null,
          'clipaddon',
        ),
      );
    }
    if (mapped.isEmpty && far()) {
      mapped.addAll(
        _labelRateItemsToCore(
          pd['farrierServices'] is List ? pd['farrierServices'] as List : null,
          'farrier',
        ),
      );
      mapped.addAll(
        _labelRateItemsToCore(
          pd['addOns'] is List ? pd['addOns'] as List : null,
          'farrieraddon',
        ),
      );
    }

    // Shipping — [VendorModel.shipping.pricing] uses basePrice / fullyLoadedRate (+ legacy aliases).
    if (isShip() && mapped.isEmpty) {
      final pricing = _asMap(pd['pricing']) ??
          _asMap(flatShippingBlock['pricing']) ??
          _asMap(appData['pricing']);
      final ratesFallback = _asMap(pd['rates']) ??
          _asMap(flatShippingBlock['rates']) ??
          _asMap(appData['rates']);

      final baseCandidates = [
        pricing?['basePrice'],
        pricing?['baseRate'],
        ratesFallback?['baseRate'],
        ratesFallback?['base'],
        pricing?['base'],
        flatShippingBlock['baseRate'],
        appData['baseRate'],
      ];
      final loadedCandidates = [
        pricing?['fullyLoadedRate'],
        pricing?['loadedRate'],
        ratesFallback?['loadedRate'],
        ratesFallback?['loaded'],
        pricing?['loaded'],
        flatShippingBlock['loadedRate'],
        appData['loadedRate'],
      ];

      dynamic pickFirstNonEmpty(List<dynamic> cands) {
        for (final v in cands) {
          if (v == null) continue;
          final t = v.toString().trim().toLowerCase();
          if (t.isEmpty || t == 'n/a' || t == '0') continue;
          return v;
        }
        return null;
      }

      final basePrice = pickFirstNonEmpty(baseCandidates);
      final loadedPrice = pickFirstNonEmpty(loadedCandidates);

      if (basePrice != null) {
        mapped.add({
          'id': 'shippingBase',
          'name': 'Base Rate',
          'price': _parsePrice(basePrice),
          'rates': <String, dynamic>{},
        });
      }
      if (loadedPrice != null) {
        mapped.add({
          'id': 'shippingLoaded',
          'name': 'Fully Loaded Rate',
          'price': _parsePrice(loadedPrice),
          'rates': <String, dynamic>{},
        });
      }
    }

    return mapped;
  }

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<String> _migrateLegacyCoreIds(List<String> ids) {
    return ids.map((id) {
      switch (id) {
        case 'base_rate':
          return 'shippingBase';
        case 'loaded_rate':
          return 'shippingLoaded';
        default:
          return id;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _mapAdditionalServicesFromProfile(
    Map<String, dynamic> pd,
  ) {
    final List additional =
        pd['additionalServices'] is List ? List.from(pd['additionalServices']!) : [];
    final out = <Map<String, dynamic>>[];
    for (final item in additional) {
      if (item is! Map) continue;
      final s = Map<String, dynamic>.from(item);
      final name =
          (s['name'] ?? s['label'])?.toString().trim() ?? '';
      if (name.isEmpty) continue;
      final id = (s['id'] ?? name).toString();
      out.add({
        'id': id,
        'name': name,
        'price':
            _parsePrice(s['price'] ?? s['ratePerHour'] ?? s['rate']),
      });
    }
    return out;
  }

  void loadCatalogForSelectedServiceType() {
    final svcLabel = selectedService.value.trim();
    if (svcLabel.isEmpty) {
      mergedProfileForSelectedType = {};
      additionalServicesList.clear();
      coreServicesList.clear();
      return;
    }

    final vendorMap = Map<String, dynamic>.from(vendorData);
    final merged = mergedVendorServiceDisplayData(vendorMap, svcLabel);
    final rawPd = merged['profileData'];

    final Map<String, dynamic> pd =
        rawPd is Map<String, dynamic>
            ? Map<String, dynamic>.from(rawPd)
            : <String, dynamic>{};

    mergedProfileForSelectedType = pd;

    final rawSd = vendorData['servicesData'];
    final servicesData =
        rawSd is Map ? Map<String, dynamic>.from(rawSd) : <String, dynamic>{};
    final flatData =
        servicesData['shipping'] ?? servicesData['transportation'] ?? {};

    final List servicesList = vendorData['assignedServices'] ?? [];
    final activeService = servicesList.firstWhereOrNull(
      (s) => s['serviceType']?.toString() == selectedService.value,
    );
    final appData = effectiveApplicationData(activeService);

    additionalServicesList.assignAll(_mapAdditionalServicesFromProfile(pd));

    coreServicesList.assignAll(
      _mapSelectableCoreRows(
        pd: pd,
        flatShippingBlock:
            flatData is Map ? Map<String, dynamic>.from(flatData) : {},
        appData: appData,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      vendorData.value = args['vendorData'] ?? {};
      selectedService.value = args['service'] ?? '';

      loadCatalogForSelectedServiceType();

      // Auto-recalculate price when fields change
      everAll([
        selectedRateType,
        startDate,
        endDate,
        selectedNumHorses,
        selectedAdditionalIds,
        selectedCoreServiceIds,
      ], (_) => calculatePrice());

      // Fetch availability to populate locations
      fetchAvailability();
    }
  }

  Future<void> fetchAvailability() async {
    final id = vendorData['_id'] ?? vendorData['id'];
    if (id == null) return;

    isLoadingAvailability.value = true;
    try {
      final responses = await Future.wait([
        _apiService.getRequest('/availability/vendors/$id'),
        _apiService.getRequest('/trips/vendor/$id'),
      ]);

      final List combinedData = [];

      // 1. Regular availability
      if (responses[0].statusCode == 200 &&
          responses[0].body['success'] == true) {
        combinedData.addAll(responses[0].body['data'] ?? []);
      }

      // 2. Trips
      if (responses[1].statusCode == 200 &&
          responses[1].body['success'] == true) {
        final List tripsData = responses[1].body['data'] ?? [];
        for (var t in tripsData) {
          if (t is Map) {
            final Map tripMap = Map.from(t);
            tripMap['isTrip'] = true;
            combinedData.add(tripMap);
          }
        }
      }

      availabilityList.assignAll(combinedData);

      // Initialize selection with first available after fetch
      final locations = availableLocations;
      if (locations.isNotEmpty) {
        if (selectedLocation.value == null)
          selectedLocation.value = locations.first;
        if (selectedOrigin.value == null)
          selectedOrigin.value = locations.first;
        if (selectedDestination.value == null && locations.length > 1) {
          selectedDestination.value = locations[1];
        } else if (selectedDestination.value == null) {
          selectedDestination.value = locations.first;
        }
      }
    } catch (e) {
      debugPrint('Error fetching availability: $e');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  String get homeLocation {
    final homeBase =
        vendorData['homeBase'] ??
        _activeServiceData?['application']?['applicationData']?['homeBase'];
    if (homeBase == null) return '';

    final city = homeBase['city']?.toString() ?? '';
    final state = homeBase['state']?.toString() ?? '';

    if (city.isEmpty || state.isEmpty) return '';
    return '$city, $state';
  }

  List<String> get availableLocations {
    final List<String> locations = [];

    // 1. Add home location first
    final home = homeLocation;
    if (home.isNotEmpty) {
      locations.add('$home (Home)');
    }

    // 2. Add locations from availability and trips
    for (var avail in availabilityList) {
      // Trips / Shipping specific fields
      if (avail['origin'] != null && avail['origin'].toString().isNotEmpty) {
        locations.add(avail['origin'].toString());
      }
      if (avail['destination'] != null &&
          avail['destination'].toString().isNotEmpty) {
        locations.add(avail['destination'].toString());
      }

      if (avail['intermediateStops'] != null &&
          avail['intermediateStops'] is List) {
        for (var stop in avail['intermediateStops']) {
          if (stop is Map && stop['address'] != null) {
            locations.add(stop['address'].toString());
          } else if (stop != null && stop is! Map) {
            locations.add(stop.toString());
          }
        }
      }

      // General availability venues
      if (avail['showVenues'] != null && avail['showVenues'] is List) {
        for (var venue in avail['showVenues']) {
          if (venue is Map &&
              (venue['name'] != null || venue['address'] != null)) {
            locations.add((venue['name'] ?? venue['address']).toString());
          } else if (venue != null && venue is! Map) {
            locations.add(venue.toString());
          }
        }
      } else if (avail['showVenues'] != null &&
          avail['showVenues'] is String &&
          avail['showVenues'].toString().isNotEmpty) {
        locations.add(avail['showVenues'].toString());
      }

      // General location object
      if (avail['location'] != null && avail['location'] is Map) {
        final loc = avail['location'];
        final city = loc['city']?.toString() ?? '';
        final state = loc['state']?.toString() ?? '';
        if (city.isNotEmpty && state.isNotEmpty) {
          locations.add('$city, $state');
        }
      }
    }

    final uniqueLocations = locations
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();

    return uniqueLocations.isEmpty ? ['Other'] : uniqueLocations;
  }

  bool _isLocationMatch(dynamic avail, String locationName) {
    // Check origin/destination
    if (avail['origin'] == locationName || avail['destination'] == locationName)
      return true;

    // Check intermediate stops
    if (avail['intermediateStops'] is List) {
      for (var stop in avail['intermediateStops']) {
        if (stop is Map && stop['address'] == locationName) return true;
        if (stop.toString() == locationName) return true;
      }
    }

    // Check showVenues
    if (avail['showVenues'] != null) {
      if (avail['showVenues'] is List) {
        for (var venue in avail['showVenues']) {
          if (venue is Map &&
              (venue['name'] == locationName ||
                  venue['address'] == locationName))
            return true;
          if (venue.toString() == locationName) return true;
        }
      }
      if (avail['showVenues'].toString() == locationName) return true;
    }

    // Check location object
    if (avail['location'] != null && avail['location'] is Map) {
      final loc = avail['location'];
      final city = loc['city']?.toString() ?? '';
      final state = loc['state']?.toString() ?? '';
      if ('$city, $state' == locationName) return true;
    }

    return false;
  }

  // Find availability dates for a specific location
  Map<String, DateTime?> getAllowedDatesForLocation(String? locationName) {
    if (locationName == null ||
        locationName.contains('(Home)') ||
        locationName == 'Other') {
      return {'start': null, 'end': null};
    }

    for (var avail in availabilityList) {
      if (_isLocationMatch(avail, locationName)) {
        final sStr = avail['startDate'] ?? avail['specificDate'];
        final eStr = avail['endDate'] ?? avail['specificDate'];
        if (sStr != null && eStr != null) {
          return {
            'start': DateTime.tryParse(sStr),
            'end': DateTime.tryParse(eStr),
          };
        }
      }
    }
    return {'start': null, 'end': null};
  }

  List<String> getHorseOptionsForLocation(String? locationName) {
    if (locationName == null ||
        locationName.contains('(Home)') ||
        locationName == 'Other') {
      return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
    }

    for (var avail in availabilityList) {
      if (_isLocationMatch(avail, locationName)) {
        final max =
            int.tryParse(
              avail['maxBookings']?.toString() ??
                  avail['maxHorses']?.toString() ??
                  '1',
            ) ??
            1;
        // Ensure at least 1 is shown
        final count = max < 1 ? 1 : (max > 20 ? 20 : max);
        return List.generate(count, (i) => (i + 1).toString());
      }
    }
    return ['1', '2', '3', '4', '5'];
  }

  bool get isBraiding => selectedService.value.toLowerCase().contains('braid');
  bool get isClipping => selectedService.value.toLowerCase().contains('clip');
  bool get isFarrier => selectedService.value.toLowerCase().contains('farrier');
  bool get isBodywork =>
      selectedService.value.toLowerCase().contains('bodywork') ||
      selectedService.value.toLowerCase().contains('massage');
  bool get isShipping =>
      selectedService.value.toLowerCase().contains('ship') ||
      selectedService.value.toLowerCase().contains('transport');

  void toggleCoreService(String id) {
    if (id.contains('_')) {
      final baseId = id.split('_')[0];
      // If a session for this service is already selected, remove it first (exclusivity)
      final existing = selectedCoreServiceIds.firstWhereOrNull(
        (sid) => sid.startsWith('${baseId}_'),
      );
      if (existing != null) {
        selectedCoreServiceIds.remove(existing);
        if (existing == id) return; // Toggle off if it's the same session
      }
    }

    if (selectedCoreServiceIds.contains(id)) {
      selectedCoreServiceIds.remove(id);
    } else {
      selectedCoreServiceIds.add(id);
    }
  }

  void calculatePrice() {
    final bool isMultiService =
        isBraiding || isShipping || isClipping || isFarrier || isBodywork;

    if ((!isMultiService && selectedRateType.value == null) ||
        (isMultiService && selectedCoreServiceIds.isEmpty) ||
        startDate.value == null ||
        endDate.value == null ||
        selectedNumHorses.value == null) {
      totalPrice.value = 0.0;
      return;
    }

    final duration = endDate.value!.difference(startDate.value!).inDays + 1;
    final numHorses = int.tryParse(selectedNumHorses.value!) ?? 1;

    final rates = _effectiveGroomRatesForPricing;

    if (isMultiService) {
      double coreTotal = 0.0;
      for (var id in selectedCoreServiceIds) {
        final service = coreServicesList.firstWhereOrNull((s) => s['id'] == id);
        if (service != null) {
          coreTotal += (service['price'] as double) * numHorses;
        } else if (id.contains('_')) {
          // Handle composite ID: serviceId_duration
          final parts = id.split('_');
          final baseId = parts[0];
          final duration = parts[1];
          final baseService = coreServicesList.firstWhereOrNull(
            (s) => s['id'] == baseId,
          );
          if (baseService != null && baseService['rates'] != null) {
            final price = _parsePrice(baseService['rates'][duration]);
            coreTotal += price * numHorses;
          }
        }
      }
      // Note: For shipping, this is technically a per-mile rate.
      // Without a distance field, we treat this as the base cost or a simplified calculation.
      basePrice.value = coreTotal;
    } else {
      double rate = 0.0;
      if (selectedRateType.value!.startsWith('Day Rate')) {
        rate = double.tryParse(rates['daily']?.toString() ?? '250') ?? 250.0;
        basePrice.value = rate * duration * numHorses;
      } else if (selectedRateType.value!.startsWith('Week Rate')) {
        rate =
            double.tryParse(rates['weekly']?['price']?.toString() ?? '1200') ??
            1200.0;
        final weeks = (duration / 7).ceil();
        basePrice.value = rate * weeks * numHorses;
      } else if (selectedRateType.value!.startsWith('Month Rate')) {
        rate =
            double.tryParse(rates['monthly']?['price']?.toString() ?? '4500') ??
            4500.0;
        final months = (duration / 30).ceil();
        basePrice.value = rate * months * numHorses;
      }
    }

    double addOnTotal = 0.0;
    for (var id in selectedAdditionalIds) {
      final service = additionalServicesList.firstWhere((s) => s['id'] == id);
      addOnTotal += (service['price'] as double) * numHorses;
    }
    additionalTotal.value = addOnTotal;
    totalPrice.value = basePrice.value + additionalTotal.value;

    if (totalPrice.value > 0 && bookedServices.isNotEmpty) {
      isSummaryVisible.value = true;
    }
  }

  void editService(int index) {
    if (index < 0 || index >= bookedServices.length) return;

    final booking = bookedServices[index];

    selectedService.value = booking['serviceType'] ?? '';
    loadCatalogForSelectedServiceType();

    selectedRateType.value = booking['rateType']?.toString().isEmpty == true
        ? null
        : booking['rateType'];
    startDate.value = booking['startDate'];
    endDate.value = booking['endDate'];
    selectedNumHorses.value = booking['horses'];
    selectedLocation.value = booking['location'];
    selectedOrigin.value = booking['origin'];
    selectedDestination.value = booking['destination'];
    notesController.text = booking['notes'] ?? '';
    selectedAdditionalIds.assignAll(
      List<String>.from(booking['additionalIds'] ?? []),
    );
    selectedCoreServiceIds.assignAll(
      _migrateLegacyCoreIds(List<String>.from(booking['coreIds'] ?? [])),
    );

    bookedServices.removeAt(index);
    calculatePrice();
  }

  void toggleAdditionalService(String id) {
    if (selectedAdditionalIds.contains(id)) {
      selectedAdditionalIds.remove(id);
    } else {
      selectedAdditionalIds.add(id);
    }
  }

  bool validateForm() {
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select start and end dates',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedNumHorses.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select number of horses',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (isBraiding || isClipping || isFarrier || isBodywork || isShipping) {
      if (selectedCoreServiceIds.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please select at least one service/rate',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      if (isShipping) {
        if (selectedOrigin.value == null || selectedDestination.value == null) {
          Get.snackbar(
            'Validation Error',
            'Please select origin and destination locations',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        if (selectedLocation.value == null) {
          Get.snackbar(
            'Validation Error',
            'Please select a location',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return false;
        }
      }
    } else {
      // General form (Grooming, etc)
      if (selectedRateType.value == null) {
        Get.snackbar(
          'Validation Error',
          'Please select a rate type',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
      if (selectedLocation.value == null) {
        Get.snackbar(
          'Validation Error',
          'Please select a location',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }

  void clearFormFields() {
    selectedRateType.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedNumHorses.value = null;
    selectedLocation.value = null;
    selectedOrigin.value = null;
    selectedDestination.value = null;
    notesController.clear();
    originController.clear();
    destinationController.clear();
    selectedAdditionalIds.clear();
    selectedCoreServiceIds.clear();
    totalPrice.value = 0.0;
    basePrice.value = 0.0;
    additionalTotal.value = 0.0;
    isSummaryVisible.value = bookedServices.isNotEmpty;
  }

  void addServiceToSummary() {
    if (!validateForm()) return;

    bookedServices.add({
      'serviceType': selectedService.value,
      'rateType':
          selectedRateType.value ??
          (isBraiding
              ? 'Braiding Service'
              : isShipping
              ? 'Shipping Service'
              : 'Service'),
      'startDate': startDate.value,
      'endDate': endDate.value,
      'horses': selectedNumHorses.value,
      'location': isShipping
          ? '${selectedOrigin.value} to ${selectedDestination.value}'
          : selectedLocation.value,
      'origin': selectedOrigin.value,
      'destination': selectedDestination.value,
      'notes': notesController.text,
      'additionalIds': List<String>.from(selectedAdditionalIds),
      'coreIds': List<String>.from(selectedCoreServiceIds),
      'basePrice': basePrice.value,
      'totalPrice': totalPrice.value,
    });

    clearFormFields();
  }

  Future<void> sendRequest() async {
    // If there's something in the form but not yet 'added', we validate and include it
    final currentFormValid =
        (startDate.value != null ||
        selectedNumHorses.value != null ||
        selectedCoreServiceIds.isNotEmpty ||
        selectedRateType.value != null);

    if (bookedServices.isEmpty && !currentFormValid) {
      Get.snackbar(
        'Error',
        'Please fill out the form or select a service',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSending.value = true;
    try {
      // Combine bookedServices + current form (if valid)
      final allBookings = List<Map<String, dynamic>>.from(bookedServices);
      if (currentFormValid) {
        if (!validateForm()) {
          isSending.value = false;
          return;
        }

        allBookings.add({
          'serviceType': selectedService.value,
          'rateType':
              selectedRateType.value ??
              (isBraiding
                  ? 'Braiding Service'
                  : isShipping
                  ? 'Shipping Service'
                  : 'Service'),
          'startDate': startDate.value,
          'endDate': endDate.value,
          'horses': selectedNumHorses.value,
          'location': isShipping
              ? '${selectedOrigin.value} to ${selectedDestination.value}'
              : selectedLocation.value,
          'origin': selectedOrigin.value,
          'destination': selectedDestination.value,
          'notes': notesController.text,
          'additionalIds': List<String>.from(selectedAdditionalIds),
          'coreIds': List<String>.from(selectedCoreServiceIds),
          'basePrice': basePrice.value,
          'totalPrice': totalPrice.value,
        });
      }

      if (!Get.isRegistered<BookingController>()) {
        Get.put(BookingController());
      }
      final bookingController = Get.find<BookingController>();

      final serviceLines = <Map<String, dynamic>>[];
      for (var booking in allBookings) {
        final start = booking['startDate'] as DateTime;
        final end = booking['endDate'] as DateTime;
        serviceLines.add({
          'serviceType': booking['serviceType'],
          'type': booking['serviceType'],
          'startDate': DateFormat('yyyy-MM-dd').format(start),
          'endDate': DateFormat('yyyy-MM-dd').format(end),
          'rateType': booking['rateType'],
          'numberOfHorses': booking['horses'],
          'location': booking['location'],
          'origin': booking['origin'],
          'destination': booking['destination'],
          'notes': booking['notes'],
          'additionalServices': booking['additionalIds'],
          'coreServices': booking['coreIds'],
          'price': booking['totalPrice'],
        });
      }

      final payload = <String, dynamic>{
        'vendorId': vendorData['_id'] ?? vendorData['id'],
        'vendorBundleLines': serviceLines,
      };

      final result = await bookingController.createBooking(payload);
      final allSuccess = result != null;
      String? lastConversationId;
      if (result is Map && result['conversationId'] != null) {
        lastConversationId = result['conversationId'] as String?;
      }

      if (allSuccess) {
        // Refresh chat requests/inbox just in case
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().fetchConversations();
        }

        Get.back();
        Get.snackbar(
          'Success',
          'Booking request sent successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Redirect to chat
        if (lastConversationId != null) {
          Get.to(
            () => SingleChatView(
              name: vendorFullName,
              image: profilePhoto,
              conversationId: lastConversationId!,
              otherId: vendorData['_id'] ?? vendorData['id'],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending booking request: $e');
      Get.snackbar(
        'Error',
        'Failed to send booking request. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  void addIntermediateStop() {
    intermediateStops.add('');
  }

  void removeIntermediateStop(int index) {
    if (index >= 0 && index < intermediateStops.length) {
      intermediateStops.removeAt(index);
    }
  }

  String? getCoordsForLocation(String? locationName) {
    if (locationName == null) return null;
    
    for (var avail in availabilityList) {
       if (avail['origin'] == locationName) {
          final coords = avail['originCoords']?['coordinates'];
          if (coords is List && coords.length == 2) return '${coords[1]},${coords[0]}';
       }
       if (avail['destination'] == locationName) {
          final coords = avail['destinationCoords']?['coordinates'];
          if (coords is List && coords.length == 2) return '${coords[1]},${coords[0]}';
       }
       if (avail['intermediateStops'] is List) {
          for (var stop in avail['intermediateStops']) {
             if (stop is Map && stop['address'] == locationName) {
                final coords = stop['locationCoords']?['coordinates'];
                if (coords is List && coords.length == 2) return '${coords[1]},${coords[0]}';
             }
          }
       }
    }
    return null;
  }

  // Display Getters
  String get vendorFullName =>
      '${vendorData['firstName'] ?? ''} ${vendorData['lastName'] ?? ''}'.trim();
  String get businessName => vendorData['businessName'] ?? 'Independent';
  String get profilePhoto => vendorData['profilePhoto'] ?? '';

  dynamic get _activeServiceData {
    final List services = vendorData['assignedServices'] ?? [];
    return services.firstWhereOrNull(
      (s) => s['serviceType']?.toString() == selectedService.value,
    );
  }

  /// Single assigned-service row matching [selectedService].
  Map<String, dynamic> assignedServiceRowMap() {
    final List services = vendorData['assignedServices'] ?? [];
    final raw = services.firstWhereOrNull(
      (s) => s['serviceType']?.toString() == selectedService.value,
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  /// Profile merged for the selected service (falls back when merge was skipped).
  Map<String, dynamic> get _effectiveProfileData {
    if (mergedProfileForSelectedType.isNotEmpty) {
      return mergedProfileForSelectedType;
    }
    final svc = assignedServiceRowMap();
    final nested = svc['profile'];
    if (nested is Map && nested['profileData'] is Map) {
      return Map<String, dynamic>.from(nested['profileData'] as Map);
    }
    return {};
  }

  Map<String, dynamic> get _effectiveGroomRatesForPricing {
    return _groomRatesAsLegacyMap(_effectiveProfileData);
  }

  String get locationStr {
    final homeBase =
        vendorData['homeBase'] ??
        _activeServiceData?['application']?['applicationData']?['homeBase'];
    if (homeBase == null) return 'N/A';

    final city = homeBase['city'] ?? '';
    final state = homeBase['state'] ?? '';

    if (city.isEmpty || state.isEmpty) return 'N/A';
    return '$city, $state, ${homeBase['country'] ?? 'USA'}';
  }

  List<Map<String, dynamic>> get rateOptions {
    final rates = _effectiveGroomRatesForPricing;

    final List<Map<String, dynamic>> options = [];
    if (rates['daily'] != null)
      options.add({'label': 'Day Rate', 'price': '\$${rates['daily']}'});
    if (rates['weekly']?['price'] != null)
      options.add({
        'label': 'Week Rate (${rates['weekly']?['days'] ?? 6}d)',
        'price': '\$${rates['weekly']['price']}',
      });
    if (rates['monthly']?['price'] != null)
      options.add({
        'label': 'Month Rate',
        'price': '\$${rates['monthly']['price']}',
      });

    // Default if none set
    if (options.isEmpty)
      return [
        {'label': 'Day Rate', 'price': '\$250'},
        {'label': 'Week Rate', 'price': '\$1200'},
        {'label': 'Month Rate', 'price': '\$4500'},
      ];
    return options;
  }

  List<String> get includedServices {
    final profile = _effectiveProfileData;
    if (profile.isEmpty) return [];
    final List<String> items = [];
    if (profile['capabilities']?['support'] != null)
      items.addAll(List<String>.from(profile['capabilities']['support']));
    if (profile['capabilities']?['handling'] != null)
      items.addAll(List<String>.from(profile['capabilities']['handling']));
    return items;
  }
}
