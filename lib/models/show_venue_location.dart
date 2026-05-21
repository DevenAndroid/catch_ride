import 'package:get/get.dart';

/// Venue or city entry for vendor availability `showVenues` (`name` + `location` only).
class ShowVenueLocation {
  final String name;
  final String location;

  const ShowVenueLocation({
    this.name = '',
    this.location = '',
  });

  String get locationLine => location.trim();

  String get displayLabel {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    return locationLine.isNotEmpty ? locationLine : 'Unknown';
  }

  String? get displaySubtitle {
    final loc = locationLine;
    final n = name.trim();
    if (loc.isEmpty) return null;
    if (n.isEmpty || n == loc) return null;
    return loc;
  }

  String get selectionKey {
    return '${name.trim().toLowerCase()}|${location.trim().toLowerCase()}';
  }

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'location': location.trim(),
      };

  static String buildLocationLine({
    String city = '',
    String state = '',
    String country = '',
  }) {
    return [city, state, country]
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(', ');
  }

  factory ShowVenueLocation.fromJson(dynamic json) {
    if (json is String) {
      final s = json.trim();
      if (s.isEmpty) return const ShowVenueLocation();
      return ShowVenueLocation.fromGoogleFormattedName(s, useAsName: true);
    }
    if (json is! Map) return const ShowVenueLocation();
    final map = Map<String, dynamic>.from(json);

    final name =
        (map['name'] ?? map['venue'] ?? map['showVenue'] ?? '').toString();
    var loc = (map['location'] ?? '').toString().trim();
    if (loc.isEmpty) {
      loc = buildLocationLine(
        city: (map['city'] ?? '').toString(),
        state: (map['state'] ?? '').toString(),
        country: (map['country'] ?? '').toString(),
      );
    }
    return ShowVenueLocation(name: name, location: loc);
  }

  factory ShowVenueLocation.fromHorseShow(Map<String, dynamic> show) {
    final venueName =
        show['showVenue']?.toString() ?? show['name']?.toString() ?? '';
    return ShowVenueLocation(
      name: venueName,
      location: buildLocationLine(
        city: show['city']?.toString() ?? '',
        state: show['state']?.toString() ?? '',
        country: show['country']?.toString() ?? '',
      ),
    );
  }

  factory ShowVenueLocation.fromGoogleFormattedName(
    String formatted, {
    bool useAsName = false,
  }) {
    final trimmed = formatted.trim();
    if (trimmed.isEmpty) return const ShowVenueLocation();
    final parts = trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final cityLabel = parts.isNotEmpty ? parts.first : trimmed;
    return ShowVenueLocation(
      name: useAsName ? cityLabel : trimmed,
      location: trimmed,
    );
  }

  static List<ShowVenueLocation> listFromJson(dynamic raw) {
    if (raw == null) return [];
    if (raw is String && raw.trim().isNotEmpty) {
      return [ShowVenueLocation.fromJson(raw)];
    }
    if (raw is! List) return [];
    return raw.map(ShowVenueLocation.fromJson).toList();
  }

  static List<Map<String, dynamic>> listToApiPayload(
    List<ShowVenueLocation> venues,
  ) =>
      venues.map((v) => v.toJson()).toList();

  static bool containsVenue(
    List<ShowVenueLocation> list,
    ShowVenueLocation venue,
  ) =>
      list.any((v) => v.selectionKey == venue.selectionKey);

  static void toggleVenue(
    RxList<ShowVenueLocation> list,
    ShowVenueLocation venue,
    bool selected,
  ) {
    if (selected) {
      if (!containsVenue(list, venue)) list.add(venue);
    } else {
      list.removeWhere((v) => v.selectionKey == venue.selectionKey);
    }
  }
}
