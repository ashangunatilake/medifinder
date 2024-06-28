

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final List<String> tokens;

  const UserModel ({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.tokens = const [],
  });

  static UserModel empty() => const UserModel(id: '', name: '', email: '', mobile: '', tokens: []);

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        name: data['Name'] ?? '',
        email: data['Email'] ?? '',
        mobile: data['Mobile'] ?? '',
        tokens: List<String>.from(data['FCMTokens'] ?? []),
      );
    }
    else {
      return UserModel.empty();
    }
  }
  ///////////////////////////////////////////////////////////////////////////////
  UserModel.fromJson(String userID, Map<String, Object?> json)
      : this(
    id: userID,
    name: json['Name']?.toString() ?? '',
    email: json['Email']?.toString() ?? '',
    mobile: json['Mobile']?.toString() ?? '',
    tokens: (json['FCMTokens'] as List<dynamic>?)?.map((token) => token.toString()).toList() ?? [],
  );
  ///////////////////////////////////////////////////////////////////////////////

  // create a new instance of UserModel with modified/updated properties
  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
  }) {
    return UserModel(id: id, name: name ?? this.name, email: email ?? this.email, mobile: mobile ?? this.mobile, tokens: tokens);
  }

  // create a json object of a UserModel instance
  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Email': email,
      'Mobile': mobile,
      'FCMTokens': tokens,
    };
  }
}


