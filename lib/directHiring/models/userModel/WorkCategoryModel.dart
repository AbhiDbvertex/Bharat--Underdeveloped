class WorkCategoryModel {
  final String id;
  final String name;
  final String image;
  final String? subtitle;

  WorkCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.subtitle,
  });

  factory WorkCategoryModel.fromJson(Map<String, dynamic> json) {
    return WorkCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }
}
