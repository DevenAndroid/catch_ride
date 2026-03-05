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
  final String? discipline;
  final List<TagModel> programTags;
  final TagModel? experienceLevel;
  final List<TagModel> opportunityTags;
  final List<TagModel> personalityTags;
  final String? description;
  final String? photo;
  final List<String> images;
  final double? price;
  final String status;
  final String? trainerId;
  final String? trainerName;
  final String? trainerAvatar;
  final String? location;
  final String? bookedByAvatar;
  final String? bookedByName;
  final String? bookedByLocation;
  final String? bookingDates;
  
  String get displayDiscipline {
    if (discipline != null && discipline!.isNotEmpty) return discipline!;
    if (programTags.isNotEmpty) return programTags.first.name;
    return 'General';
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
    this.discipline,
    this.programTags = const [],
    this.experienceLevel,
    this.opportunityTags = const [],
    this.personalityTags = const [],
    this.description,
    this.photo,
    this.images = const [],
    this.price,
    this.status = 'pending',
    this.trainerId,
    this.trainerName,
    this.trainerAvatar,
    this.location,
    this.bookedByAvatar,
    this.bookedByName,
    this.bookedByLocation,
    this.bookingDates,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested trainer object if it exists
    String? tId;
    String? tName;
    String? tAvatar;
    
    if (json['trainerId'] is Map) {
      tId = json['trainerId']['_id'];
      tName = "${json['trainerId']['firstName'] ?? ''} ${json['trainerId']['lastName'] ?? ''}".trim();
      tAvatar = json['trainerId']['avatar'];
    } else {
      tId = json['trainerId'];
      tName = json['trainerName'];
      tAvatar = json['trainerAvatar'];
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
      showAvailability: (json['showAvailability'] as List?)
              ?.map((e) => AvailabilityModel.fromJson(e))
              .toList() ??
          [],
      discipline: json['discipline'],
      programTags: (json['programTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      experienceLevel: json['experienceLevel'] != null
          ? TagModel.fromJson(json['experienceLevel'])
          : null,
      opportunityTags: (json['opportunityTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      personalityTags: (json['personalityTags'] as List?)
              ?.map((e) => TagModel.fromJson(e))
              .toList() ??
          [],
      description: json['description'],
      photo: json['photo'],
      images: List<String>.from(json['images'] ?? []),
      price: json['price'] is num ? (json['price'] as num).toDouble() : null,
      status: json['status'] ?? 'pending',
      trainerId: tId,
      trainerName: tName,
      trainerAvatar: tAvatar,
      location: json['location'],
      bookedByAvatar: json['bookedByAvatar'],
      bookedByName: json['bookedByName'],
      bookedByLocation: json['bookedByLocation'],
      bookingDates: json['bookingDates'],
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
      'discipline': discipline,
      'programTags': programTags.map((e) => e.toJson()).toList(),
      if (experienceLevel != null) 'experienceLevel': experienceLevel!.toJson(),
      'opportunityTags': opportunityTags.map((e) => e.toJson()).toList(),
      'personalityTags': personalityTags.map((e) => e.toJson()).toList(),
      'description': description,
      'photo': photo,
      'images': images,
      'price': price,
      'status': status,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'location': location,
    };
  }
}
