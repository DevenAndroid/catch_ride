import 'package:intl/intl.dart';

import 'show_venue_location.dart';

class VendorAvailabilityModel {
  final String? id;
  final String vendorId;
  final String vendorName;
  final String availabilityType; // 'recurring', 'one-time', 'blocked'
  final int? dayOfWeek; // 0-6
  final List<TimeSlot>? timeSlots;
  final DateTime? specificDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool allDay;
  final String status; // 'available', 'booked', 'blocked'
  final List<String> serviceTypes;
  final LocationData? location;
  final int maxBookings;
  final int currentBookings;
  final String? notes;
  final List<ShowVenueLocation> showVenues;
  final DateTime? unavailableStart;
  final DateTime? unavailableEnd;
  final String? locationType; // 'Both', 'Barn', 'Show Venue'
  final String? capacityType; // 'No capacity limit', 'Max horses per time block', 'Max horses per day'
  final String? timeBlockType; // 'Full Day', 'Morning window', 'Afternoon window'
  final String? bufferTime; // '15 min', '30 min', '45 min'
  final int maxDays;
  final String? availabilityMode; // 'General bookings', 'Emergency-only'
  final String? newClientPolicy; 

  VendorAvailabilityModel({
    this.id,
    required this.vendorId,
    required this.vendorName,
    required this.availabilityType,
    this.dayOfWeek,
    this.timeSlots,
    this.specificDate,
    this.startDate,
    this.endDate,
    this.allDay = false,
    this.status = 'available',
    this.serviceTypes = const [],
    this.location,
    this.maxBookings = 1,
    this.currentBookings = 0,
    this.notes,
    this.showVenues = const [],
    this.unavailableStart,
    this.unavailableEnd,
    this.locationType,
    this.capacityType,
    this.timeBlockType,
    this.bufferTime,
    this.maxDays = 1,
    this.availabilityMode,
    this.newClientPolicy,
  });

  factory VendorAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final parsedVenues = ShowVenueLocation.listFromJson(json['showVenues']);

    return VendorAvailabilityModel(
      id: json['_id'],
      vendorId: (json['vendorId'] is Map ? json['vendorId']['_id'] : json['vendorId'])?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? 'Unknown Vendor',
      availabilityType: json['availabilityType']?.toString() ?? 'one-time',
      dayOfWeek: json['dayOfWeek'],
      timeSlots: (json['timeSlots'] as List?)
          ?.map((e) => TimeSlot.fromJson(e))
          .toList(),
      specificDate: json['specificDate'] != null ? DateTime.parse(json['specificDate']) : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      allDay: json['allDay'] ?? false,
      status: json['status'] ?? 'available',
      serviceTypes: List<String>.from(json['serviceTypes'] ?? []),
      location: json['location'] != null ? LocationData.fromJson(json['location']) : null,
      maxBookings: json['maxBookings'] ?? 1,
      currentBookings: json['currentBookings'] ?? 0,
      notes: json['notes'],
      showVenues: parsedVenues,
      unavailableStart: json['unavailableStart'] != null ? DateTime.parse(json['unavailableStart']) : null,
      unavailableEnd: json['unavailableEnd'] != null ? DateTime.parse(json['unavailableEnd']) : null,
      locationType: json['locationType'],
      capacityType: json['capacityType'],
      timeBlockType: json['timeBlockType'],
      bufferTime: json['bufferTime'],
      maxDays: json['maxDays'] ?? 1,
      availabilityMode: json['availabilityMode'],
      newClientPolicy: json['newClientPolicy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'availabilityType': availabilityType,
      'dayOfWeek': dayOfWeek,
      'timeSlots': timeSlots?.map((e) => e.toJson()).toList(),
      'specificDate': specificDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'allDay': allDay,
      'status': status,
      'serviceTypes': serviceTypes,
      'location': location?.toJson(),
      'maxBookings': maxBookings,
      'currentBookings': currentBookings,
      'notes': notes,
      'showVenues': ShowVenueLocation.listToApiPayload(showVenues),
      'unavailableStart': unavailableStart?.toIso8601String(),
      'unavailableEnd': unavailableEnd?.toIso8601String(),
      'locationType': locationType,
      'capacityType': capacityType,
      'timeBlockType': timeBlockType,
      'bufferTime': bufferTime,
      'maxDays': maxDays,
      'availabilityMode': availabilityMode,
      'newClientPolicy': newClientPolicy,
    };
  }

  String get dateDisplay {
    if (availabilityType == 'recurring') {
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return dayOfWeek != null ? 'Every ${days[dayOfWeek!]}' : 'Recurring';
    }
    if (startDate != null && endDate != null) {
      return '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}';
    }
    if (specificDate != null) {
      return DateFormat('MMM dd, yyyy').format(specificDate!);
    }
    return 'Unknown Date';
  }

  String get locationDisplay {
    if (showVenues.isNotEmpty) {
      return showVenues
          .map((v) {
            final sub = v.displaySubtitle;
            return sub != null ? '${v.displayLabel} ($sub)' : v.displayLabel;
          })
          .join(', ');
    }
    if (location == null) return 'N/A';
    final parts = [
      location!.city,
      location!.state,
      if (location!.country != null && location!.country!.isNotEmpty)
        location!.country!,
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}

class LocationData {
  final String city;
  final String state;
  final String? country;
  final String? address;
  final String? zipCode;

  LocationData({
    required this.city,
    required this.state,
    this.country,
    this.address,
    this.zipCode,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country']?.toString(),
      address: json['address'],
      zipCode: json['zipCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      if (country != null && country!.isNotEmpty) 'country': country,
      'address': address,
      'zipCode': zipCode,
    };
  }
}
