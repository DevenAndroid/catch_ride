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
    return BookingModel(
      id: json['_id'],
      bookingNumber: json['bookingNumber'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      clientId: json['clientId'] is Map ? json['clientId']['_id'] : json['clientId'],
      clientName: json['clientName'],
      trainerId: json['trainerId'] is Map ? json['trainerId']['_id'] : json['trainerId'],
      trainerName: json['trainerName'],
      horseId: json['horseId'] is Map ? json['horseId']['_id'] : json['horseId'],
      horseName: json['horseName'],
      date: json['date'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      paymentStatus: json['paymentStatus'],
      horseImage: json['horseId'] is Map ? json['horseId']['images']?.first : null,
      location: json['horseId'] is Map ? json['horseId']['location'] : null,
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
