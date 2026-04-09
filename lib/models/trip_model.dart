class TripModel {
  String? id;
  String? origin;
  String? destination;
  List<String> destinationTags;
  DateTime? startDate;
  DateTime? endDate;
  int maxHorses;
  String? equipmentDescription;
  String? routeNotes;
  bool allowIntermediateStops;
  List<String> intermediateStops;
  String status; // 'Open', 'Limited', 'Full'

  TripModel({
    this.id,
    this.origin,
    this.destination,
    this.destinationTags = const [],
    this.startDate,
    this.endDate,
    this.maxHorses = 1,
    this.equipmentDescription,
    this.routeNotes,
    this.allowIntermediateStops = false,
    this.intermediateStops = const [],
    this.status = 'Open',
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'] ?? json['id'],
      origin: json['origin'],
      destination: json['destination'],
      destinationTags: List<String>.from(json['destinationTags'] ?? []),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      maxHorses: json['maxHorses'] ?? 1,
      equipmentDescription: json['equipmentDescription'],
      routeNotes: json['routeNotes'],
      allowIntermediateStops: json['allowIntermediateStops'] ?? false,
      intermediateStops: List<String>.from(json['intermediateStops'] ?? []),
      status: json['status'] ?? 'Open',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'origin': origin,
      'destination': destination,
      'destinationTags': destinationTags,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxHorses': maxHorses,
      'equipmentDescription': equipmentDescription,
      'routeNotes': routeNotes,
      'allowIntermediateStops': allowIntermediateStops,
      'intermediateStops': intermediateStops,
      'status': status,
    };
  }
}
