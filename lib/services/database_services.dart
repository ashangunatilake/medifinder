import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/models/user_review_model.dart';

import '../models/user_order_model.dart';

const String USERS_COLLECTION_REFERENCE = 'Users';

class DatabaseServices {
  final firestore = FirebaseFirestore.instance;

  late final CollectionReference _usersRef;

  DatabaseServices() {
    ///// _firestore -> firestore
    _usersRef = firestore.collection(USERS_COLLECTION_REFERENCE).withConverter<UserModel>(
        fromFirestore: (snapshots, _) => UserModel.fromJson(
          snapshots.data()!,),
        toFirestore: (user, _) =>user.toJson());
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  void addUser(UserModel user) async {
    _usersRef.add(user);
  }

  void updateUser(String userID, UserModel user) {
    _usersRef.doc(userID).update(user.toJson());
  }

  void deleteUser(String userID) {
    _usersRef.doc(userID).delete();
  }

  Stream<QuerySnapshot> getUserReviews(String userID) {
    return _usersRef.doc(userID).collection('Reviews').snapshots();
  }

  void addUserReview(String userID, UserReview review) async {
    _usersRef.doc(userID).collection('Reviews').add(review.toJson());
  }

  void updateUserReview(String userID, String reviewID, UserReview review) {
    _usersRef.doc(userID).collection('Reviews').doc(reviewID).update(review.toJson());
  }

  void deleteUserReview(String userID, String reviewID) {
    _usersRef.doc(userID).collection('Reviews').doc(reviewID).delete();
  }

  Stream<QuerySnapshot> getUserOrders(String userID) {
    return _usersRef.doc(userID).collection('Orders').snapshots();
  }

  void addUserOrder(String userID, UserOrder order) async {
    _usersRef.doc(userID).collection('Orders').add(order.toJson());
  }

  void updateUserOrder(String userID, String orderID, UserOrder order) {
    _usersRef.doc(userID).collection('Orders').doc(orderID).update(order.toJson());
  }

  void deleteUserOrder(String userID, String orderID) {
    _usersRef.doc(userID).collection('Orders').doc(orderID).delete();
  }
}