import 'package:vidsell/features/new_listing/models/listing.dart';
import 'package:vidsell/models/store/store.dart';
import 'package:vidsell/models/store/my_store.dart';

class BusinessAccountDraft {
  const BusinessAccountDraft({
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
    this.isActive = true,
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
  final bool isActive;

  BusinessAccountDraft copyWith({
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
    bool? isActive,
  }) {
    return BusinessAccountDraft(
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
      isActive: isActive ?? this.isActive,
    );
  }
}

@Deprecated('Use Store for public screens and MyStore for owner screens.')
class BusinessAccount extends Store {
  const BusinessAccount({
    required super.id,
    required super.status,
    required this.storeName,
    required this.phoneNumber,
    this.logoPath,
    this.bannerPath,
    this.slogan = '',
    this.categoryNames = const [],
    this.city = '',
    this.address = '',
    this.alwaysOpen = false,
    this.openDays = const [],
    this.openingTime = '00:00',
    this.closingTime = '00:00',
    this.email = '',
    this.mainPhone = '',
    this.additionalPhones = const [],
    this.shortNumber = '',
    this.isActive = true,
    super.stats,
    super.description = '',
  }) : super(name: storeName, logoUrl: logoPath);

  factory BusinessAccount.fromJson(Map<String, dynamic> json) {
    final store = Store.fromJson(json);
    final ownStore = MyStore.fromJson(json);
    final categories = json['categoryNames'] is List
        ? (json['categoryNames'] as List).whereType<String>().toList()
        : ownStore.category.isEmpty
        ? const <String>[]
        : [ownStore.category];
    return BusinessAccount(
      id: store.id,
      stats: store.stats,
      status: ownStore.status,
      storeName: ownStore.name,
      phoneNumber: ownStore.phone,
      logoPath: ownStore.logoUrl,
      bannerPath: json['bannerPath'] as String?,
      slogan: '${json['slogan'] ?? ''}',
      description: ownStore.description,
      categoryNames: categories,
      city: '${json['city'] ?? ''}',
      address: '${json['address'] ?? ''}',
      alwaysOpen: json['alwaysOpen'] as bool? ?? false,
      openDays: json['openDays'] is List
          ? (json['openDays'] as List).whereType<String>().toList()
          : const [],
      openingTime: '${json['openingTime'] ?? '00:00'}',
      closingTime: '${json['closingTime'] ?? '00:00'}',
      email: '${json['email'] ?? ''}',
      mainPhone: '${json['mainPhone'] ?? ownStore.phone}',
      additionalPhones: json['additionalPhones'] is List
          ? (json['additionalPhones'] as List).whereType<String>().toList()
          : const [],
      shortNumber: '${json['shortNumber'] ?? ''}',
      isActive: ownStore.status == 'ACTIVE',
    );
  }

  final String storeName;
  final String phoneNumber;
  final String? logoPath;
  final String? bannerPath;
  final String slogan;
  final List<String> categoryNames;
  final String city;
  final String address;
  final bool alwaysOpen;
  final List<String> openDays;
  final String openingTime;
  final String closingTime;
  final String email;
  final String mainPhone;
  final List<String> additionalPhones;
  final String shortNumber;
  final bool isActive;
}

class BusinessListing {
  const BusinessListing({
    required this.id,
    required this.title,
    required this.status,
    required this.views,
    required this.inquiries,
  });

  final String id;
  final String title;
  final ListingStatus status;
  final int views;
  final int inquiries;

  factory BusinessListing.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    if (id.isEmpty) throw StateError('Business listing response has no ID.');
    final rawStatus = json['status']?.toString().trim() ?? '';
    if (rawStatus.isEmpty) {
      throw StateError('Business listing response has no status.');
    }
    return BusinessListing(
      id: id,
      title: json['title'] as String? ?? '',
      status: ListingStatus.parse(rawStatus),
      views: (json['views'] as num?)?.toInt() ?? 0,
      inquiries: (json['inquiries'] as num?)?.toInt() ?? 0,
    );
  }
}

class BusinessAnalytics {
  const BusinessAnalytics({
    required this.views,
    required this.inquiries,
    required this.favorites,
    required this.period,
    this.searches = 0,
    this.messages = 0,
    this.viewsByDay = const [],
    this.searchesByDay = const [],
    this.messagesByDay = const [],
  });

  final int views;
  final int inquiries;
  final int favorites;
  final String period;
  final int searches;
  final int messages;
  final List<int> viewsByDay;
  final List<int> searchesByDay;
  final List<int> messagesByDay;

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) =>
      BusinessAnalytics(
        views: (json['views'] as num?)?.toInt() ?? 0,
        inquiries: (json['inquiries'] as num?)?.toInt() ?? 0,
        favorites: (json['favorites'] as num?)?.toInt() ?? 0,
        period: json['period'] as String? ?? '30d',
        searches: (json['searches'] as num?)?.toInt() ?? 0,
        messages: (json['messages'] as num?)?.toInt() ?? 0,
        viewsByDay: _parseDailyValues(json['viewsByDay']),
        searchesByDay: _parseDailyValues(json['searchesByDay']),
        messagesByDay: _parseDailyValues(json['messagesByDay']),
      );

  static List<int> _parseDailyValues(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item is num ? item.toInt() : 0).toList();
  }
}

class BusinessVerification {
  const BusinessVerification({
    required this.status,
    required this.submittedAt,
    this.reason,
  });

  final String status;
  final DateTime submittedAt;
  final String? reason;

  factory BusinessVerification.fromJson(Map<String, dynamic> json) =>
      BusinessVerification(
        status: json['status'] as String? ?? 'pending',
        submittedAt:
            DateTime.tryParse(json['submittedAt'] as String? ?? '') ??
            DateTime.now(),
        reason: json['reason'] as String?,
      );
}
