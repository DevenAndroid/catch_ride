import 'package:intl/intl.dart';

class BookingModel {
  final String? id;
  final String bookingNumber;
  final String type;
  final String status;
  final String? clientId;
  final String? clientName;
  /// Role of [clientId] when populated from the API (e.g. `barn_manager`).
  final String? clientRole;
  /// Set on [clientId] user when they are a barn manager account.
  final bool clientIsBarnManager;
  /// Linked trainer profile name when the requester is a barn manager.
  final String? requesterTrainerName;
  final String? requesterTrainerImage;
  final String? trainerId;   // Trainer Profile ID
  final String? trainerName;
  final String? trainerUserId; // Trainer's User ID (for chat threads)
  final String? vendorId;
  final String? vendorName;
  final String? horseId;
  final String? horseName;
  final String date;
  final String? startTime;
  final String? endTime;
  final double price;
  final String? paymentStatus;
  final String? horseImage;
  final String? clientImage;
  final String? vendorImage;
  final String? trainerImage;
  final String? location;
  /// Horse's listed address/home location from populated `horseId` (distinct from booking `location`, which may be a show venue name).
  final String? horseLocation;
  final String? notes;
  final String? startDate;
  final String? endDate;
  final String? acceptedById;
  final String? acceptedByName;
  final String? acceptedByRole;
  final String? barnManagerId;
  final String? barnManagerName;
  final String? senderBarnName;
  final String? providerBarnName;
  final List<String> tags;
  final int? numberOfHorses;
  final String? origin;
  final String? destination;
  final List<dynamic> coreServices;
  final List<dynamic> additionalServices;
  final String? rateType;
  /// Vendor multi-service bundle (one booking, multiple lines). Empty for legacy bookings.
  final List<Map<String, dynamic>> vendorBundleLines;

  BookingModel({
    this.id,
    required this.bookingNumber,
    required this.type,
    required this.status,
    this.clientId,
    this.clientName,
    this.clientRole,
    this.clientIsBarnManager = false,
    this.requesterTrainerName,
    this.requesterTrainerImage,
    this.trainerId,
    this.trainerName,
    this.trainerUserId,
    this.vendorId,
    this.vendorName,
    this.horseId,
    this.horseName,
    required this.date,
    this.startTime,
    this.endTime,
    required this.price,
    this.paymentStatus,
    this.horseImage,
    this.trainerImage,
    this.location,
    this.horseLocation,
    this.notes,
    this.startDate,
    this.endDate,
    this.tags = const [],
    this.acceptedById,
    this.acceptedByName,
    this.acceptedByRole,
    this.clientImage,
    this.vendorImage,
    this.barnManagerId,
    this.barnManagerName,
    this.senderBarnName,
    this.providerBarnName,
    this.numberOfHorses,
    this.origin,
    this.destination,
    this.coreServices = const [],
    this.additionalServices = const [],
    this.rateType,
    this.vendorBundleLines = const [],
  });

  bool get _clientActsAsBarnManager =>
      clientRole == 'barn_manager' || clientIsBarnManager;

  /// Name shown for the trial requester. Barn managers act for their linked trainer.
  String get displayClientName {
    if (_clientActsAsBarnManager &&
        requesterTrainerName != null &&
        requesterTrainerName!.isNotEmpty) {
      return requesterTrainerName!;
    }
    return clientName ?? '';
  }

  /// Avatar for [displayClientName].
  String? get displayClientImage {
    if (_clientActsAsBarnManager &&
        requesterTrainerImage != null &&
        requesterTrainerImage!.isNotEmpty) {
      return requesterTrainerImage;
    }
    return clientImage;
  }

  static String? _nameFromProfileMap(dynamic data) {
    if (data is! Map) return null;
    final name =
        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    return name.isNotEmpty ? name : null;
  }

