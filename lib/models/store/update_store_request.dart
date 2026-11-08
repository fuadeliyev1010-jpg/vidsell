class UpdateStoreRequest {
  const UpdateStoreRequest({
    this.name,
    this.category,
    this.logoUrl,
    this.description,
    this.phone,
    this.workingHours,
  });

  final String? name;
  final String? category;
  final String? logoUrl;
  final String? description;
  final String? phone;
  final String? workingHours;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (category != null) 'category': category,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (description != null) 'description': description,
    if (phone != null) 'phone': phone,
    if (workingHours != null) 'workingHours': workingHours,
  };
}
