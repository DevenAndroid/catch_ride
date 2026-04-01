import 'package:flutter/foundation.dart';

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
  final List<String> roles;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.roles = const [],
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
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayAvatar => avatar ?? photo ?? '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If tags are populated as objects, we want just the IDs
    dynamic tagsList =
        json['tags'] ??
        (json['trainerId'] is Map ? json['trainerId']['tags'] : []);
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

    dynamic horseShowsList =
        json['horseShows'] ??
        (json['trainerId'] is Map ? json['trainerId']['horseShows'] : []);
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

    final trainerData = json['trainerId'] is Map
        ? json['trainerId'] as Map<String, dynamic>
        : null;
    final barnManagerData = json['barnManagerId'] is Map
        ? json['barnManagerId'] as Map<String, dynamic>
        : null;
    final vendorData = json['vendorId'] is Map
        ? json['vendorId'] as Map<String, dynamic>
        : null;

    // Determine professional/fallback data based on role
    Map<String, dynamic>? proData;
    if (json['role'] == 'trainer') {
      proData = trainerData;
    } else if (json['role'] == 'barn_manager') {
      proData = barnManagerData;
    } else if (json['role'] == 'service_provider') {
      proData = vendorData;
    }

    return UserModel(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : ['user'],
      avatar: json['avatar'] ??
          (proData != null ? proData['profilePhoto'] ?? proData['avatar'] : null),
      photo: json['photo'] ??
          (proData != null ? proData['profilePhoto'] ?? proData['avatar'] : null),
      coverImage: json['coverImage'] ?? (proData != null ? proData['coverImage'] : null),
      phone: json['phone'] ?? (proData != null ? proData['phone'] : null),
      location: json['location'] ?? (proData != null ? proData['location'] : null),
      location2: json['location2'] ?? (proData != null ? proData['location2'] : null),
      bio: json['bio'] ?? (proData != null ? proData['bio'] ?? proData['description'] : null),
      barnName: json['barnName'] ??
          (proData != null ? proData['barnName'] : null) ??
          (json['role'] == 'barn_manager' && trainerData != null ? trainerData['barnName'] : null),
      yearsExperience: json['yearsExperience'] ?? (proData != null ? proData['yearsExperience'] : null) ?? 0,
      yearsInIndustry: json['yearsInIndustry'] ?? (proData != null ? proData['yearsInIndustry'] : null),
      programTags: List<String>.from(
        json['programTags'] ?? (proData != null ? proData['programTags'] : null) ?? [],
      ),
      showCircuits: List<String>.from(
        json['showCircuits'] ?? (proData != null ? proData['showCircuits'] : null) ?? [],
      ),
      horseShows: parsedHorseShows,
      tags: parsedTags,
      facebook: json['facebook'] ?? (proData != null ? proData['facebook'] : null),
      instagram: json['instagram'] ?? (proData != null ? proData['instagram'] : null),
      website: json['website'] ?? (proData != null ? proData['website'] : null),
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      isProfileSetup: json['isProfileSetup'] ?? false,
      isProfileApprove: json['isProfileApprove'] ?? false,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      status: json['status'] ?? 'active',
      trainerProfileId: trainerData != null ? trainerData['_id'] : json['trainerId'],
      linkedBarnManager:
          trainerData != null && trainerData['linkedBarnManager'] != null
          ? BarnManager.fromJson(trainerData['linkedBarnManager'])
          : null,
      linkedTrainer: json['role'] == 'barn_manager' && json['trainerId'] is Map
          ? TrainerLinkedModel.fromJson(json['trainerId'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'roles': roles,
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
      if (linkedBarnManager != null)
        'linkedBarnManager': linkedBarnManager!.toJson(),
      if (linkedTrainer != null) 'linkedTrainer': linkedTrainer!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    List<String>? roles,
    String? avatar,
    String? photo,
    String? coverImage,
    String? phone,
    String? location,
    String? location2,
    String? bio,
    String? barnName,
    int? yearsExperience,
    List<String>? programTags,
    List<String>? showCircuits,
    List<String>? horseShows,
    List<String>? tags,
    String? facebook,
    String? instagram,
    String? website,
    bool? isProfileCompleted,
    bool? isProfileSetup,
    bool? isProfileApprove,
    bool? pushNotificationsEnabled,
    bool? twoFactorEnabled,
    String? status,
    String? trainerProfileId,
    BarnManager? linkedBarnManager,
    TrainerLinkedModel? linkedTrainer,
    String? yearsInIndustry,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      avatar: avatar ?? this.avatar,
      photo: photo ?? this.photo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      location2: location2 ?? this.location2,
      bio: bio ?? this.bio,
      barnName: barnName ?? this.barnName,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      programTags: programTags ?? this.programTags,
      showCircuits: showCircuits ?? this.showCircuits,
      horseShows: horseShows ?? this.horseShows,
      tags: tags ?? this.tags,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      isProfileApprove: isProfileApprove ?? this.isProfileApprove,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      status: status ?? this.status,
      trainerProfileId: trainerProfileId ?? this.trainerProfileId,
      linkedBarnManager: linkedBarnManager ?? this.linkedBarnManager,
      linkedTrainer: linkedTrainer ?? this.linkedTrainer,
      yearsInIndustry: yearsInIndustry ?? this.yearsInIndustry,
      createdAt: createdAt ?? this.createdAt,
    );
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
  final String? location2;

  TrainerLinkedModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.avatar,
    this.bio,
    this.barnName,
    this.location,
    this.location2,
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
      location2: json['location2'],
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
      'location2': location2,
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
  final String? userId; // The User ID (not profile ID) for fetch chats
  final String status;

  BarnManager({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.avatar,
    this.bio,
    this.userId,
    this.status = 'pending',
  });

  String get fullName => (firstName != null && lastName != null)
      ? '$firstName $lastName'.trim()
      : firstName ?? lastName ?? email;

  factory BarnManager.fromJson(Map<String, dynamic> json) {
    final parsedId = json['userId'] is Map ? json['userId']['_id'] : json['userId'];
    debugPrint('DEBUG: BarnManager.fromJson - userId: $parsedId');
    return BarnManager(
      id: json['_id'] ?? json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      avatar: json['profilePhoto'] ?? json['avatar'],
      bio: json['bio'],
      userId: parsedId,
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
      'userId': userId,
      'status': status,
    };
  }
}
