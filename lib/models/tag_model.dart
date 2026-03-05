class TagModel {
  final String? id;
  final String name;
  final String? description;
  final bool? isActive;

  TagModel({
    this.id,
    required this.name,
    this.description,
    this.isActive,
  });

  factory TagModel.fromJson(dynamic json) {
    if (json is String) {
      return TagModel(name: json);
    }
    return TagModel(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
  }

  @override
  String toString() => name;
}
