import 'tag_model.dart';
import 'availability_model.dart';

class HorseModel {
  final String? id;
  final String name;
  final String breed;
  final int age;
  final String? color;
  final String gender;
  final String? height;
  final String? listingTitle;
  final String? videoLink;
  final String? usefNumber;
  final List<String> listingTypes;
  final List<AvailabilityModel> showAvailability;
  final List<String> disciplines;
  final List<TagModel> programTags;
  final TagModel? experienceLevel;
  final List<TagModel> opportunityTags;
  final List<TagModel> personalityTags;
  final List<TagModel> tags;
  final String? description;
  final String? photo;
  final List<String> images;
  final double? price;
  final Map<String, dynamic>? prices;
  final String status;
  final bool isActive;
  final String? trainerId;
  final String? trainerName;
  final String? trainerAvatar;
  final String? ownerId;
  final String? location;
  final String? bookedById;
  final String? bookedByName;
  final String? bookedByAvatar;
  final String? bookedByLocation;
  final String? bookingDates;
  final DateTime? createdAt;

  String get displayDiscipline {
    if (disciplines.isNotEmpty) return disciplines.join(', ');
    if (programTags.isNotEmpty) return programTags.first.name;
    return 'N/A';
  }

  HorseModel({
    this.id,
    required this.name,
    required this.breed,
    required this.age,
    this.color,
    required this.gender,
    this.height,
    this.listingTitle,
    this.videoLink,
    this.usefNumber,
    this.listingTypes = const [],
    this.showAvailability = const [],
    this.disciplines = const [],
    this.programTags = const [],
    this.experienceLevel,
    this.opportunityTags = const [],
    this.personalityTags = const [],
    this.tags = const [],
    this.description,
    this.photo,
    this.images = const [],
    this.price,
    this.prices,
    this.status = 'pending',
    this.isActive = true,
    this.trainerId,
    this.trainerName,
    this.trainerAvatar,
    this.ownerId,
    this.location,
    this.bookedById,
    this.bookedByName,
    this.bookedByAvatar,
    this.bookedByLocation,
    this.bookingDates,
    this.createdAt,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested trainer object if it exists
    String? tId;
    String? tName;
    String? tAvatar;

    final trainerObj = (json['trainerId'] is Map)
        ? json['trainerId']
        : (json['trainer'] is Map ? json['trainer'] : null);

    if (trainerObj != null) {
      tId = trainerObj['_id'] ?? trainerObj['id'];
      tName =
          "${trainerObj['firstName'] ?? trainerObj['first_name'] ?? ''} ${trainerObj['lastName'] ?? trainerObj['last_name'] ?? ''}"
              .trim();
      tAvatar =
          trainerObj['profilePhoto'] ??
          trainerObj['profile_photo'] ??
          trainerObj['avatar'] ??
          trainerObj['photo'] ??
          trainerObj['profilePic'] ??
          trainerObj['profile_pic'] ??
          trainerObj['profilePicture'] ??
          trainerObj['profile_picture'] ??
          trainerObj['image'] ??
          trainerObj['avatarUrl'] ??
          trainerObj['profileImageUrl'] ??
          trainerObj['user_avatar'] ??
          trainerObj['user_photo'] ??
          trainerObj['userAvatar'] ??
          trainerObj['userPhoto'];
    } else {
      tId = json['trainerId'];
      tName = json['trainerName'] ?? json['trainer_name'];
      tAvatar =
          json['trainerAvatar'] ??
          json['trainerProfilePhoto'] ??
          json['trainer_profile_photo'] ??
          json['trainerPhoto'] ??
          json['trainerProfilePic'] ??
          json['trainer_profile_pic'] ??
          json['trainerImage'] ??
          json['trainerAvatarUrl'] ??
          json['trainerProfileImageUrl'] ??
          json['trainer_avatar'] ??
          json['trainer_photo'] ??
          json['trainer_profile_picture'] ??
          json['trainerProfilePicture'];
    }

    // Handle nested bookedBy object if it exists
    String? bId;
    String? bName;
    String? bAvatar;
    String? bLocation;

    final bObj = (json['bookedBy'] is Map)
        ? json['bookedBy']
        : (json['booked_by'] is Map ? json['booked_by'] : null);

    if (bObj != null) {
      final bData = bObj as Map<String, dynamic>;
      bId = bData['_id'] ?? bData['id'];
      bName =
          "${bData['firstName'] ?? bData['first_name'] ?? ''} ${bData['lastName'] ?? bData['last_name'] ?? ''}"
              .trim();
      bAvatar =
          bData['profilePhoto'] ??
          bData['profile_photo'] ??
          bData['avatar'] ??
          bData['photo'] ??
          bData['profilePic'] ??
          bData['profile_pic'] ??
          bData['profilePicture'] ??
          bData['profile_picture'] ??
          bData['image'] ??
          bData['avatarUrl'] ??
          bData['profileImageUrl'] ??
          bData['user_avatar'] ??
          bData['user_photo'] ??
          bData['userAvatar'] ??
          bData['userPhoto'];
      bLocation = bData['location'];
    } else {
      bId = json['bookedById'] ?? json['booked_by_id'];
      bName = json['bookedByName'] ?? json['booked_by_name'];
      bAvatar =
          json['bookedByAvatar'] ??
          json['bookedByProfilePhoto'] ??
          json['bookedBy_profile_photo'] ??
          json['bookedByPhoto'] ??
          json['bookedByProfilePic'] ??
          json['bookedBy_profile_pic'] ??
          json['bookedByImage'] ??
          json['bookedByAvatarUrl'] ??
          json['bookedByProfileImageUrl'] ??
          json['booked_by_avatar'] ??
          json['bookedBy_avatar'] ??
          json['booked_by_photo'] ??
          json['booked_by_profile_photo'];
      bLocation = json['bookedByLocation'] ?? json['booked_by_location'];
    }

    return HorseModel(
      id: json['_id'],
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age'] is num ? (json['age'] as num).toInt() : 0,
      color: json['color'],
      gender: json['gender'] ?? 'Other',
      height: json['height'],
      listingTitle: json['listingTitle'],
      videoLink: json['videoLink'],
      usefNumber: json['usefNumber'],
      listingTypes: List<String>.from(json['listingTypes'] ?? []),
      showAvailability:
          (json['showAvailability'] as List?)
              ?.map((e) => AvailabilityModel.fromJson(e))
              .toList() ??
          [],
      disciplines: json['discipline'] is String
          ? [json['discipline'] as String]
          : List<String>.from(json['discipline'] ?? []),
      programTags:
          (json['programTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      experienceLevel: json['experienceLevel'] != null
          ? TagModel.fromJson(json['experienceLevel'])
          : null,
      opportunityTags:
          (json['opportunityTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      personalityTags:
          (json['personalityTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      tags:
          (json['tags'] as List?)?.map((e) => TagModel.fromJson(e)).toList() ??
          [],
      description: json['description'],
      photo: json['photo'],
      images: List<String>.from(json['images'] ?? []),
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      prices: json['prices'] is Map<String, dynamic> ? json['prices'] : null,
      status: json['status'] ?? 'pending',
      isActive: json['isActive'] ?? true,
      trainerId: tId,
      trainerName: tName,
      trainerAvatar: tAvatar,
      ownerId: json['ownerId'],
      location: json['location'],
      bookedByAvatar: bAvatar,
      bookedByName: bName?.isEmpty == true ? null : bName,
      bookedByLocation: bLocation,
      bookingDates: json['bookingDates'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'color': color,
      'gender': gender,
      'height': height,
      'listingTitle': listingTitle,
      'videoLink': videoLink,
      'usefNumber': usefNumber,
      'listingTypes': listingTypes,
      'showAvailability': showAvailability.map((e) => e.toJson()).toList(),
      'discipline': disciplines,
      'programTags': programTags.map((e) => e.toJson()).toList(),
      if (experienceLevel != null) 'experienceLevel': experienceLevel!.toJson(),
      'opportunityTags': opportunityTags.map((e) => e.toJson()).toList(),
      'personalityTags': personalityTags.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'description': description,
      'photo': photo,
      'images': images,
      'price': price,
      'prices': prices,
      'status': status,
      'isActive': isActive,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'ownerId': ownerId,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  HorseModel copyWith({
    String? id,
    String? name,
    String? breed,
    int? age,
    String? color,
    String? gender,
    String? height,
    String? listingTitle,
    String? videoLink,
    String? usefNumber,
    List<String>? listingTypes,
    List<AvailabilityModel>? showAvailability,
    List<String>? disciplines,
    List<TagModel>? programTags,
    TagModel? experienceLevel,
    List<TagModel>? opportunityTags,
    List<TagModel>? personalityTags,
    List<TagModel>? tags,
    String? description,
    String? photo,
    List<String>? images,
    double? price,
    Map<String, dynamic>? prices,
    String? status,
    bool? isActive,
    String? trainerId,
    String? trainerName,
    String? trainerAvatar,
    String? ownerId,
    String? location,
    String? bookedById,
    String? bookedByName,
    String? bookedByAvatar,
    String? bookedByLocation,
    String? bookingDates,
    DateTime? createdAt,
  }) {
    return HorseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      color: color ?? this.color,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      listingTitle: listingTitle ?? this.listingTitle,
      videoLink: videoLink ?? this.videoLink,
      usefNumber: usefNumber ?? this.usefNumber,
      listingTypes: listingTypes ?? this.listingTypes,
      showAvailability: showAvailability ?? this.showAvailability,
      disciplines: disciplines ?? this.disciplines,
      programTags: programTags ?? this.programTags,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      opportunityTags: opportunityTags ?? this.opportunityTags,
      personalityTags: personalityTags ?? this.personalityTags,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      images: images ?? this.images,
      price: price ?? this.price,
      prices: prices ?? this.prices,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      trainerAvatar: trainerAvatar ?? this.trainerAvatar,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      bookedById: bookedById ?? this.bookedById,
      bookedByName: bookedByName ?? this.bookedByName,
      bookedByAvatar: bookedByAvatar ?? this.bookedByAvatar,
      bookedByLocation: bookedByLocation ?? this.bookedByLocation,
      bookingDates: bookingDates ?? this.bookingDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
