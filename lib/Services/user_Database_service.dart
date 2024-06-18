// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:medifinder/models/drug_model.dart';

// class UserDatabaseServices {
//   final CollectionReference drugCollection =
//       FirebaseFirestore.instance.collection('drugs');

//   Future<void> deleteDrug(String drugId) async {
//     try {
//       await drugCollection.doc(drugId).delete();
//     } catch (e) {
//       throw Exception("Error deleting drug: $e");
//     }
//   }

//   Future<void> addDrug(DrugModel drug) async {
//     try {
//       await drugCollection.add(drug.toMap());
//     } catch (e) {
//       throw Exception('Error adding drug: $e');
//     }
//   }

//   Stream<List<DrugModel>> getDrugs() {
//     return drugCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return DrugModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }

//   Future<void> updateDrug(DrugModel drug) async {
//     try {
//       await drugCollection.doc(drug.id).update(drug.toMap());
//     } catch (e) {
//       throw Exception('Error updating drug: $e');
//     }
//   }

// //Search functionality is case sensitive
//   Future<List<DrugModel>> searchDrugs(String query) async {
//     QuerySnapshot snapshot = await drugCollection
//         .where('name', isGreaterThanOrEqualTo: query)
//         .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();
//     return snapshot.docs.map((doc) {
//       return DrugModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//     }).toList();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medifinder/models/drug_model.dart';
import 'package:medifinder/models/user_order_model.dart';

class UserDatabaseServices {
  final CollectionReference drugCollection =
      FirebaseFirestore.instance.collection('drugs');
  final CollectionReference userOrderCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference pharmacyOrderCollection =
      FirebaseFirestore.instance.collection('pharmacies');

  // Drug-related methods
  Future<void> deleteDrug(String drugId) async {
    try {
      await drugCollection.doc(drugId).delete();
    } catch (e) {
      throw Exception("Error deleting drug: $e");
    }
  }

  Future<void> addDrug(DrugModel drug) async {
    try {
      await drugCollection.add(drug.toMap());
    } catch (e) {
      throw Exception('Error adding drug: $e');
    }
  }

  Stream<List<DrugModel>> getDrugs() {
    return drugCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DrugModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> updateDrug(DrugModel drug) async {
    try {
      await drugCollection.doc(drug.id).update(drug.toMap());
    } catch (e) {
      throw Exception('Error updating drug: $e');
    }
  }

  Future<List<DrugModel>> searchDrugs(String query) async {
    QuerySnapshot snapshot = await drugCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs.map((doc) {
      return DrugModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Order-related methods
  Stream<List<UserOrder>> getOngoingOrders(String pharmacyId) {
    return pharmacyOrderCollection
        .doc(pharmacyId)
        .collection('Orders')
        .where('Completed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserOrder.fromSnapshot(doc);
      }).toList();
    });
  }

  Stream<List<UserOrder>> getCompletedOrders(String pharmacyId) {
    return pharmacyOrderCollection
        .doc(pharmacyId)
        .collection('Orders')
        .where('Completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserOrder.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> addUserOrder(String pharmacyId, UserOrder order) async {
    try {
      await pharmacyOrderCollection
          .doc(pharmacyId)
          .collection('Orders')
          .add(order.toJson());
    } catch (e) {
      throw Exception('Error adding user order: $e');
    }
  }

  Future<void> updateUserOrder(
      String pharmacyId, String orderId, UserOrder order) async {
    try {
      await pharmacyOrderCollection
          .doc(pharmacyId)
          .collection('Orders')
          .doc(orderId)
          .update(order.toJson());
    } catch (e) {
      throw Exception('Error updating user order: $e');
    }
  }

  Future<void> deleteUserOrder(String pharmacyId, String orderId) async {
    try {
      await pharmacyOrderCollection
          .doc(pharmacyId)
          .collection('Orders')
          .doc(orderId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting user order: $e');
    }
  }
}
