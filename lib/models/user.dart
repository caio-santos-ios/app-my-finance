class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photo;
  final bool admin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
    required this.admin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photo: json['photo'] ?? '',
      admin: json['admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'admin': admin,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    bool? admin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      admin: admin ?? this.admin,
    );
  }
}
