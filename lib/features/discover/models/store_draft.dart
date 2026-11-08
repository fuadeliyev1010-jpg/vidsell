class StoreDraft {
  const StoreDraft({
    required this.phoneNumber,
    this.storeName = '',
    this.slogan = '',
    this.description = '',
    this.categoryNames = const [],
    this.city = '',
    this.address = '',
    this.logoPath,
    this.bannerPath,
    this.alwaysOpen = false,
    this.openDays = const [],
    this.openingTime = '00:00',
    this.closingTime = '00:00',
    this.email = '',
    this.mainPhone = '',
    this.additionalPhones = const [],
    this.shortNumber = '',
  });

  final String phoneNumber;
  final String storeName;
  final String slogan;
  final String description;
  final List<String> categoryNames;
  final String city;
  final String address;
  final String? logoPath;
  final String? bannerPath;
  final bool alwaysOpen;
  final List<String> openDays;
  final String openingTime;
  final String closingTime;
  final String email;
  final String mainPhone;
  final List<String> additionalPhones;
  final String shortNumber;

  StoreDraft copyWith({
    String? storeName,
    String? slogan,
    String? description,
    List<String>? categoryNames,
    String? city,
    String? address,
    String? logoPath,
    String? bannerPath,
    bool? alwaysOpen,
    List<String>? openDays,
    String? openingTime,
    String? closingTime,
    String? email,
    String? mainPhone,
    List<String>? additionalPhones,
    String? shortNumber,
  }) => StoreDraft(
    phoneNumber: phoneNumber,
    storeName: storeName ?? this.storeName,
    slogan: slogan ?? this.slogan,
    description: description ?? this.description,
    categoryNames: categoryNames ?? this.categoryNames,
    city: city ?? this.city,
    address: address ?? this.address,
    logoPath: logoPath ?? this.logoPath,
    bannerPath: bannerPath ?? this.bannerPath,
    alwaysOpen: alwaysOpen ?? this.alwaysOpen,
    openDays: openDays ?? this.openDays,
    openingTime: openingTime ?? this.openingTime,
    closingTime: closingTime ?? this.closingTime,
    email: email ?? this.email,
    mainPhone: mainPhone ?? this.mainPhone,
    additionalPhones: additionalPhones ?? this.additionalPhones,
    shortNumber: shortNumber ?? this.shortNumber,
  );
}
