class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? avatar;
  final String? photo;
  final String? coverImage;
  final String? phone;
  final String? location;
  final String? location2;
  final String? bio;
  final String? barnName;
  final int yearsExperience;
  final List<String> programTags;
  final List<String> showCircuits;
  final String? facebook;
  final String? instagram;
  final String? website;
  final bool isProfileCompleted;
  final bool isProfileSetup;
  final bool isProfileApprove;
  final List<String> tags;
  final String? trainerProfileId;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.avatar,
    this.photo,
    this.coverImage,
    this.phone,
    this.location,
    this.location2,
    this.bio,
    this.barnName,
    this.yearsExperience = 0,
    this.programTags = const [],
    this.showCircuits = const [],
    this.tags = const [],
    this.facebook,
    this.instagram,
    this.website,
    this.isProfileCompleted = false,
    this.isProfileSetup = false,
    this.isProfileApprove = false,
    this.trainerProfileId,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayAvatar => avatar ?? photo ?? '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If tags are populated as objects, we want just the IDs
    dynamic tagsList = json['tags'] ?? (json['trainerId'] is Map ? json['trainerId']['tags'] : []);
    List<String> parsedTags = [];
    if (tagsList is List) {
      for (var t in tagsList) {
        if (t is Map) {
          parsedTags.add(t['_id'] ?? t['id'] ?? '');
        } else if (t is String) {
          parsedTags.add(t);
        }
      }
    }

    final trainerData = json['trainerId'] is Map ? json['trainerId'] as Map<String, dynamic> : null;

    return UserModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'] ?? trainerData?['profilePhoto'],
      photo: json['photo'] ?? trainerData?['profilePhoto'],
      coverImage: json['coverImage'] ?? trainerData?['coverImage'],
      phone: json['phone'] ?? trainerData?['phone'],
      location: json['location'] ?? trainerData?['location'],
      location2: json['location2'] ?? trainerData?['location2'],
      bio: json['bio'] ?? trainerData?['bio'] ?? trainerData?['description'],
      barnName: json['barnName'] ?? trainerData?['barnName'],
      yearsExperience: json['yearsExperience'] ?? trainerData?['yearsExperience'] ?? 0,
      programTags: List<String>.from(json['programTags'] ?? trainerData?['programTags'] ?? []),
      showCircuits: List<String>.from(json['showCircuits'] ?? trainerData?['showCircuits'] ?? []),
      tags: parsedTags,
      facebook: json['facebook'] ?? trainerData?['facebook'],
      instagram: json['instagram'] ?? trainerData?['instagram'],
      website: json['website'] ?? trainerData?['website'],
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isProfileSetup: json['isProfileSetup'] ?? false,
      isProfileApprove: json['isProfileApprove'] ?? false,
      trainerProfileId: trainerData != null 
          ? trainerData['_id'] 
          : json['trainerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'avatar': avatar,
      'photo': photo,
      'coverImage': coverImage,
      'phone': phone,
      'location': location,
      'location2': location2,
      'bio': bio,
      'barnName': barnName,
      'yearsExperience': yearsExperience,
      'programTags': programTags,
      'showCircuits': showCircuits,
      'tags': tags,
      'facebook': facebook,
      'instagram': instagram,
      'website': website,
      'isProfileCompleted': isProfileCompleted,
      'isProfileSetup': isProfileSetup,
      'isProfileApprove': isProfileApprove,
    };
  }
}
