// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:medifinder/models/user_model.dart';
//
// final FirebaseFirestore _db = FirebaseFirestore.instance;
//
// Future<void> saveUserData(UserModel user) async {
//   try {
//     await _db.collection('Users').doc(user.id).set(user.toJson());
//   } on FirebaseException catch (e) {
//     throw TFirebaseException(e.code).message;
//   } on FormatException catch (e) {
//     throw const TFormatException();
//   } on PlatformException catch (e) {
//     throw TPlatformException(e.code).message;
//   } catch (e) {
//     throw 'Something went wrong. Please try again';
//   }
// }
//
// Future<UserModel> fetchUserDetails(String uid) async {
//   try {
//     final documentSnapshot = await _db.collection('Users').doc(uid).get();
//     if(documentSnapshot.exists) {
//       return UserModel.fromSnapshot(documentSnapshot);
//     } else {
//       return UserModel.empty();
//     }
//   } on FirebaseException catch (e) {
//     throw TFirebaseException(e.code).message;
//   } on FormatException catch (e) {
//     throw const TFormatException();
//   } on PlatformException catch (e) {
//     throw TPlatformException(e.code).message;
//   } catch (e) {
//     throw 'Something went wrong. Please try again';
//   }
// }
//
// Future<void> updateUserDetails(UserModel updatedUser) async {
//   try {
//     await _db.collection('Users').doc(updatedUser.id).update(updatedUser.toJson());
//   }on FirebaseException catch (e) {
//     throw TFirebaseException(e.code).message;
//   } on FormatException catch (e) {
//     throw const TFormatException();
//   } on PlatformException catch (e) {
//     throw TPlatformException(e.code).message;
//   } catch (e) {
//     throw 'Something went wrong. Please try again';
//   }
// }
//
// Future<void> updateSingleField(Map<String, dynamic> json, String uid) async {
//   try {
//     await _db.collection('Users').doc(uid).update(json);
//   }on FirebaseException catch (e) {
//     throw TFirebaseException(e.code).message;
//   } on FormatException catch (e) {
//     throw const TFormatException();
//   } on PlatformException catch (e) {
//     throw TPlatformException(e.code).message;
//   } catch (e) {
//     throw 'Something went wrong. Please try again';
//   }
// }
//
// Future<void> removeUserRecord(String uid) async {
//   try {
//     await _db.collection('Users').doc(uid).delete();
//   }on FirebaseException catch (e) {
//     throw TFirebaseException(e.code).message;
//   } on FormatException catch (e) {
//     throw const TFormatException();
//   } on PlatformException catch (e) {
//     throw TPlatformException(e.code).message;
//   } catch (e) {
//     throw 'Something went wrong. Please try again';
//   }
// }


// Future<Map<String, dynamic>> _loadData() async {
//   final userUid = await _userDatabaseServices.getCurrentUserUid();
//   final DocumentSnapshot userDoc = await _userDatabaseServices.getCurrentUserDoc();
//   final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//
//   final args = ModalRoute.of(context)!.settings.arguments as Map?;
//   late DocumentSnapshot pharmacyDoc;
//   late Map<String, dynamic> pharmacyData;
//   late String drugName;
//
//   if (args != null) {
//     pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
//     pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
//     drugName = args['searchedDrug'] as String;
//   }
//
//   return {
//     'userUid': userUid,
//     'userData': userData,
//     'pharmacyDoc': pharmacyDoc,
//     'pharmacyData': pharmacyData,
//     'drugName': drugName,
//   };
// }

// class YourWidgetState extends State<YourWidget> {
//   Map<String, dynamic>? _data;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData().then((data) {
//       setState(() {
//         _data = data;
//         _isLoading = false;
//       });
//     });
//   }
//
//   Future<Map<String, dynamic>> _loadData() async {
//     final userUid = await _userDatabaseServices.getCurrentUserUid();
//     final DocumentSnapshot userDoc = await _userDatabaseServices.getCurrentUserDoc();
//     final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//
//     final args = ModalRoute.of(context)!.settings.arguments as Map?;
//     late DocumentSnapshot pharmacyDoc;
//     late Map<String, dynamic> pharmacyData;
//     late String drugName;
//
//     if (args != null) {
//       pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
//       pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
//       drugName = args['searchedDrug'] as String;
//     }
//
//     return {
//       'userUid': userUid,
//       'userData': userData,
//       'pharmacyDoc': pharmacyDoc,
//       'pharmacyData': pharmacyData,
//       'drugName': drugName,
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return CircularProgressIndicator(); // or any other loading widget
//     } else {
//       // Use _data to build your widget
//
