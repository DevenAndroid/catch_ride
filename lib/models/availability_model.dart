class AvailabilityModel {
  final String? id;
  final String cityState;
  final String showVenue;
  final String startDate;
  final String endDate;
  final bool isActive;

  AvailabilityModel({
    this.id,
    required this.cityState,
    required this.showVenue,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['_id'],
      cityState: json['cityState'] ?? '',
      showVenue: json['showVenue'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'cityState': cityState,
      'showVenue': showVenue,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
