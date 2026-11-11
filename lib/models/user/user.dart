import 'package:equatable/equatable.dart';
import '../../core/network/media_url.dart';
import '../enums/gender.dart';
import '../enums/role.dart';

class User extends Equatable {
  const User({
    required this.id,
    String? fullName,
    String? countryCode,
    String? phoneNumber,
    this.avatarUrl,
    this.gender,
    this.role,
    this.createdAt,
    this.identifier = '',
    this.email = '',
    this.about = '',
    this.phoneVerified = false,
    this.emailVerified = false,
    String? name,
    String? phone,
  }) : fullName = fullName ?? name ?? '',
       countryCode = countryCode ?? '',
       phoneNumber = phoneNumber ?? phone ?? '';

  final String id;
  final String fullName;
  final String countryCode;
  final String phoneNumber;
  final String? avatarUrl;
  final Gender? gender;
  final Role? role;
  final DateTime? createdAt;
  final String identifier;
  final String email;
  final String about;
  final bool phoneVerified;
  final bool emailVerified;

  String get name => fullName;
  String get phone => phoneNumber;

  User copyWith({
    String? id,
    String? fullName,
    String? countryCode,
    String? phoneNumber,
    String? identifier,
    String? name,
    String? email,
    String? about,
    String? avatarUrl,
    bool clearAvatar = false,
    Gender? gender,
    Role? role,
    DateTime? createdAt,
    bool? phoneVerified,
    bool? emailVerified,
  }) => User(
    id: id ?? this.id,
    fullName: fullName ?? name ?? this.fullName,
    countryCode: countryCode ?? this.countryCode,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    identifier: identifier ?? this.identifier,
    email: email ?? this.email,
    about: about ?? this.about,
    avatarUrl: clearAvatar ? null : avatarUrl ?? this.avatarUrl,
    gender: gender ?? this.gender,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    phoneVerified: phoneVerified ?? this.phoneVerified,
    emailVerified: emailVerified ?? this.emailVerified,
  );

  factory User.fromJson(
    Map<String, dynamic> json, {
    String? mediaOrigin,
  }) => User(
    id: '${json['id'] ?? ''}',
    fullName: '${json['fullName'] ?? json['name'] ?? ''}',
    countryCode: '${json['countryCode'] ?? ''}',
    phoneNumber: '${json['phoneNumber'] ?? json['phone'] ?? ''}',
    avatarUrl: mediaOrigin == null
        ? json['avatarUrl'] as String?
        : resolveMediaUrl(json['avatarUrl'] as String?, origin: mediaOrigin),
    gender: json['gender'] == null
        ? null
        : Gender.fromCode(json['gender'] as String?),
    role: json['role'] == null ? null : Role.fromCode(json['role'] as String?),
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    identifier: '${json['identifier'] ?? ''}',
    email: '${json['email'] ?? ''}',
    about: '${json['about'] ?? ''}',
    phoneVerified: json['phoneVerified'] == true,
    emailVerified: json['emailVerified'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (gender != null) 'gender': gender!.code,
    if (role != null) 'role': role!.code,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'identifier': identifier,
    'email': email,
    'about': about,
    'phoneVerified': phoneVerified,
    'emailVerified': emailVerified,
  };

  @override
  List<Object?> get props => [
    id,
    fullName,
    countryCode,
    phoneNumber,
    avatarUrl,
    gender,
    role,
    createdAt,
    identifier,
    email,
    about,
    phoneVerified,
    emailVerified,
  ];
}
