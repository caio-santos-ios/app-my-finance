class AuthLogin {
  final String token;
  final String refreshToken;
  final String photo;
  final String name;

  AuthLogin({
    required this.token,
    required this.refreshToken,
    required this.photo,
    required this.name,
  });

  factory AuthLogin.fromJson(Map<String, dynamic> json) {
    return AuthLogin(
      token: json['token'],
      // refreshToken: json['refreshToken'],
      refreshToken: "",
      photo: json['photo'],
      name: json['name'],
    );
  }
}
