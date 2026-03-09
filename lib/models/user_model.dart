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
    this.bio,
    this.barnName,
    this.yearsExperience = 0,
    this.programTags = const [],
    this.showCircuits = const [],
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
    return UserModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      photo: json['photo'],
      coverImage: json['coverImage'],
      phone: json['phone'],
      location: json['location'],
      bio: json['bio'],
      barnName: json['barnName'],
      yearsExperience: json['yearsExperience'] ?? 0,
      programTags: List<String>.from(json['programTags'] ?? []),
      showCircuits: List<String>.from(json['showCircuits'] ?? []),
      facebook: json['facebook'],
      instagram: json['instagram'],
      website: json['website'],
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isProfileSetup: json['isProfileSetup'] ?? false,
      isProfileApprove: json['isProfileApprove'] ?? false,
      trainerProfileId: json['trainerId'] is Map 
          ? json['trainerId']['_id'] 
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
      'bio': bio,
      'barnName': barnName,
      'yearsExperience': yearsExperience,
      'programTags': programTags,
      'showCircuits': showCircuits,
      'facebook': facebook,
      'instagram': instagram,
      'website': website,
      'isProfileCompleted': isProfileCompleted,
      'isProfileSetup': isProfileSetup,
      'isProfileApprove': isProfileApprove,
    };
  }
}
