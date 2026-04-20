import 'package:intl/intl.dart';

class BookingModel {
  final String? id;
  final String bookingNumber;
  final String type;
  final String status;
  final String? clientId;
  final String? clientName;
  final String? trainerId;
  final String? trainerName;
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
  final String? notes;
  final String? startDate;
  final String? endDate;
  final String? acceptedById;
  final String? acceptedByName;
  final String? acceptedByRole;
  final List<String> tags;

  BookingModel({
    this.id,
    required this.bookingNumber,
    required this.type,
    required this.status,
    this.clientId,
    this.clientName,
    this.trainerId,
    this.trainerName,
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
    this.notes,
    this.startDate,
    this.endDate,
    this.tags = const [],
    this.acceptedById,
    this.acceptedByName,
    this.acceptedByRole,
    this.clientImage,
    this.vendorImage,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Direct date extraction
    Object? dateVal = json['date'];
    String displayDate = 'N/A';

    if (dateVal != null) {
      if (dateVal is String) {
        if (dateVal.contains('T')) {
          try {
            final dt = DateTime.parse(dateVal);
            displayDate = DateFormat('dd MMM yyyy').format(dt);
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

    String? sDate = formatD(sDateVal, 'dd MMM');
    String? eDate = formatD(eDateVal, 'dd MMM yyyy');
    
    if (sDate != null && eDate != null) {
      displayDate = "$sDate - $eDate";
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

    print('Booking ID: ${json['_id']} - VendorImg: $vendorImg, ClientImg: $clientImg');

    return BookingModel(
      id: json['_id'],
      bookingNumber: json['bookingNumber'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      clientId: json['clientId'] is Map ? json['clientId']['_id'] : json['clientId'],
      clientName: json['clientName'] ?? (json['clientId'] is Map ? "${json['clientId']['firstName'] ?? ''} ${json['clientId']['lastName'] ?? ''}".trim() : null),
      trainerId: json['trainerId'] is Map ? json['trainerId']['_id'] : json['trainerId'],
      trainerName: (json['trainerName'] != null && json['trainerName'].toString().isNotEmpty)
          ? json['trainerName']
          : (json['trainerId'] is Map ? "${json['trainerId']['firstName'] ?? ''} ${json['trainerId']['lastName'] ?? ''}".trim() : null),
      vendorId: json['vendorId'] is Map 
          ? (json['vendorId']['vendorProfileId'] ?? json['vendorId']['_id'] ?? json['vendorId']['id']) 
          : (json['vendorProfileId'] ?? json['vendorId']),
      vendorName: json['vendorId'] is Map ? "${json['vendorId']['firstName'] ?? ''} ${json['vendorId']['lastName'] ?? ''}".trim() : null,
      horseId: json['horseId'] is Map ? json['horseId']['_id'] : json['horseId'],
      horseName: (json['horseName'] != null && json['horseName'].toString().isNotEmpty)
          ? json['horseName']
          : (json['horseId'] is Map ? json['horseId']['name'] : null),
      date: displayDate,
      startDate: sDate,
      endDate: eDate,
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      paymentStatus: json['paymentStatus'],
      horseImage: json['horseImage'] ?? (json['horseId'] is Map ? (json['horseId']['images']?.isNotEmpty == true ? json['horseId']['images'].first : json['horseId']['photo']) : null),
      trainerImage: trainerImg,
      location: (json['location'] != null && json['location'].toString().isNotEmpty) ? json['location'] : (json['horseId'] is Map ? json['horseId']['location'] : null),
      notes: json['notes'],
      tags: _parseTags(json['horseId']),
      acceptedById: json['acceptedById'] is Map ? json['acceptedById']['_id'] : json['acceptedById'],
      acceptedByName: acceptedByN,
      acceptedByRole: json['acceptedByRole'],
      clientImage: clientImg,
      vendorImage: vendorImg,
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
      'notes': notes,
      'tags': tags,
    };
  }
}
