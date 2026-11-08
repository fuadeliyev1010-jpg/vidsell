class StoreApplicationRequest {
  const StoreApplicationRequest({
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.workingHours,
  });

  final String name;
  final String category;
  final String description;
  final String phone;
  final String workingHours;

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'description': description,
    'phone': phone,
    'workingHours': workingHours,
  };

  factory StoreApplicationRequest.fromJson(Map<String, dynamic> json) =>
      StoreApplicationRequest(
        name: '${json['name'] ?? json['storeName'] ?? ''}',
        category: '${json['category'] ?? json['categoryName'] ?? ''}',
        description: '${json['description'] ?? ''}',
        phone: '${json['phone'] ?? json['phoneNumber'] ?? ''}',
        workingHours: '${json['workingHours'] ?? ''}',
      );
}
