import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medifinder/models/drug_model.dart';

class UserDatabaseServices {
  final CollectionReference drugCollection =
      FirebaseFirestore.instance.collection('drugs');

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

//Search functionality is case sensitive
  Future<List<DrugModel>> searchDrugs(String query) async {
    QuerySnapshot snapshot = await drugCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs.map((doc) {
      return DrugModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
