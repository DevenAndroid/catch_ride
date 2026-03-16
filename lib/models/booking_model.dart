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
  final String? horseId;
  final String? horseName;
  final String date;
  final String? startTime;
  final String? endTime;
  final double price;
  final String? paymentStatus;
  final String? horseImage;
  final String? location;
  final String? notes;

  BookingModel({
    this.id,
    required this.bookingNumber,
    required this.type,
    required this.status,
    this.clientId,
    this.clientName,
    this.trainerId,
    this.trainerName,
    this.horseId,
    this.horseName,
    required this.date,
    this.startTime,
    this.endTime,
    required this.price,
    this.paymentStatus,
    this.horseImage,
    this.location,
    this.notes,
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
      horseId: json['horseId'] is Map ? json['horseId']['_id'] : json['horseId'],
      horseName: (json['horseName'] != null && json['horseName'].toString().isNotEmpty) 
          ? json['horseName'] 
          : (json['horseId'] is Map ? json['horseId']['name'] : null),
      date: displayDate,
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      paymentStatus: json['paymentStatus'],
      horseImage: json['horseImage'] ?? (json['horseId'] is Map ? (json['horseId']['images']?.isNotEmpty == true ? json['horseId']['images'].first : json['horseId']['photo']) : null),
      location: (json['location'] != null && json['location'].toString().isNotEmpty) ? json['location'] : null,
      notes: json['notes'],
    );
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
    };
  }
}
