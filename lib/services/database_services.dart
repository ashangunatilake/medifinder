import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/models/user_review_model.dart';
import 'package:medifinder/models/user_order_model.dart';

const String USERS_COLLECTION_REFERENCE = 'Users';

class UserDatabaseServices {
  final firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersRef;

  UserDatabaseServices() {
    _usersRef = firestore.collection(USERS_COLLECTION_REFERENCE).withConverter<UserModel>(
        fromFirestore: (snapshots, _) => UserModel.fromSnapshot(
          snapshots,),
        toFirestore: (user, _) =>user.toJson());
  }

  Future<String> getCurrentUserUid() async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        throw Exception('No user logged in.');
      }
    } catch (e) {
      throw Exception('Error getting current user UID: $e');
    }
  }

  Future<DocumentSnapshot> getCurrentUserDoc() async {
    try {
      User? user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();

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

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  Future<void> addUser(String userID, UserModel user) async {
    try {
      await _usersRef.doc(userID).set(user);
    } catch (e) {
      throw Exception('Error adding user: $e');
    }

  }

  Future<void> updateUser(String userID, UserModel user) async {
    try {
      await _usersRef.doc(userID).update(user.toJson());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userID) async {
    try {
      await _usersRef.doc(userID).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Stream<QuerySnapshot<UserReview>> getUserReviews(String userID) {
    return _usersRef.doc(userID).collection('Reviews').withConverter<UserReview>(
      fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
      toFirestore: (review, _) => review.toJson(),
    ).snapshots();
  }

  Future<void> addUserReview(String userID, UserReview review) async {
    try {
      await _usersRef.doc(userID).collection('Reviews').add(review.toJson());
    } catch (e) {
      throw Exception('Error adding user review: $e');
    }
  }

  Future<void> updateUserReview(String userID, String reviewID, UserReview review) async {
    try {
      await _usersRef.doc(userID).collection('Reviews').doc(reviewID).update(review.toJson());
    } catch (e) {
      throw Exception('Error updating user review: $e');
    }
  }

  Future<void> deleteUserReview(String userID, String reviewID) async {
    try {
      await _usersRef.doc(userID).collection('Reviews').doc(reviewID).delete();
    } catch (e) {
      throw Exception('Error deleting user review: $e');
    }
  }

  Stream<QuerySnapshot<UserOrder>> getUserOrders(String userID) {
    return _usersRef.doc(userID).collection('Orders').withConverter<UserOrder>(
      fromFirestore: (snapshots, _) => UserOrder.fromSnapshot(snapshots),
      toFirestore: (order, _) => order.toJson(),
    ).snapshots();
  }

  Future<void> addUserOrder(String userID, UserOrder order) async {
    try {
      await _usersRef.doc(userID).collection('Orders').add(order.toJson());
    } catch (e) {
      throw Exception('Error adding user order: $e');
    }
  }

  Future<void> updateUserOrder(String userID, String orderID, UserOrder order) async {
    try {
      await _usersRef.doc(userID).collection('Orders').doc(orderID).update(order.toJson());
    } catch (e) {
      throw Exception('Error updating user order: $e');
    }
  }

  Future<void> deleteUserOrder(String userID, String orderID) async {
    try {
      await _usersRef.doc(userID).collection('Orders').doc(orderID).delete();
    } catch (e) {
      throw Exception('Error deleting user order: $e');
    }
  }

  // Pick/Capture an image
  // Upload the image to Firebase storage
  // Get the URL of the uploaded image
  // Store the image ULR inside the corresponidng databse doc
  // Future<String> uploadPrescription(String pName, String uName) async {
  //   ImagePicker imagePicker = ImagePicker();
  //   XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
  //
  //   if (image != null) {
  //     String imageName = DateTime.now().microsecondsSinceEpoch.toString();
  //
  //     Reference referenceRoot = FirebaseStorage.instance.ref(); // Get a reference to storage root
  //     Reference referencePharmacyDir = referenceRoot.child(pName); // Create a reference to the pharmacy directory
  //     Reference referenceUserDir = referencePharmacyDir.child(uName); // Create a reference to the user directory inside the pharmacy directory
  //     Reference referenceImage = referenceUserDir.child(imageName); // Create a reference to the image inside the user's directory
  //
  //     try {
  //       await referenceImage.putFile(File(image.path)); // Upload the image to Firebase Storage
  //       String imageUrl = await referenceImage.getDownloadURL(); // Optionally, you can get the download URL of the uploaded image
  //       print('Image uploaded successfully!');
  //       return imageUrl;
  //       // to access the image use Image.network('url');
  //     } catch (e) {
  //       print('Error uploading image: $e');
  //       return 'Error uploading image: $e';
  //     }
  //   } else {
  //     print('No image selected.');
  //     return 'No image selected.';
  //   }
  // }

  Future<String> uploadPrescription(XFile image, String pName, String uName) async {
    String imageName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref(); // Get a reference to storage root
    Reference referencePharmacyDir = referenceRoot.child(pName); // Create a reference to the pharmacy directory
    Reference referenceUserDir = referencePharmacyDir.child(uName); // Create a reference to the user directory inside the pharmacy directory
    Reference referenceImage = referenceUserDir.child(imageName); // Create a reference to the image inside the user's directory

    try {
      await referenceImage.putFile(File(image.path)); // Upload the image to Firebase Storage
      String imageUrl = await referenceImage.getDownloadURL(); // Optionally, you can get the download URL of the uploaded image
      print('Image uploaded successfully!');
      return imageUrl;
      // to access the image use Image.network('url');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Future<List<DocumentSnapshot>> getAcceptedUserOrders(String userID) {
  //   Stream<QuerySnapshot<UserReview>> stream = _usersRef.doc(userID).collection('Reviews').withConverter<UserReview>(
  //                                               fromFirestore: (snapshots, _) => UserReview.fromSnapshot(snapshots),
  //                                               toFirestore: (review, _) => review.toJson(),
  //                                               ).snapshots();
  //
  // }

  // Stream<QuerySnapshot> getOngoingUserOrders(String userID) async* {
  //   try {
  //     //List<Map<String, dynamic>> allUserOrders = [];
  //     await firestore.collection('Pharmacies').get().then((QuerySnapshot querySnapshot) {
  //       querySnapshot.docs.forEach((doc) {
  //         firestore.collection('Pharmacies').doc(doc.id).collection('Orders').get().then((QuerySnapshot querySnapshot2){
  //           querySnapshot2.docs.forEach((element) {
  //             if (element.id == userID){
  //               firestore.collection('Pharmacies').doc(doc.id).collection('Orders').doc(element.id).collection('UserOrders').where("Completed", isEqualTo: false).snapshots();
  //             }
  //           });
  //         });
  //       });
  //     });
  //     //final pharmaciesSnapshotStream = firestore.collection('Pharmacies').snapshots();
  //     // await for (var pharmaciesSnapshot in pharmaciesSnapshotStream) {
  //     //
  //     //   // Get the Orders document where the document ID is the same as userID
  //     //   // final orderDocSnapshot = await firestore.collection('Orders').doc(userID).get();
  //     //   //
  //     //   // if (orderDocSnapshot.exists) {
  //     //   //   // Get the UserOrders collection inside the Orders document
  //     //   //   print("hello");
  //     //   //   final userOrdersSnapshot = await orderDocSnapshot.reference.collection('UserOrders').get();
  //     //   //
  //     //   //   for (var userOrderDoc in userOrdersSnapshot.docs) {
  //     //   //     final data = userOrderDoc.data();
  //     //   //     if (data['isAccepted'] && !data['isCompleted']) {
  //     //   //       allUserOrders.add(data);
  //     //   //     }
  //     //   //   }
  //     //   // }
  //     //   //
  //     //   // // Yield the accumulated list of accepted user orders
  //     //   // yield allUserOrders;
  //     // }
  //   } catch (e) {
  //     throw Exception('Error getting ongoing user orders: $e');
  //   }
  //
  // }

  Stream<List<Map<String, dynamic>>> getOngoingUserOrders(String userID) async* {
    try {
      // Get all pharmacies
      final pharmaciesSnapshot = await firestore.collection('Pharmacies').get();

      // Create a list to store all ongoing orders
      List<Map<String, dynamic>> allUserOrders = [];

      for (var pharmacyDoc in pharmaciesSnapshot.docs) {
        // Get all orders for the given user in the current pharmacy
        final userOrdersSnapshot = await firestore
            .collection('Pharmacies')
            .doc(pharmacyDoc.id)
            .collection('Orders')
            .doc(userID)
            .collection('UserOrders')
            .where('Completed', isEqualTo: false)
            .get();

        for (var orderDoc in userOrdersSnapshot.docs) {
          allUserOrders.add(orderDoc.data());
        }
      }

      // Yield the list of ongoing orders
      yield allUserOrders;
    } catch (e) {
      throw Exception('Error getting ongoing user orders: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getCompletedUserOrders(String userID) async* {
    try {
      // Get all pharmacies
      final pharmaciesSnapshot = await firestore.collection('Pharmacies').get();

      // Create a list to store all ongoing orders
      List<Map<String, dynamic>> allUserOrders = [];

      for (var pharmacyDoc in pharmaciesSnapshot.docs) {
        // Get all orders for the given user in the current pharmacy
        final userOrdersSnapshot = await firestore
            .collection('Pharmacies')
            .doc(pharmacyDoc.id)
            .collection('Orders')
            .doc(userID)
            .collection('UserOrders')
            .where('Completed', isEqualTo: true)
            .get();

        for (var orderDoc in userOrdersSnapshot.docs) {
          allUserOrders.add(orderDoc.data());
        }
      }

      // Yield the list of ongoing orders
      yield allUserOrders;
    } catch (e) {
      throw Exception('Error getting completed user orders: $e');
    }
  }


  // Stream<List<Map<String, dynamic>>> getCompletedUserOrders(String userID) async* {
  //   try {
  //     final pharmaciesSnapshotStream = firestore.collection('Pharmacies').snapshots();
  //     await for (var pharmaciesSnapshot in pharmaciesSnapshotStream) {
  //       List<Map<String, dynamic>> allUserOrders = [];
  //
  //       // Get the Orders document where the document ID is the same as userID
  //       final orderDocSnapshot = await firestore.collection('Orders').doc(userID).get();
  //
  //       if (orderDocSnapshot.exists) {
  //         // Get the UserOrders collection inside the Orders document
  //         final userOrdersSnapshot = await orderDocSnapshot.reference.collection('UserOrders').get();
  //
  //         for (var userOrderDoc in userOrdersSnapshot.docs) {
  //           final data = userOrderDoc.data();
  //           if (data['isCompleted']) {
  //             allUserOrders.add(data);
  //           }
  //         }
  //       }
  //
  //       // Yield the accumulated list of accepted user orders
  //       yield allUserOrders;
  //     }
  //   } catch (e) {
  //     throw Exception('Error getting completed user orders: $e');
  //   }

  // }

  //void showMapView
}