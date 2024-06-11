import 'package:cloud_firestore/cloud_firestore.dart';

class UserReview {
  final String id;
  final double rating;
  final String comment;
  final Timestamp timestamp;

  const UserReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  static UserReview empty() => UserReview(id: '', rating: 0.0, comment: '', timestamp: Timestamp.fromDate(DateTime.now()));

  factory UserReview.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return UserReview(
        id: document.id,
        rating: (data['Rating'] is int ? (data['Rating'] as int).toDouble() : data['Rating'] as double?) ?? 0.0,
        comment: data['Comment'] as String? ?? '',
        timestamp: data['DateTime'] as Timestamp? ?? Timestamp.fromDate(DateTime.now()),
      );
    } else {
      return UserReview.empty();
    }
  }

  factory UserReview.fromJson(String userID, Map<String, Object?> json) {
    return UserReview(
      id: userID,
      rating: (json['Rating'] is int ? (json['Rating'] as int).toDouble() : json['Rating'] as double?) ?? 0.0,
      comment: json['Comment'] as String? ?? '',
      timestamp: json['DateTime'] as Timestamp? ?? Timestamp.fromDate(DateTime.now()),
    );
  }

  UserReview copyWith({
    double? rating,
    String? comment,
    Timestamp? timestamp,
  }) {
    return UserReview(
      id: this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'Rating': rating,
      'Comment': comment,
      'DateTime': timestamp,
    };
  }
}
