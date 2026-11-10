import 'package:vidsell/models/store/store_application_request.dart';

class UpdateStoreRequest {
  const UpdateStoreRequest({
    this.name,
    this.category,
    this.slogan,
    this.logoUrl,
    this.bannerUrl,
    this.description,
    this.open24Hours,
    this.workingHours,
    this.latitude,
    this.longitude,
  });

  final String? name;
  final String? category;
  final String? slogan;
  final String? logoUrl;
  final String? bannerUrl;
  final String? description;
  final bool? open24Hours;
  final List<StoreWorkingHour>? workingHours;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (category != null) 'category': category,
    if (slogan != null) 'slogan': slogan,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (bannerUrl != null) 'bannerUrl': bannerUrl,
    if (description != null) 'description': description,
    if (open24Hours != null) 'open24Hours': open24Hours,
    if (workingHours != null)
      'workingHours': workingHours!.map((hour) => hour.toJson()).toList(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}