  static String? _imageFromProfileMap(dynamic data) {
    if (data is! Map) return null;
    for (final key in [
      'profilePhoto',
      'photo',
      'avatar',
      'displayAvatar',
      'profileImage',
      'image',
    ]) {
      final v = data[key];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return null;
  }

  static String? _linkedTrainerNameFromClient(Map client) {
    final fromUserTrainer = _nameFromProfileMap(client['trainerId']);
    if (fromUserTrainer != null) return fromUserTrainer;

    if (client['barnManagerId'] is Map) {
      final bm = client['barnManagerId'] as Map;
      final fromBmTrainer = _nameFromProfileMap(bm['trainerId']);
      if (fromBmTrainer != null) return fromBmTrainer;
    }
    return null;
  }

  static String? _linkedTrainerImageFromClient(Map client) {
    final fromUserTrainer = _imageFromProfileMap(client['trainerId']);
    if (fromUserTrainer != null) return fromUserTrainer;

    if (client['barnManagerId'] is Map) {
      final bm = client['barnManagerId'] as Map;
      final fromBmTrainer = _imageFromProfileMap(bm['trainerId']);
      if (fromBmTrainer != null) return fromBmTrainer;
    }
    return null;
  }

  static List<Map<String, dynamic>> _parseVendorBundleLines(dynamic raw) {
    if (raw is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // ... rest of the code ...
    // Direct date extraction
    Object? dateVal = json['date'];
    String displayDate = 'N/A';

    if (dateVal != null) {
      if (dateVal is String) {
        if (dateVal.contains('T')) {
          try {
            final dt = DateTime.parse(dateVal);
            displayDate = DateFormat('MMM dd, yyyy').format(dt);
          } catch (e) {
            displayDate = dateVal.split('T').first;
          }
        } else {
          displayDate = dateVal;
        }
      } else {
        displayDate = dateVal.toString();
      }
    }

    String? acceptedByN;
    if (json['acceptedById'] is Map) {
      final map = json['acceptedById'];
      acceptedByN = "${map['firstName'] ?? ''} ${map['lastName'] ?? ''}".trim();
    }

    // Date Range Handling
    String? sDateVal = json['startDate'];
    String? eDateVal = json['endDate'];
    
    String? formatD(String? val, String format) {
      if (val == null || val.toString().isEmpty) return null;
      try {
        final dt = DateTime.parse(val.toString());
        return DateFormat(format).format(dt);
      } catch (e) {
        // If it's already a clean date string like 15 Apr, keep it
        return val.toString();
      }
    }

    String? sDateFormatted = formatD(sDateVal, 'MMM dd');
    String? eDateFormatted = formatD(eDateVal, 'MMM dd, yyyy');
    
    if (sDateFormatted != null && eDateFormatted != null) {
      displayDate = "$sDateFormatted - $eDateFormatted";
    }

    // Aggressive Deep-Search Image Helper
    String? deepSearchPhoto(dynamic data) {
      if (data is! Map) return null;
      // 1. Direct photo-sounding keys
      for (final key in ['profilePhoto', 'photo', 'avatar', 'displayAvatar', 'image', 'profileImage', 'businessLogo', 'trainerPhoto', 'clientPhoto']) {
        if (data[key] != null && data[key].toString().isNotEmpty && data[key] is String) return data[key].toString();
      }
      // 2. Common nested profile fields in this app
      if (data['trainerId'] is Map) {
        String? found = deepSearchPhoto(data['trainerId']);
        if (found != null) return found;
      }
      if (data['clientId'] is Map) {
        String? found = deepSearchPhoto(data['clientId']);
        if (found != null) return found;
      }
      if (data['vendorId'] is Map) {
        String? found = deepSearchPhoto(data['vendorId']);
        if (found != null) return found;
      }
      if (data['profile'] is Map) {
        String? found = deepSearchPhoto(data['profile']);
        if (found != null) return found;
      }
      if (data['user'] is Map) {
        String? found = deepSearchPhoto(data['user']);
        if (found != null) return found;
      }
      return null;
    }

    // Robust image extraction for both sides
    String? vendorImg;
    if (json['vendorId'] != null) {
      vendorImg = deepSearchPhoto(json['vendorId']);
    }
    if (vendorImg == null && json['acceptedById'] != null && json['acceptedByRole'] != 'user') {
      vendorImg = deepSearchPhoto(json['acceptedById']);
    }

    String? clientImg;
    if (json['clientId'] != null) {
      clientImg = deepSearchPhoto(json['clientId']);
    }
    if (clientImg == null && json['trainerId'] != null) {
      clientImg = deepSearchPhoto(json['trainerId']);
    }

    // Existing trainerImage logic (for backward compatibility if needed)
    String? trainerImg = vendorImg ?? clientImg ?? deepSearchPhoto(json);
    trainerImg ??= json['trainerProfilePhoto'] ?? json['clientProfilePhoto'];

    String? senderBN;
    if (json['clientId'] is Map) {
      if (json['clientId']['trainerId'] is Map) {
        senderBN = json['clientId']['trainerId']['barnName'];
      }
      // If not in trainer profile, check user profile directly
      senderBN ??= json['clientId']['barnName'];
      
      // If still null, check if it's in the top level if not populated
      if (senderBN == null && json['clientBarnName'] != null) {
        senderBN = json['clientBarnName'];
      }
    }

    String? providerBN;
    if (json['trainerId'] is Map) {
       providerBN = json['trainerId']['barnName'];
    }

    String? bmName;
    if (json['barnManagerId'] is Map) {
      bmName = "${json['barnManagerId']['firstName'] ?? ''} ${json['barnManagerId']['lastName'] ?? ''}".trim();
    }

    String? horseLoc;
    if (json['horseId'] is Map) {
      final h = json['horseId'];
      final loc = h['location'];
      if (loc != null && loc.toString().trim().isNotEmpty) {
        horseLoc = loc.toString().trim();
      }
    }

    String? clientRoleVal;
    bool clientIsBarnManagerVal = false;
    String? requesterTrainerNameVal;
    String? requesterTrainerImageVal;
    if (json['clientId'] is Map) {
      final client = json['clientId'] as Map;
      clientRoleVal = client['role']?.toString();
      clientIsBarnManagerVal =
          clientRoleVal == 'barn_manager' || client['barnManagerId'] != null;
      requesterTrainerNameVal = _linkedTrainerNameFromClient(client);
      requesterTrainerImageVal = _linkedTrainerImageFromClient(client);
    }

    // Booking-level barn manager (set on create / accept)
    if ((requesterTrainerNameVal == null ||
            requesterTrainerNameVal!.isEmpty) &&
        json['barnManagerId'] is Map) {
      final bm = json['barnManagerId'] as Map;
      clientIsBarnManagerVal = true;
      requesterTrainerNameVal ??= _nameFromProfileMap(bm['trainerId']);
      requesterTrainerImageVal ??= _imageFromProfileMap(bm['trainerId']);
    }

    return BookingModel(
      id: json['_id'],
      bookingNumber: json['bookingNumber'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      clientId: json['clientId'] is Map ? json['clientId']['_id'] : json['clientId'],
      clientName: json['clientName'] ?? (json['clientId'] is Map ? "${json['clientId']['firstName'] ?? ''} ${json['clientId']['lastName'] ?? ''}".trim() : null),
      clientRole: clientRoleVal,
      clientIsBarnManager: clientIsBarnManagerVal,
      requesterTrainerName: requesterTrainerNameVal?.isNotEmpty == true
          ? requesterTrainerNameVal
          : null,
      requesterTrainerImage: requesterTrainerImageVal,
      trainerId: json['trainerId'] is Map ? json['trainerId']['_id'] : json['trainerId'],
      trainerUserId: json['trainerId'] is Map ? json['trainerId']['userId']?.toString() : null,
      trainerName: (json['trainerName'] != null && json['trainerName'].toString().isNotEmpty)
          ? json['trainerName']
          : (json['trainerId'] is Map 
              ? "${json['trainerId']['firstName'] ?? ''} ${json['trainerId']['lastName'] ?? ''}".trim() 
              : (json['clientId'] is Map 
                  ? "${json['clientId']['firstName'] ?? ''} ${json['clientId']['lastName'] ?? ''}".trim() 
                  : json['clientName'])),
      vendorId: json['vendorId'] is Map 
          ? (json['vendorId']['vendorProfileId'] ?? json['vendorId']['_id'] ?? json['vendorId']['id']) 
          : (json['vendorProfileId'] ?? json['vendorId']),
      vendorName: json['vendorId'] is Map ? "${json['vendorId']['firstName'] ?? ''} ${json['vendorId']['lastName'] ?? ''}".trim() : null,
      horseId: json['horseId'] is Map ? json['horseId']['_id'] : json['horseId'],
      horseName: (json['horseName'] != null && json['horseName'].toString().isNotEmpty)
          ? json['horseName']
          : (json['horseId'] is Map ? json['horseId']['name'] : null),
      date: displayDate,
      startDate: sDateVal,
      endDate: eDateVal,
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      paymentStatus: json['paymentStatus'],
      horseImage: json['horseImage'] ?? (json['horseId'] is Map ? (json['horseId']['images']?.isNotEmpty == true ? json['horseId']['images'].first : json['horseId']['photo']) : null),
      trainerImage: trainerImg,
      location: (json['location'] != null && json['location'].toString().isNotEmpty) ? json['location'] : (json['horseId'] is Map ? json['horseId']['location'] : null),
      horseLocation: horseLoc,
      notes: json['notes'],
      tags: _parseTags(json['horseId']),
      acceptedById: json['acceptedById'] is Map ? json['acceptedById']['_id'] : json['acceptedById'],
      acceptedByName: acceptedByN,
      acceptedByRole: json['acceptedByRole'],
      clientImage: clientImg,
      vendorImage: vendorImg,
      barnManagerId: json['barnManagerId'] is Map ? json['barnManagerId']['_id'] : json['barnManagerId'],
      barnManagerName: bmName,
      senderBarnName: senderBN,
      providerBarnName: providerBN,
      numberOfHorses: json['numberOfHorses'] != null ? int.tryParse(json['numberOfHorses'].toString()) : null,
      origin: json['origin'],
      destination: json['destination'],
      coreServices: json['coreServices'] is List ? json['coreServices'] : [],
      additionalServices: json['additionalServices'] is List ? json['additionalServices'] : [],
      rateType: json['rateType'],
      vendorBundleLines: _parseVendorBundleLines(
        json['vendorBundleLines'] ?? json['serviceLines'],
      ),
    );
  }

  static List<String> _parseTags(dynamic horseData) {
    if (horseData is! Map) return [];
    final List<String> result = [];
    for (final key in ['programTags', 'opportunityTags', 'personalityTags']) {
      final list = horseData[key];
      if (list is List) {
        for (final t in list) {
          if (t is Map) {
            final name = t['name'] ?? t['_id'] ?? '';
            if (name.toString().isNotEmpty) result.add(name.toString());
          } else if (t is String && t.isNotEmpty) {
            result.add(t);
          }
        }
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'bookingNumber': bookingNumber,
      'type': type,
      'status': status,
      'clientId': clientId,
      'clientName': clientName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'horseId': horseId,
      'horseName': horseName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'paymentStatus': paymentStatus,
      'horseImage': horseImage,
      'location': location,
      if (horseLocation != null) 'horseLocation': horseLocation,
      'notes': notes,
      'tags': tags,
      'numberOfHorses': numberOfHorses,
      'origin': origin,
      'destination': destination,
      'coreServices': coreServices,
      'additionalServices': additionalServices,
      'rateType': rateType,
      'vendorBundleLines': vendorBundleLines,
    };
  }
}
