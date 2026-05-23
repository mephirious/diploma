class UserModelSimple {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;

  UserModelSimple({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
  });

  UserModelSimple copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatar,
  }) {
    return UserModelSimple(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
    );
  }

  factory UserModelSimple.fromJson(Map<String, dynamic> json) {
    return UserModelSimple(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
