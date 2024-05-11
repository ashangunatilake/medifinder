import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/models/user_review_model.dart';

class UserModel {
  final String name;
  final String email;
  final String mobile;
  final List<UserOrder>? orders;
  final List<UserReview>? reviews;

  const UserModel ({
    required this.name,
    required this.email,
    required this.mobile,
    this.orders,
    this.reviews,
  });

  // create a UserModel instance using a json object
  factory UserModel.fromJson(Map<String, Object?> json) {
    final List<UserOrder> orders = (json['Orders'] as List<dynamic>?)
        ?.map((orderJson) => UserOrder.fromJson(orderJson))
        .toList() ?? [];
    final List<UserReview> reviews = (json['Reviews'] as List<dynamic>?)
        ?.map((reviewJson) => UserReview.fromJson(reviewJson))
        .toList() ?? [];

    return UserModel(
      name: json['Name']! as String,
      email: json['Email']! as String,
      mobile: json['Mobile']! as String,
      orders: orders,
      reviews: reviews,
    );
  }

  // create a new instance of UserModel with modified/updated properties
  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    List<UserOrder>? orders,
    List<UserReview>? reviews,

  }) {
    return UserModel(name: name ?? this.name, email: email ?? this.email, mobile: mobile ?? this.mobile, reviews: reviews ?? this.reviews, orders: orders ?? this.orders,);
  }

  // create a json object of a UserModel instance
  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Email': email,
      'Mobile': mobile,
      'Orders': orders?.map((order) => order.toJson()).toList(),
      'Reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }
}


