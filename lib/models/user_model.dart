enum UserRole { admin, doctor, patient }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedCreatedAt;
    final rawDate = map['createdAt'];
    if (rawDate is String) {
      parsedCreatedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate != null && rawDate.runtimeType.toString().contains('Timestamp')) {
      parsedCreatedAt = (rawDate as dynamic).toDate();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.patient,
      ),
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      createdAt: parsedCreatedAt,
    );
  }
}
