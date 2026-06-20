class ServiceModel {
  final String name;
  final String image;
  final String category;
  final String shopAddress;

  ServiceModel({
    required this.name,
    required this.image,
    required this.category,
    required this.shopAddress,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      shopAddress: json['shopAddress'] ?? '',
    );
  }
}