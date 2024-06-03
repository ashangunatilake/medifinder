import 'package:cloud_firestore/cloud_firestore.dart';

class UserReview {
  final String id;
  final double rating;
  final String comment;

  const UserReview({
    required this.id,
    required this.rating,
    required this.comment,
  });

  static UserReview empty() => const UserReview(id: '', rating: 0, comment: '');

  factory UserReview.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return UserReview(
        id: document.id,
        rating: data['Rating'] ?? 0,
        comment: data['Comment'] ?? '',
      );
    }
    else {
      return UserReview.empty();
    }
  }
  UserReview.fromJson(String userID, Map<String, Object?> json)
    :this(
      id: userID,
      rating: json['Rating']! as double,
      comment: json['Comment']! as String,
    );

  UserReview copyWith({
    double? rating,
    String? comment,

  }) {
    return UserReview(id: this.id, rating: rating ?? this.rating, comment: comment ?? this.comment);
  }

  Map<String, Object?> toJson() {
    return {
      'Rating': rating,
      'Comment': comment,
    };
  }
}