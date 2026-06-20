class Technician {
  final String id;
  final String name;
  final String role;
  final String image;
  final String phone;
  final String shopAddress;

  Technician({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    required this.phone,
    required this.shopAddress,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      image: json['image'] ?? '',
      phone: json['phone'] ?? '',
      shopAddress: json['shopAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "role": role,
      "image": image,
      "phone": phone,
      "shopAddress": shopAddress,
    };
  }
}