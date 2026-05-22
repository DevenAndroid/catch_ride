class VendorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final dynamic phone;
  final String? profilePhoto;
  final String? coverImage;
  final String businessName;
  final String serviceType;
  final String? location;
  final String? bio;
  final dynamic yearsExperience;
  final double? rating;
  final String status;
  final List<VendorServiceItem> services;
  final List<VendorAvailability> serviceAvailability;
  /// Show venues from availability that matched the explore `location` filter.
  final List<VendorMatchingVenue> matchingAvailabilityVenues;

  VendorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePhoto,
    this.coverImage,
    required this.businessName,
    required this.serviceType,
    this.location,
    this.bio,
    this.yearsExperience,
    this.rating,
    required this.status,
    this.services = const [],
    this.serviceAvailability = const [],
    this.matchingAvailabilityVenues = const [],
  });

  /// Best label for list UI when filtering by show venue / location.
  String? get displayLocation {
    if (matchingAvailabilityVenues.isNotEmpty) {
      return matchingAvailabilityVenues.first.displayLine;
    }
    return location;
  }

  /// Dates from the first availability row that matched explore filters.
  VendorAvailability? get primaryServiceAvailability =>
      serviceAvailability.isNotEmpty ? serviceAvailability.first : null;

  String get fullName => '$firstName $lastName';

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    // Handle serviceType which can be a String or a List<dynamic>
    String parsedServiceType = '';
    if (json['serviceType'] is List) {
      parsedServiceType = (json['serviceType'] as List).join(', ');
    } else {
      parsedServiceType = json['serviceType']?.toString() ?? '';
    }

    return VendorModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhoto: json['profilePhoto'] ?? json['profile'],
      coverImage: json['coverImage'] ?? json['bannerImage'],
      businessName: json['businessName'] ?? '',
      serviceType: parsedServiceType,
      location:
      (json['location'] != null && json['location'].toString().trim().isNotEmpty)
          ? json['location']
          : (json['homeBase'] is Map
          ? '${json['homeBase']['city'] ?? ''}${json['homeBase']['city'] != null && json['homeBase']['state'] != null ? ', ' : ''}${json['homeBase']['state'] ?? ''}'
          : json['homeBase']) ??
          (json['city'] != null
              ? '${json['city']}${json['state'] != null ? ', ${json['state']}' : ''}'
              : null),
      bio: json['bio'] ?? json['whyJoinOurCommunity'],
      yearsExperience: json['yearsExperience'] ?? json['experience'],
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      services: (json['services'] as List? ?? [])
          .map((e) {
            if (e is String) {
              return VendorServiceItem(name: e);
            }
            return VendorServiceItem.fromJson(e as Map<String, dynamic>);
          })
          .toList(),
      serviceAvailability: (json['serviceAvailability'] as List? ?? [])
          .map((e) => VendorAvailability.fromJson(e))
          .toList(),
      matchingAvailabilityVenues:
          (json['matchingAvailabilityVenues'] as List? ?? [])
              .map((e) => VendorMatchingVenue.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class VendorMatchingVenue {
  final String name;
  final String location;

  const VendorMatchingVenue({this.name = '', this.location = ''});

  String get displayLine {
    final n = name.trim();
    final loc = location.trim();
    if (n.isNotEmpty && loc.isNotEmpty && n != loc) return '$n, $loc';
    if (loc.isNotEmpty) return loc;
    return n;
  }

  factory VendorMatchingVenue.fromJson(Map<String, dynamic> json) {
    return VendorMatchingVenue(
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}

class VendorServiceItem {
  final String? name;
  final double? price;
  final String? duration;
  final String? description;

  VendorServiceItem({this.name, this.price, this.duration, this.description});

  factory VendorServiceItem.fromJson(Map<String, dynamic> json) {
    return VendorServiceItem(
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'],
      description: json['description'],
    );
  }
}

class VendorAvailability {
  final String? id;
  final String? serviceRegion;
  final String? startDate;
  final String? endDate;

  VendorAvailability({
    this.id,
    this.serviceRegion,
    this.startDate,
    this.endDate,
  });

  factory VendorAvailability.fromJson(Map<String, dynamic> json) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        DateTime dt = DateTime.parse(dateStr);
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      } catch (e) {
        return dateStr.split('T')[0];
      }
    }

    return VendorAvailability(
      id: json['_id'] ?? json['id'],
      serviceRegion: json['serviceRegion'],
      startDate: formatDate(json['startDate'] ?? json['specificDate']),
      endDate: formatDate(json['endDate'] ?? json['specificDate']),
    );
  }
}
