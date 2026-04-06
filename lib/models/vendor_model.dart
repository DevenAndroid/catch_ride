class VendorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePhoto;
  final String? coverImage;
  final String businessName;
  final String serviceType;
  final String? location;
  final String? bio;
  final int? yearsExperience;
  final double? rating;
  final String status;
  final List<VendorServiceItem> services;
  final List<VendorAvailability> serviceAvailability;

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
  });

  String get fullName => '$firstName $lastName';

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhoto: json['profilePhoto'],
      coverImage: json['coverImage'],
      businessName: json['businessName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      location: json['location'] ??
                (json['homeBase'] is Map
                    ? '${json['homeBase']['city'] ?? ''}${json['homeBase']['city'] != null && json['homeBase']['state'] != null ? ', ' : ''}${json['homeBase']['state'] ?? ''}'
                    : json['homeBase']) ??
                (json['city'] != null
                    ? '${json['city']}${json['state'] != null ? ', ${json['state']}' : ''}'
                    : null),
      bio: json['bio'],
      yearsExperience: json['yearsExperience'],
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      services: (json['services'] as List? ?? [])
          .map((e) => VendorServiceItem.fromJson(e))
          .toList(),
      serviceAvailability: (json['serviceAvailability'] as List? ?? [])
          .map((e) => VendorAvailability.fromJson(e))
          .toList(),
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
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[dt.month - 1]} ${dt.day}';
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
