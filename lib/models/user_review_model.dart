import 'package:firebase_auth/firebase_auth.dart';

class UserReview {
  final String pid;
  final double rating;
  final String comment;

  const UserReview({
    required this.pid,
    required this.rating,
    required this.comment,
  });

  UserReview.fromJson(Map<String, Object?> json)
    :this(
      pid: json['PharmacyID']! as String,
      rating: json['Rating']! as double,
      comment: json['Comment']! as String,
    );

  UserReview copyWith({
    String? pid,
    double? rating,
    String? comment,

  }) {
    return UserReview(pid: pid ?? this.pid, rating: rating ?? this.rating, comment: comment ?? this.comment);
  }

  Map<String, Object?> toJson() {
    return {
      'PharmacyID': pid,
      'Rating': rating,
      'Comment': comment,
    };
  }
}