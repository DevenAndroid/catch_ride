// load_models.dart (no longer needs material)

enum LoadStatus { open, limited, full, closed }

class ShippingLoad {
  final String id;
  final String shipperId;
  String origin; // City or Show Venue
  List<String> destinations;
  DateTime? startDate;
  DateTime? endDate;
  int totalSlots;
  int remainingSlots;
  String equipmentType; // e.g., "6-Horse Air Ride Gooseneck"
  bool allowsStops;
  String? notes;
  bool isPublic;
  LoadStatus status;

  ShippingLoad({
    required this.id,
    required this.shipperId,
    required this.origin,
    required this.destinations,
    this.startDate,
    this.endDate,
    required this.totalSlots,
    required this.remainingSlots,
    required this.equipmentType,
    this.allowsStops = true,
    this.notes,
    this.isPublic = true,
    this.status = LoadStatus.open,
  });

  String get dateRange {
    if (startDate == null) return "TBD";
    if (endDate == null || endDate == startDate) {
      return "${startDate!.month}/${startDate!.day}/${startDate!.year}";
    }
    return "${startDate!.month}/${startDate!.day} - ${endDate!.month}/${endDate!.day}, ${endDate!.year}";
  }

  String get destinationSummary {
    if (destinations.isEmpty) return "TBD";
    if (destinations.length == 1) return destinations.first;
    return "${destinations.first} + ${destinations.length - 1} more";
  }
}
