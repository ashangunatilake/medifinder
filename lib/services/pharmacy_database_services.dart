import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import '../models/drugs_model.dart';
import '../models/user_order_model.dart';
import '../models/user_review_model.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

import 'exception_handling_services.dart';

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

  Future<DocumentSnapshot> getCurrentPharmacyDoc() async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Pharmacies').doc(uid).get();

        if (userDoc.exists) {
          return userDoc;
        } else {
          throw Exception('No such document.');
        }
      } else {
        throw Exception('No user logged in.');
      }
    } catch (e) {
      throw Exception('Error getting current user document: $e');
    }

  }

  Future<DocumentSnapshot> getPharmacyDoc(String pharmacyID) async {
    try {
      DocumentSnapshot pharmacyDoc = await _pharmaciesRef.doc(pharmacyID).get();
      if (pharmacyDoc.exists) {
        return pharmacyDoc;
      } else {
        throw Exception('No such document.');
      }
    } catch (e) {
      throw Exception('Error getting current user document: $e');
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

  // Future<void> addPharmacyReview(String pharmacyID, String reviewID, UserReview review) async {
  //   try {
  //     await _pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID).set(review.toJson());
  //   } catch (e) {
  //     throw Exception('Error adding pharmacy review: $e');
  //   }
  // }

  Future<void> addPharmacyReview(String pharmacyID, String reviewID, UserReview review) async {
    try {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        // Add the new review
        transaction.set(_pharmaciesRef.doc(pharmacyID).collection('Reviews').doc(reviewID), review.toJson());
        // Get all reviews
        final reviewsSnapshot = await _pharmaciesRef.doc(pharmacyID).collection('Reviews').get();
        final reviews = reviewsSnapshot.docs;
        //Calculate the new average rating
        double totalRating = 0;
        reviews.forEach((review) {
          totalRating += review['Rating'];
        });
        double newOverallRating = totalRating / reviews.length;
        // Update the overall rating
        transaction.update(_pharmaciesRef.doc(pharmacyID), {
          'Ratings': newOverallRating,
        });
      });
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

  Stream<QuerySnapshot<UserReview>> getOnlyThreePharmacyReviews(String pharmacyID) {
    return _pharmaciesRef.doc(pharmacyID).collection('Reviews').withConverter<UserReview>(
      fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
      toFirestore: (review, _) => review.toJson(),
    ).limit(3).snapshots();
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
      final DocumentReference orderDocRef = _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID);
      await orderDocRef.set({'Placeholder': true});
      await orderDocRef.collection('UserOrders').add(order.toJson());
    } catch (e) {
      throw Exception('Error adding pharmacy order: $e');
    }
  }

  Future<void> updatePharmacyOrder(String pharmacyID, String orderID, String docID, UserOrder order) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).collection('UserOrders').doc(docID).update(order.toJson());
    } catch (e) {
      throw Exception('Error updating pharmacy order: $e');
    }
  }

  Future<void> deletePharmacyOrder(String pharmacyID, String orderID, String docID) async {
    try {
      await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(orderID).collection('UserOrders').doc(docID).delete();
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
        QuerySnapshot drugsSnapshotName = await drugsCollection.where('Name', isEqualTo: medication).get();
        if (drugsSnapshotName.docs.isNotEmpty) {
          filteredPharmacies.add(document);
        } else {
          QuerySnapshot drugsSnapshotBrandName = await drugsCollection.where('BrandName', isEqualTo: medication).get();
          if (drugsSnapshotBrandName.docs.isNotEmpty) {
            filteredPharmacies.add(document);
          }
        }
      }
      return filteredPharmacies;
    } catch (e) {
      throw Exception('Error filtering pharmacies by medication: $e');
    }
  }

  // Future<DocumentSnapshot> getDrugByName(String name, String pharmacyID) async {
  //   try {
  //     CollectionReference drugsRef = _pharmaciesRef.doc(pharmacyID).collection('Drugs');
  //     QuerySnapshot querySnapshotName = await drugsRef.where('Name', isEqualTo: name).get();
  //     if (querySnapshotName.docs.isNotEmpty) {
  //       return querySnapshotName.docs.first;
  //     } else {
  //       QuerySnapshot querySnapshotBrandName = await drugsRef.where('BrandName', isEqualTo: name).get();
  //       if (querySnapshotBrandName.docs.isNotEmpty) {
  //         return querySnapshotBrandName.docs.first;
  //       } else{
  //         throw Exception('No such document.');
  //       }
  //     }
  //   } catch (e) {
  //     throw Exception('Error getting drug by name: $e');
  //   }
  // }

  Future<DocumentSnapshot> getDrugByName(String name, String pharmacyID) async {
    try {
      CollectionReference drugsRef = _pharmaciesRef.doc(pharmacyID).collection('Drugs');
      QuerySnapshot querySnapshotName = await drugsRef.where('Name', isEqualTo: name).get();
      if (querySnapshotName.docs.isNotEmpty) {
        return querySnapshotName.docs.first;
      } else {
        throw DrugNameException('Drug not found');
      }
    } catch (e) {
      throw Exception('Error getting drug by name: $e');
    }
  }

  Future<List<DocumentSnapshot>> getDrugsByBrandName(String name, String pharmacyID) async {
    try {
      List<DocumentSnapshot> filteredDrugs = [];
      CollectionReference drugsRef = _pharmaciesRef.doc(pharmacyID).collection('Drugs');
      QuerySnapshot querySnapshotBrandName = await drugsRef.where('BrandName', isEqualTo: name).get();
      if (querySnapshotBrandName.docs.isNotEmpty) {
        for (DocumentSnapshot document in querySnapshotBrandName.docs) {
          filteredDrugs.add(document);
        }
        return filteredDrugs;
      } else{
        throw DrugBrandNameException('Drugs not found');
      }
    } catch (e) {
      throw Exception('Error getting drugs by brand name: $e');
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  // Functions for pharmacy uis
  //////////////////////////////////////////////////////////////////////////////

  Stream<List<DocumentSnapshot>> getUsersWithToAcceptOrders(String pharmacyID) async* {
    try {
      final userOrdersSnapshot = await _pharmaciesRef.doc(pharmacyID).collection('Orders').get();
      List<DocumentSnapshot> allUsersWithToAcceptOrders = [];
      print(userOrdersSnapshot.docs);
      for (var userOrdersDoc in userOrdersSnapshot.docs) {
        final ordersSnapshot = await userOrdersDoc.reference.collection('UserOrders').get();
        for (var orderDoc in ordersSnapshot.docs) {
          if(!orderDoc['Accepted'] && !orderDoc['Completed'])
          {
            allUsersWithToAcceptOrders.add(userOrdersDoc);
            break;
          }
        }
      }
      yield allUsersWithToAcceptOrders;
    } catch (e) {
      throw Exception('Error getting users with to-accept orders: $e');
    }
  }

  Stream<List<DocumentSnapshot>> getUsersWithAcceptedOrders(String pharmacyID) async* {
    try {
      final userOrdersSnapshot = await _pharmaciesRef.doc(pharmacyID).collection('Orders').get();
      List<DocumentSnapshot> allUsersWithAcceptedOrders = [];
      print(userOrdersSnapshot.docs);
      for (var userOrdersDoc in userOrdersSnapshot.docs) {
        final ordersSnapshot = await userOrdersDoc.reference.collection('UserOrders').get();
        for (var orderDoc in ordersSnapshot.docs) {
          if(orderDoc['Accepted'] && !orderDoc['Completed'])
          {
            allUsersWithAcceptedOrders.add(userOrdersDoc);
            break;
          }
        }
      }
      yield allUsersWithAcceptedOrders;
    } catch (e) {
      throw Exception('Error getting users with accepted orders: $e');
    }
  }

  Stream<List<DocumentSnapshot>> getToAcceptUserOrders(String pharmacyID, String userOrdersDocID) async* {
    try {
      final ordersSnapshot = await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(userOrdersDocID).collection('UserOrders').get();

      List<DocumentSnapshot> allUserOrders = [];

      for (var orderDoc in ordersSnapshot.docs) {
        if (!orderDoc['Accepted'] && !orderDoc['Completed']) {
          allUserOrders.add(orderDoc);
        }
      }

      yield allUserOrders;

    } catch (e) {
      throw Exception('Error getting to-accept user orders: $e');
    }
  }

  Stream<List<DocumentSnapshot>> getAcceptedUserOrders(String pharmacyID, String userOrdersDocID) async* {
    try {
      final ordersSnapshot = await _pharmaciesRef.doc(pharmacyID).collection('Orders').doc(userOrdersDocID).collection('UserOrders').get();

      List<DocumentSnapshot> allUserOrders = [];

      for (var orderDoc in ordersSnapshot.docs) {
        if (orderDoc['Accepted'] && !orderDoc['Completed']) {
          allUserOrders.add(orderDoc);
        }
      }

      yield allUserOrders;

    } catch (e) {
      throw Exception('Error getting to-accept user orders: $e');
    }
  }

  Stream<List<QuerySnapshot<DrugsModel>>> searchDrugs(String pharmacyID, String name) {
    final nameQuery = _pharmaciesRef.doc(pharmacyID).collection('Drugs').where('Name', isEqualTo: name).withConverter<DrugsModel>(
      fromFirestore: (snapshots, _) => DrugsModel.fromSnapshot(snapshots),
      toFirestore: (drug, _) => drug.toJson(),
    ).snapshots();

    final brandNameQuery = _pharmaciesRef.doc(pharmacyID).collection('Drugs').where('BrandName', isEqualTo: name).withConverter<DrugsModel>(
      fromFirestore: (snapshots, _) => DrugsModel.fromSnapshot(snapshots),
      toFirestore: (drug, _) => drug.toJson(),
    ).snapshots();
    return StreamZip([nameQuery, brandNameQuery]);
  }


  Stream<List<QuerySnapshot<DrugsModel>>> getDrugs(String pharmacyID) {
    final drugQuery = _pharmaciesRef.doc(pharmacyID).collection('Drugs').withConverter<DrugsModel>(
      fromFirestore: (snapshots, _) => DrugsModel.fromSnapshot(snapshots),
      toFirestore: (drug, _) => drug.toJson(),
    ).snapshots();
    return StreamZip([drugQuery]);
  }

  Future<void> addDrug(String pharmacyID, DrugsModel drug) async {
    //Use the drug name as their doc id in Drugs collection
    try {
      //await _pharmaciesRef.doc(pharmacyID).collection('Drugs').doc(drugID).set(drug.toJson());
      await _pharmaciesRef.doc(pharmacyID).collection('Drugs').add(drug.toJson());
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
  
  Future<void> updateDrugQuantity(String pharmacyID, String drugID, int quantity) async {
    try {
      final drugDoc = _pharmaciesRef.doc(pharmacyID).collection('Drugs').doc(drugID);
      final drugSnapshot = await drugDoc.get();

      if(drugSnapshot.exists) {
        final currentQuantity = drugSnapshot.data()?['Quantity'] ?? 0.0;
        final newQuantity = currentQuantity - quantity;

        if (newQuantity < 0) {
          throw InsufficientQuantityException('The quantity you are ordering is greater than the available quantity');
        }

        await drugDoc.update({'Quantity': newQuantity});
      } else {
        throw DrugNameException('Drug not found.');
      }
    } catch (e) {
      throw Exception('Error updating drug quantity: $e');
    }
  }
}

