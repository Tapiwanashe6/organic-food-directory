import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? profilePicture;
  final bool isEmailVerified;
  final int notificationCount;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profilePicture,
    this.isEmailVerified = false,
    this.notificationCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      address: map['address'],
      profilePicture: map['profilePicture'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      notificationCount: map['notificationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
      'isEmailVerified': isEmailVerified,
      'notificationCount': notificationCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profilePicture,
    bool? isEmailVerified,
    int? notificationCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, phone, address, profilePicture, isEmailVerified, notificationCount];
}
