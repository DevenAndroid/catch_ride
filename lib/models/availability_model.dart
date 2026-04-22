class AvailabilityModel {
  final String? id;
  final String? showId;
  final String cityState;
  final String showVenue;
  final String? showName;
  final String startDate;
  final String endDate;
  final bool isActive;

  AvailabilityModel({
    this.id,
    this.showId,
    required this.cityState,
    required this.showVenue,
    this.showName,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['_id'],
      showId: json['showId'] != null
          ? (json['showId'] is String ? json['showId'] : json['showId']['_id'])
          : null,
      cityState: json['cityState'] ?? '',
      showVenue: json['showVenue'] ?? '',
      showName: json['showName'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (showId != null) 'showId': showId,
      'cityState': cityState,
      'showVenue': showVenue,
      if (showName != null) 'showName': showName,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
