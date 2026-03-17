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
  final List<String> horseShows;
  final String? facebook;
  final String? instagram;
  final String? website;
  final bool isProfileCompleted;
  final bool isProfileSetup;
  final bool isProfileApprove;
  final bool pushNotificationsEnabled;
  final bool twoFactorEnabled;
  final String status;
  final List<String> tags;
  final String? trainerProfileId;
  final BarnManager? linkedBarnManager;
  final TrainerLinkedModel? linkedTrainer;
  final String? yearsInIndustry;

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
    this.horseShows = const [],
    this.tags = const [],
    this.facebook,
    this.instagram,
    this.website,
    this.isProfileCompleted = false,
    this.isProfileSetup = false,
    this.isProfileApprove = false,
    this.pushNotificationsEnabled = true,
    this.twoFactorEnabled = false,
    this.status = 'active',
    this.trainerProfileId,
    this.linkedBarnManager,
    this.linkedTrainer,
    this.yearsInIndustry,
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

    dynamic horseShowsList = json['horseShows'] ?? (json['trainerId'] is Map ? json['trainerId']['horseShows'] : []);
    List<String> parsedHorseShows = [];
    if (horseShowsList is List) {
      for (var h in horseShowsList) {
        if (h is Map) {
          parsedHorseShows.add(h['_id'] ?? h['id'] ?? '');
        } else if (h is String) {
          parsedHorseShows.add(h);
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
      barnName: json['barnName'] ?? trainerData?['barnName'] ?? json['barnManagerId']?['barnName'],
      yearsExperience: json['yearsExperience'] ?? trainerData?['yearsExperience'] ?? 0,
      yearsInIndustry: json['yearsInIndustry'] ?? json['barnManagerId']?['yearsInIndustry'],
      programTags: List<String>.from(json['programTags'] ?? trainerData?['programTags'] ?? []),
      showCircuits: List<String>.from(json['showCircuits'] ?? trainerData?['showCircuits'] ?? []),
      horseShows: parsedHorseShows,
      tags: parsedTags,
      facebook: json['facebook'] ?? trainerData?['facebook'],
      instagram: json['instagram'] ?? trainerData?['instagram'],
      website: json['website'] ?? trainerData?['website'],
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isProfileSetup: json['isProfileSetup'] ?? false,
      isProfileApprove: json['isProfileApprove'] ?? false,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      status: json['status'] ?? 'active',
      trainerProfileId: trainerData != null 
          ? trainerData['_id'] 
          : json['trainerId'],
      linkedBarnManager: trainerData != null && trainerData['linkedBarnManager'] != null
          ? BarnManager.fromJson(trainerData['linkedBarnManager'])
          : null,
      linkedTrainer: json['role'] == 'barn_manager' && json['trainerId'] is Map
          ? TrainerLinkedModel.fromJson(json['trainerId'])
          : null,
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
      'horseShows': horseShows,
      'tags': tags,
      'facebook': facebook,
      'instagram': instagram,
      'website': website,
      'isProfileCompleted': isProfileCompleted,
      'isProfileSetup': isProfileSetup,
      'isProfileApprove': isProfileApprove,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'twoFactorEnabled': twoFactorEnabled,
      'status': status,
      if (linkedBarnManager != null) 'linkedBarnManager': linkedBarnManager!.toJson(),
      if (linkedTrainer != null) 'linkedTrainer': linkedTrainer!.toJson(),
    };
  }
}

class TrainerLinkedModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? avatar;
  final String? bio;
  final String? barnName;
  final String? location;

  TrainerLinkedModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.avatar,
    this.bio,
    this.barnName,
    this.location,
  });

  String get fullName => (firstName != null && lastName != null) 
      ? '$firstName $lastName'.trim() 
      : firstName ?? lastName ?? email;

  factory TrainerLinkedModel.fromJson(Map<String, dynamic> json) {
    return TrainerLinkedModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      avatar: json['profilePhoto'] ?? json['avatar'],
      bio: json['bio'],
      barnName: json['barnName'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePhoto': avatar,
      'bio': bio,
      'barnName': barnName,
      'location': location,
    };
  }
}

class BarnManager {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? avatar;
  final String? bio;
  final String status;

  BarnManager({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.avatar,
    this.bio,
    this.status = 'pending',
  });

  String get fullName => (firstName != null && lastName != null) 
      ? '$firstName $lastName'.trim() 
      : firstName ?? lastName ?? email;

  factory BarnManager.fromJson(Map<String, dynamic> json) {
    return BarnManager(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      avatar: json['profilePhoto'] ?? json['avatar'],
      bio: json['bio'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePhoto': avatar,
      'bio': bio,
      'status': status,
    };
  }
}
