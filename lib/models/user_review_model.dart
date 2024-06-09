import 'package:cloud_firestore/cloud_firestore.dart';

class UserReview {
  final String id;
  final double rating;
  final String comment;
  final DateTime datetime;

  const UserReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.datetime,
  });

  static UserReview empty() => UserReview(id: '', rating: 0, comment: '', datetime: DateTime.now());

  factory UserReview.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if(document.data() != null) {
      final data = document.data()!;
      return UserReview(
        id: document.id,
        rating: data['Rating'] is int ? (data['Rating'] as int).toDouble() : data['Rating'] ?? 0,
        comment: data['Comment'] ?? '',
        datetime: data['DateTime'] ?? DateTime.now(),
      );
    }
    else {
      return UserReview.empty();
    }
  }
  UserReview.fromJson(String userID, Map<String, Object?> json)
    :this(
      id: userID,
      rating: json['Rating'] is int ? (json['Rating'] as int).toDouble() : json['Rating'] as double,
      comment: json['Comment']! as String,
      datetime: json['DateTime']! as DateTime,
    );

  UserReview copyWith({
    double? rating,
    String? comment,
    DateTime? datetime,

  }) {
    return UserReview(id: this.id, rating: rating ?? this.rating, comment: comment ?? this.comment, datetime: datetime ?? this.datetime);
  }

  Map<String, Object?> toJson() {
    return {
      'Rating': rating,
      'Comment': comment,
      'DateTime': datetime,
    };
  }
}