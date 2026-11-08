class GoogleSignInRequest {
  const GoogleSignInRequest({required this.idToken});

  final String idToken;

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
