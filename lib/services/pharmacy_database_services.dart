import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import '../models/drugs_model.dart';
import '../models/user_order_model.dart';
import '../models/user_review_model.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

const String PHARMACIES_COLLECTION_REFERENCE = 'Pharmacies';

class PharmacyDatabaseServices {
  final firestore = FirebaseFirestore.instance;

  late final CollectionReference _pharmaciesRef;

  PharmacyDatabaseServices() {
    ///// _firestore -> firestore
    _pharmaciesRef = firestore.collection(PHARMACIES_COLLECTION_REFERENCE).withConverter<PharmacyModel>(
        fromFirestore: (snapshots, _) => PharmacyModel.fromSnapshot(
          snapshots,),
        toFirestore: (pharmacy, _) =>pharmacy.toJson());
  }

  Future<String> getCurrentPharmacyUid() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        throw Exception('No user logged in.');
      }
    } catch (e) {
      throw Exception('Error getting current pharmacy UID: $e');
    }
  }

  Stream<QuerySnapshot> getPharmacies() {
    return _pharmaciesRef.snapshots();
  }

  Future<void> addPharmacy(String pharmacyID, PharmacyModel pharmacy) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).set(pharmacy);
    } catch (e) {
      throw Exception('Error adding pharmacy: $e');
    }
  }

  Future<void> updatePharmacy(String pharmacyID, PharmacyModel pharmacy) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).update(pharmacy.toJson());
    } catch (e) {
      throw Exception('Error updating pharmacy: $e');
    }
  }

  Future<void> deletePharmacy(String pharmacyID) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).delete();
    } catch (e) {
      throw Exception('Error deleting pharmacy: $e');
    }
  }

  Stream<QuerySnapshot<UserReview>> getPharmacyReviews(String pharmacyID) {
    return _pharmaciesRef.doc(pharmacyID).collection('Reviews').withConverter<UserReview>(
      fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
      toFirestore: (review, _) => review.toJson(),
    ).snapshots();
  }

  Future<void> addPharmacyReview(String pharmacyID, String reviewID, UserReview review) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).set(review.toJson());
    } catch (e) {
      throw Exception('Error adding pharmacy review: $e');
    }
  }

  Future<void> updatePharmacyReview(String pharmacyID, String reviewID, UserReview review) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).update(review.toJson());
    } catch (e) {
      throw Exception('Error updating pharmacy review: $e');
    }
  }

  Future<void> deletePharmacyReview(String pharmacyID, String reviewID) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).delete();
    } catch (e) {
      throw Exception('Error deleting pharmacy review: $e');
    }
  }

  Stream<QuerySnapshot<UserOrder>> getPharmacyOrders(String pharmacyID) {
    return _pharmaciesRef.doc(pharmacyID).collection('Orders').withConverter<UserOrder>(
      fromFirestore: (snapshots, _) => UserOrder.fromSnapshot(snapshots),
      toFirestore: (order, _) => order.toJson(),
    ).snapshots();
  }

  Future<void> addPharmacyOrder(String pharmacyID, String orderID, UserOrder order) async {
    // For now the doc id is auto generated in the UserOrders collection
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).collection('UserOrders').add(order.toJson());
    } catch (e) {
      throw Exception('Error adding pharmacy order: $e');
    }
  }

  Future<void> updatePharmacyOrder(String pharmacyID, String orderID, UserOrder order) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).update(order.toJson());
    } catch (e) {
      throw Exception('Error updating pharmacy order: $e');
    }
  }

  Future<void> deletePharmacyOrder(String pharmacyID, String orderID) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).delete();
    } catch (e) {
      throw Exception('Error deleting pharmacy order: $e');
    }
  }

  Future<List<DocumentSnapshot>> getNearbyPharmacies(LatLng userPosition, String medication) {
    try {
      final geo = GeoFlutterFire();

      GeoFirePoint center = geo.point(latitude: userPosition.latitude, longitude: userPosition.longitude);
      var collectionReference = firestore.collection('Pharmacies');
      double radius = 5.0; // radius in kilometers
      String field = 'Position';

      Stream<List<DocumentSnapshot>> nearbyPharmaciesStream = geo.collection(collectionRef: collectionReference)
          .within(center: center, radius: radius, field: field);

      return filterByMedication(nearbyPharmaciesStream, medication);
    } catch (e) {
      throw Exception('Error getting nearby pharmacies: $e');
    }

  }

  Future<List<DocumentSnapshot>> filterByMedication(Stream<List<DocumentSnapshot>> pharmaciesStream, String medication) async {
    try {
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
    } catch (e) {
      throw Exception('Error filtering pharmacies by medication: $e');
    }

  }

  // Future<List<DocumentSnapshot>> getAcceptedUserOrders(String userID, ) {
  //   Stream<QuerySnapshot<UserReview>> stream = _pharmaciesRef.doc(userID).collection('Reviews').withConverter<UserReview>(
  //     fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
  //     toFirestore: (review, _) => review.toJson(),
  //   ).snapshots();
  // }

  Future<DocumentSnapshot> getDrugByName(String name, String pharmacyID) async {
    try {
    CollectionReference drugsRef = _pharmaciesRef.doc(pharmacyID).collection('Drugs');
    DocumentSnapshot drugDoc = await drugsRef.doc(name).get();
    if (drugDoc.exists) {
      return drugDoc;
    } else {
      throw Exception('No such document.');
    }
    } catch (e) {
      throw Exception('Error getting drug by name: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getToAcceptUserOrders(String userID) async* {
    try {
      final pharmaciesSnapshotStream = firestore.collection('Pharmacies').snapshots();
      await for (var pharmaciesSnapshot in pharmaciesSnapshotStream) {
        List<Map<String, dynamic>> allUserOrders = [];

        // Get the Orders document where the document ID is the same as userID
        final orderDocSnapshot = await firestore.collection('Orders').doc(userID).get();

        if (orderDocSnapshot.exists) {
          // Get the UserOrders collection inside the Orders document
          final userOrdersSnapshot = await orderDocSnapshot.reference.collection('UserOrders').get();

          for (var userOrderDoc in userOrdersSnapshot.docs) {
            final data = userOrderDoc.data();
            if (data['isAccepted'] && !data['isCompleted']) {
              allUserOrders.add(data);
            }
          }
        }

        // Yield the accumulated list of accepted user orders
        yield allUserOrders;
      }
    } catch (e) {
      throw Exception('Error getting ongoing user orders: $e');
    }

  }

  //////////////////////////////////////////////////////////////

  Stream<QuerySnapshot<DrugsModel>> getDrugs(String pharmacyID) {
    return _pharmaciesRef.doc(pharmacyID).collection('Drugs').withConverter<DrugsModel>(
      fromFirestore: (snapshots, _) => DrugsModel.fromSnapshot(snapshots),
      toFirestore: (drug, _) => drug.toJson(),
    ).snapshots();
  }

  Future<void> addDrug(String pharmacyID, String drugID, DrugsModel drug) async {
    //Use the drug name as their doc id in Drugs collection
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Drugs').doc(drugID).set(drug.toJson());
    } catch (e) {
      throw Exception('Error adding drug: $e');
    }
  }

  Future<void> updateDrug(String pharmacyID, String drugID, DrugsModel drug) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Drugs').doc(drugID).update(drug.toJson());
    } catch (e) {
      throw Exception('Error updating drug: $e');
    }
  }

  Future<void> deleteDrug(String pharmacyID, String drugID) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Drugs').doc(drugID).delete();
    } catch (e) {
      throw Exception('Error deleting drug: $e');
    }
  }
}