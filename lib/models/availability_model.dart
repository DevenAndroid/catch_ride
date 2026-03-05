class AvailabilityModel {
  final String? id;
  final String cityState;
  final String showVenue;
  final String startDate;
  final String endDate;

  AvailabilityModel({
    this.id,
    required this.cityState,
    required this.showVenue,
    required this.startDate,
    required this.endDate,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['_id'],
      cityState: json['cityState'] ?? '',
      showVenue: json['showVenue'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'cityState': cityState,
      'showVenue': showVenue,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
