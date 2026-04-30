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
  List<Map<String, dynamic>>? intermediateStopsData;
  List<double>? originCoords;
  List<double>? destinationCoords;

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
    this.originCoords,
    this.destinationCoords,
    this.intermediateStopsData,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Handle coordinates
    List<double>? parseCoords(dynamic coordsJson) {
      if (coordsJson != null && coordsJson['coordinates'] != null) {
        return List<double>.from(coordsJson['coordinates'].map((e) => e.toDouble()));
      }
      return null;
    }

    // Handle intermediate stops safely
    List<String> stops = [];
    List<Map<String, dynamic>> stopsData = [];
    
    if (json['intermediateStops'] != null && json['intermediateStops'] is List) {
      for (var item in json['intermediateStops']) {
        if (item is String) {
          stops.add(item);
        } else if (item is Map) {
          stops.add(item['address']?.toString() ?? '');
          stopsData.add(Map<String, dynamic>.from(item));
        }
      }
    }

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
      intermediateStops: stops,
      intermediateStopsData: stopsData,
      status: json['status'] ?? 'Open',
      originCoords: parseCoords(json['originCoords']),
      destinationCoords: parseCoords(json['destinationCoords']),
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
