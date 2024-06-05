import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import '../models/user_order_model.dart';
import '../models/user_review_model.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

const String PHARMACIES_COLLECTION_REFERENCE = 'Pharmacies';

class DatabaseServices {
  final firestore = FirebaseFirestore.instance;

  late final CollectionReference _pharmaciesRef;

  DatabaseServices() {
    ///// _firestore -> firestore
    _pharmaciesRef = firestore.collection(PHARMACIES_COLLECTION_REFERENCE).withConverter<PharmacyModel>(
        fromFirestore: (snapshots, _) => PharmacyModel.fromSnapshot(
          snapshots,),
        toFirestore: (pharmacy, _) =>pharmacy.toJson());
  }

  Future<String?> getCurrentPharmacyUid() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid; // Return the UID if user is not null
      } else {
        return null; // Return null if no user is logged in
      }
    } catch (e) {
      print('Error getting current pharmacy UID: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getPharmacies() {
    return _pharmaciesRef.snapshots();
  }

  void addPharmacy(String pharmacyID, PharmacyModel pharmacy) async {
    await _pharmaciesRef.doc(pharmacyID).set(pharmacy);
  }

  void updatePharmacy(String pharmacyID, PharmacyModel pharmacy) async {
    await _pharmaciesRef.doc(pharmacyID).update(pharmacy.toJson());
  }

  void deletePharmacy(String pharmacyID) async {
    await _pharmaciesRef.doc(pharmacyID).delete();
  }

  // Stream<QuerySnapshot> getUserReviews(String userID) {
  //   return _usersRef.doc(userID).collection('Reviews').snapshots();
  // }

  // Stream<QuerySnapshot<UserReview>> getPharmacyReviews(String pharmacyID) {
  //   return _pharmaciesRef.doc(pharmacyID).collection('Reviews').withConverter<UserReview>(
  //     fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
  //     toFirestore: (review, _) => review.toJson(),
  //   ).snapshots();
  // }

  void addPharmacyReview(String pharmacyID, UserReview review) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Reviews').add(review.toJson());
  }

  void updatePharmacyReview(String pharmacyID, String reviewID, UserReview review) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).update(review.toJson());
  }

  void deletePharmacyReview(String pharmacyID, String reviewID) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).delete();
  }

  // Stream<QuerySnapshot> getUserOrders(String userID) {
  //   return _usersRef.doc(userID).collection('Orders').snapshots();
  // }

  // Stream<QuerySnapshot<UserOrder>> getUserOrders(String pharmacyID) {
  //   return _pharmaciesRef.doc(pharmacyID).collection('Orders').withConverter<UserOrder>(
  //     fromFirestore: (snapshots, _) => UserOrder.fromSnapshot(snapshots),
  //     toFirestore: (order, _) => order.toJson(),
  //   ).snapshots();
  // }

  void addUserOrder(String pharmacyID, UserOrder order) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Orders').add(order.toJson());
  }

  void updateUserOrder(String pharmacyID, String orderID, UserOrder order) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).update(order.toJson());
  }

  void deleteUserOrder(String pharmacyID, String orderID) async {
    await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).delete();
  }

  Future<List<DocumentSnapshot>> getNearbyPharmacies(LatLng userPosition, String medication) {
    final geo = GeoFlutterFire();

    GeoFirePoint center = geo.point(latitude: userPosition.latitude, longitude: userPosition.longitude);
    var collectionReference = firestore.collection('Pharmacies');
    double radius = 5.0; // radius in kilometers
    String field = 'Position';

    Stream<List<DocumentSnapshot>> nearbyPharmaciesStream = geo.collection(collectionRef: collectionReference)
                                            .within(center: center, radius: radius, field: field);

    return filterByMedication(nearbyPharmaciesStream, medication);
  }

  Future<List<DocumentSnapshot>> filterByMedication(Stream<List<DocumentSnapshot>> pharmaciesStream, String medication) async {
    List<DocumentSnapshot> filteredPharmacies = [];

    List<DocumentSnapshot> newResult = await pharmaciesStream.first;
    for (DocumentSnapshot document in newResult) {
      CollectionReference drugsCollection = document.reference.collection('Drugs');
      QuerySnapshot drugsSnapshot = await drugsCollection.where('Name', isEqualTo: medication).get();
      if (drugsSnapshot.docs.isNotEmpty) {
        filteredPharmacies.add(document);
      }
    }

    return filteredPharmacies;
  }
}