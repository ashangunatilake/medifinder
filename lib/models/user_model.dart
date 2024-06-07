

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;

  const UserModel ({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
  });

  static UserModel empty() => const UserModel(id: '', name: '', email: '', mobile: '');

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        name: data['Name'] ?? '',
        email: data['Email'] ?? '',
        mobile: data['Mobile'] ?? '',
      );
    }
    else {
      return UserModel.empty();
    }
  }
  UserModel.fromJson(String userID, Map<String, Object?> json)
      : this(
    id: userID,
    name: json['Name']?.toString() ?? '',
    email: json['Email']?.toString() ?? '',
    mobile: json['Mobile']?.toString() ?? '',
  );

  // create a new instance of UserModel with modified/updated properties
  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
  }) {
    return UserModel(id: this.id, name: name ?? this.name, email: email ?? this.email, mobile: mobile ?? this.mobile,);
  }

  // create a json object of a UserModel instance
  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Email': email,
      'Mobile': mobile,
    };
  }
}


