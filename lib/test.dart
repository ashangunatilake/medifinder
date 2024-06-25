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


// @override
// Widget build(BuildContext context) {
//   final args = ModalRoute.of(context)!.settings.arguments as Map?;
//   if (args != null) {
//     pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
//     pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
//     drugName = args['searchedDrug'] as String;
//   } else {
//     // Handle the case where args are null (optional)
//     // You might want to throw an error or use default values
//   }
//
//   return Scaffold(
//     body: FutureBuilder<DocumentSnapshot>(
//       future: _userDatabaseServices.getCurrentUserDoc(),
//       builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator()); // Show a loading indicator while waiting
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
//         } else if (!snapshot.hasData || !snapshot.data!.exists) {
//           return Center(child: Text('Document does not exist')); // Handle the case where the document does not exist
//         } else {
//           DocumentSnapshot userDoc = snapshot.data!;
//           Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//           return buildOrderContent(userData, context); // Call a method to build the rest of the UI
//         }
//       },
//     ),
//     bottomNavigationBar: BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: "Home",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.shopping_cart),
//           label: "Orders",
//         ),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
//       ],
//       currentIndex: 0,
//       onTap: (int n) {
//         if (n == 1) Navigator.pushNamed(context, '/activities');
//         if (n == 2) Navigator.pushNamed(context, '/profile');
//       },
//       selectedItemColor: const Color(0xFF12E7C0),
//     ),
//   );
// }
//
// Widget buildOrderContent(Map<String, dynamic> userData, BuildContext context) {
//   return Container(
//     decoration: const BoxDecoration(
//       image: DecorationImage(
//         image: AssetImage('assets/background.png'),
//         fit: BoxFit.cover,
//       ),
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SafeArea(
//             child: SizedBox(
//               height: 5,
//             )),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                   size: 30.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 21.0),
//         Container(
//           margin: const EdgeInsets.only(left: 10.0, right: 10.0),
//           width: MediaQuery.of(context).size.width,
//           decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//               boxShadow: [
//                 BoxShadow(
//                     color: Color(0x40FFFFFF),
//                     blurRadius: 4.0,
//                     offset: Offset(0, 4))
//               ]),
//           child: Padding(
//             padding: const EdgeInsets.only(
//                 top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Medicine Name",
//                       style: TextStyle(
//                         fontSize: 20.0,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 12.0,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       "Price",
//                       style: TextStyle(
//                         fontSize: 20.0,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 5.0,
//                 )
//               ],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 10.0,
//         ),
//         Container(
//           margin: const EdgeInsets.only(left: 10.0, right: 10.0),
//           padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//           width: MediaQuery.of(context).size.width,
//           decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//               boxShadow: [
//                 BoxShadow(
//                     color: Color(0x40FFFFFF),
//                     blurRadius: 4.0,
//                     offset: Offset(0, 4))
//               ]),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 height: 31.0,
//               ),
//               Text(
//                 "Delivery Method",
//                 style: TextStyle(fontSize: 18.0),
//               ),
//               SizedBox(
//                 height: 19.0,
//               ),
//               DropdownButton(
//                 items: [
//                   DropdownMenuItem(
//                     child: Text(
//                       "Meet at pharmacy",
//                       style: TextStyle(fontSize: 14.0),
//                     ),
//                     value: false,
//                   ),
//                   DropdownMenuItem(
//                     child: Text(
//                       "Deliver",
//                       style: TextStyle(fontSize: 14.0),
//                     ),
//                     value: true,
//                   ),
//                 ],
//                 isExpanded: true,
//                 onChanged: (bool? selectedValue) {
//                   setState(() {
//                     deliver = selectedValue!;
//                   });
//                 },
//                 value: deliver,
//               ),
//               SizedBox(
//                 height: 19.0,
//               ),
//               Text(
//                 "Prescription",
//                 style: TextStyle(fontSize: 18.0),
//               ),
//               SizedBox(height: 19.0),
//               GestureDetector(
//                 onTap: () {
//                   showOptions(pharmacyData['Name'], userData['Name']);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
//                   decoration: BoxDecoration(
//                       color: Color(0xFFF9F9F9),
//                       border: Border.all(color: Color(0xFFC4C4C4)),
//                       borderRadius: BorderRadius.all(Radius.circular(9)),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Color(0x40FFFFFF),
//                             blurRadius: 4.0,
//                             offset: Offset(0, 4))
//                       ]),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _image == null
//                           ? Text(
//                         "Upload prescription",
//                         style: TextStyle(
//                           fontSize: 14.0,
//                         ),
//                       )
//                           : Expanded(
//                         child: Text(
//                           _image!.name,
//                           style: TextStyle(
//                             fontSize: 14.0,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Icon(
//                         Icons.upload,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 30.0,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 85.0,
//                   ),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         //userAddOrder(userUid, pharmacyDoc.id, drugName, _imageUrl, quantity, deliver);
//                         Navigator.pushNamed(context, '/activities');
//                       },
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF12E7C0),
//                           //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
//                           side: const BorderSide(color: Color(0xFF12E7C0))),
//                       child: const Text(
//                         "Place Order",
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 85.0,
//                   )
//                 ],
//               ),
//               SizedBox(height: 27.0)
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapView extends StatelessWidget {
//   final LatLng userLocation;
//   final List<Map<String, dynamic>> pharmacyLocations;
//
//   const MapView({
//     required this.userLocation,
//     required this.pharmacyLocations,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Set<Marker> markers = {
//       Marker(
//         markerId: MarkerId('userLocation'),
//         position: userLocation,
//         infoWindow: InfoWindow(title: 'Your Location'),
//       ),
//     };
//
//     for (var pharmacy in pharmacyLocations) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(pharmacy['id']),
//           position: pharmacy['location'],
//           infoWindow: InfoWindow(title: pharmacy['name']),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Map View'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: userLocation,
//           zoom: 12,
//         ),
//         markers: markers,
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:medifinder/services/pharmacy_database_services.dart';
// import '../models/user_model.dart';
// import 'map_view.dart';
//
// class Search extends StatefulWidget {
//   const Search({super.key});
//
//   @override
//   State<Search> createState() => _SearchState();
// }
//
// class _SearchState extends State<Search> {
//   final PharmacyDatabaseServices _databaseServices = PharmacyDatabaseServices();
//   List<DocumentSnapshot> filteredPharmacies = [];
//   bool searched = false;
//   bool waiting = false;
//   late UserModel userModel;
//   late LatLng location;
//   final TextEditingController searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)!.settings.arguments as Map?;
//     if (args != null) {
//       userModel = args['user'] as UserModel;
//       location = args['location'] as LatLng;
//       print(location);
//     } else {
//       // Handle the case where args are null (optional)
//       // You might want to throw an error or use default values
//     }
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/background.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SafeArea(
//               child: SizedBox(height: 5),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 30.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24.0, 21.0, 24.0, 0),
//               child: Form(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14.0),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9F9F9),
//                     borderRadius: BorderRadius.circular(9.0),
//                     border: Border.all(
//                       color: const Color(0xFFCCC9C9),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                           child: TextFormField(
//                             controller: searchController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Medicine';
//                               }
//                               return null;
//                             },
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Search Medicine",
//                               hintStyle: TextStyle(
//                                 fontFamily: "Poppins",
//                                 fontSize: 15.0,
//                                 color: Color(0xFFC4C4C4),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
//                         child: GestureDetector(
//                           onTap: () async {
//                             setState(() {
//                               waiting = true;
//                             });
//                             filteredPharmacies = await _databaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase());
//                             setState(() {
//                               searched = true;
//                               waiting = false;
//                             });
//                           },
//                           child: Icon(
//                             Icons.search,
//                             color: Color(0xFFC4C4C4),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 21.0),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   List<Map<String, dynamic>> pharmacyLocations = filteredPharmacies.map((doc) {
//                     GeoPoint geoPoint = doc['location'];
//                     return {
//                       'id': doc.id,
//                       'name': doc['Name'],
//                       'location': LatLng(geoPoint.latitude, geoPoint.longitude),
//                     };
//                   }).toList();
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MapView(
//                         userLocation: location,
//                         pharmacyLocations: pharmacyLocations,
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                 ),
//                 child: const Text(
//                   "Map View",
//                   style: TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//             if (searched && !waiting)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredPharmacies.length,
//                   itemBuilder: (context, index) {
//                     return Column(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.pushNamed(context, '/pharmacydetails', arguments: {'selectedPharmacy': filteredPharmacies[index], 'searchedDrug': searchController.text.trim().toLowerCase()});
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(left: 10.0, right: 10.0),
//                             width: MediaQuery.of(context).size.width,
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.all(Radius.circular(10)),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Color(0x40FFFFFF),
//                                   blurRadius: 4.0,
//                                   offset: Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         filteredPharmacies[index]['Name'],
//                                         style: TextStyle(
//                                           fontSize: 20.0,
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 47.0,
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "4.6",
//                                               style: TextStyle(
//                                                 fontSize: 15.0,
//                                               ),
//                                             ),
//                                             Icon(
//                                               Icons.star,
//                                               color: Colors.amber,
//                                               size: 24.0,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 20.0,
//                                   ),
//                                   Text(
//                                     filteredPharmacies[index]['ContactNo'],
//                                     style: TextStyle(
//                                       fontSize: 20.0,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 7.0,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               )
//             else if (waiting)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: Center(child: CircularProgressIndicator()),
//               )
//             else
//               Expanded(child: SizedBox()),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Orders",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//           ),
//         ],
//         onTap: (int n) {
//           if (n == 1) Navigator.pushNamed(context, '/activities');
//           if (n == 2) Navigator.pushNamed(context, '/profile');
//         },
//         currentIndex: 0,
//         selectedItemColor: const Color(0xFF12E7C0),
//       ),
//     );
//   }
// }

// class PharmacyRatingWidget extends StatelessWidget {
//   final String pharmacyId;
//
//   PharmacyRatingWidget({required this.pharmacyId});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('Pharmacies').doc(pharmacyId).snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }
//         final pharmacyData = snapshot.data!;
//         double overallRating = pharmacyData['Ratings'];
//
//         return Text('Overall Rating: ${overallRating.toStringAsFixed(1)}');
//       },
//     );
//   }
// }

// <uses-permission android:name="android.permission.INTERNET" />-->
// <!--    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />-->
// <!--    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />-->
// <!--    <uses-permission android:name="android.permission.VIBRATE" />-->
// <!--    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />-->
// <!--    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />-->
// <!--    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />






