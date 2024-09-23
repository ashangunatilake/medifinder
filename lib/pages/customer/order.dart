import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/database_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/exception_handling_services.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final PushNotifications _pushNotifications = PushNotifications();
  bool deliver = false;
  XFile? _image;
  final picker = ImagePicker();
  int quantity = 0;
  String _imageUrl = "";
  late String userUid;
  late DocumentSnapshot userDoc;
  late Map<String, dynamic> userData;
  late DocumentSnapshot pharmacyDoc;
  late Map<String, dynamic> pharmacyData;
  late DocumentSnapshot drugDoc;
  late Map<String, dynamic> drugData;
  late LatLng userLocation;
  late double radius;
  bool loading = false;
  String fileName = "";

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  Future<void> initializeUserData() async {
    setState(() {
      loading = true;
    });

    try {
      userUid = await _userDatabaseServices.getCurrentUserUid();
      userDoc = await _userDatabaseServices.getCurrentUserDoc();
      userData = userDoc.data() as Map<String, dynamic>;
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null)
      {
        pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
        pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
        drugDoc = args['searchedDrug'] as DocumentSnapshot;
        drugData = drugDoc.data() as Map<String, dynamic>;
        userLocation = args['userLocation'] as LatLng;
        radius = args['radius'];
      }
      else {
        throw ErrorException();
      }
    } catch (e) {
      if (e is UserLoginException) {
        Snackbars.errorSnackBar(message: e.message, context: context);
      }
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget imageDialog(String imagePath, String pName, String uName) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
              height: 500.0,
              fit: BoxFit.fill,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 10.0,),
            const Text(
              "Upload prescription?",
              style: TextStyle(
                fontSize: 18.0
              ),
            ),
            const SizedBox(height: 10.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                      side: const BorderSide(color: Color(0xFF12E7C0))
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF12E7C0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                      );
                      _imageUrl = await _userDatabaseServices.uploadPrescription(_image!, pName, uName);
                      Navigator.pop(context); // Close the progress indicator
                      Snackbars.successSnackBar(message: "Prescription uploaded successfully", context: context);
                      Navigator.pop(context); // Close the dialog
                      setState(() {
                        fileName = _image!.name;
                      });
                    } catch (e) {
                      Navigator.pop(context); // Close the progress indicator
                      Snackbars.errorSnackBar(message: "Error uploading prescription", context: context);
                      Navigator.pop(context); // Close the dialog
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12E7C0),
                      //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                      side: const BorderSide(color: Color(0xFF12E7C0))),
                  child: const Text(
                    "Upload",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  Future<XFile?> compressImage(String path) async {
    final lastIndex = path.lastIndexOf(RegExp(r'.png|.jp'));
    final fileName = path.substring(0,lastIndex);
    final outputPath = "${fileName}_out${path.substring(lastIndex)}";
    print(outputPath);
    if (lastIndex == path.lastIndexOf(RegExp(r'.png'))) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
          path,
          outputPath,
          minWidth: 1000,
          minHeight: 1000,
          quality: 50,
          format: CompressFormat.png
      );
      return compressedImage;
    }
    else {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        path,
        outputPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
      );
      return compressedImage;
    }

  }

  //Image Picker function to get image from gallery
  Future<void> getImageFromGalleryAndSave(String pName, String uName) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);


    if (pickedFile != null) {
      _image = await compressImage(pickedFile.path);
      await showDialog(
        context: context,
        builder: (_) => imageDialog(_image!.path, pName, uName),
        barrierDismissible: false
      );
    }
  }

  //Image Picker function to get image from camera
  Future<void> getImageFromCameraAndSave(String pName, String uName) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _image = await compressImage(pickedFile.path);
      await showDialog(
          context: context,
          builder: (_) => imageDialog(_image!.path, pName, uName),
          barrierDismissible: false
      );
    }

  }

  Future<void> showOptions(String pName, String uName) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text("Gallery"),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGalleryAndSave(pName, uName);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text("Camera"),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCameraAndSave(pName, uName);
            },
          ),
        ],
      ),
    );
  }

  Future<void> userAddOrder(String uid, String pid, String drugID, String drugName, String imageUrl, int quantity, bool delivery, [GeoPoint? location]) async {
    try {
      UserOrder order = UserOrder(
        id: uid,
        did: drugID,
        drugName: drugName,
        pid: pid,
        url: imageUrl,
        quantity: quantity,
        delivery: delivery,
        isAccepted: false,
        isCompleted: false,
        location: location,
      );
      await _pharmacyDatabaseServices.addPharmacyOrder(pid, uid, order);
      print('User order added successfully!');
    } catch (e) {
      Snackbars.errorSnackBar(message: "Error placing the order", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: (!loading) ? Text("${pharmacyData["Name"]} - Order") : const Text("Order"),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: (loading) ? const Center(child: PageSkeleton())
          : Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
                child: SizedBox(
                  height: 21.0,
                )),
            Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x40FFFFFF),
                        blurRadius: 4.0,
                        offset: Offset(0, 4))
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${drugData['BrandName'].toString().capitalize} ${drugData['Dosage']}",
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Rs. ${drugData['UnitPrice'].toString()}",
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5.0,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x40FFFFFF),
                        blurRadius: 4.0,
                        offset: Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 31.0,
                  ),
                  const Text(
                    "Delivery Method",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(
                    height: 19.0,
                  ),
                  DropdownButton(
                    items: [
                      const DropdownMenuItem(
                        value: false,
                        child: Text(
                          "Meet at pharmacy",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        enabled: (pharmacyData['DeliveryServiceAvailability'] && radius == 5.0) ? true : false,
                        child: Text(
                          "Deliver",
                          style: (pharmacyData['DeliveryServiceAvailability'] && radius == 5.0) ? const TextStyle(fontSize: 14.0)
                              : const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey
                          ),
                        ),
                      ),
                    ],
                    isExpanded: true,
                    onChanged: (bool? selectedValue) {
                      setState(() {
                        deliver = selectedValue!;
                      });
                    },
                    value: deliver,
                  ),
                  const SizedBox(
                    height: 19.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            border: Border.all(color: const Color(0xFFC4C4C4)),
                            borderRadius: const BorderRadius.all(Radius.circular(9)),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x40FFFFFF),
                                  blurRadius: 4.0,
                                  offset: Offset(0, 4))
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                onPressed: () {
                                  if(quantity != 0)
                                  {
                                    setState(() {
                                      --quantity;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.black,
                                )
                            ),
                            Text(
                              "${quantity.toInt()}",
                              style: const TextStyle(
                                  fontSize: 14.0
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    ++quantity;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                )
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 19.0,
                  ),
                  const Text(
                    "Prescription",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 19.0),
                  GestureDetector(
                    onTap: () {
                      showOptions(pharmacyData['Name'], userData['Name']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          border: Border.all(color: const Color(0xFFC4C4C4)),
                          borderRadius: const BorderRadius.all(Radius.circular(9)),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x40FFFFFF),
                                blurRadius: 4.0,
                                offset: Offset(0, 4))
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          fileName.isEmpty
                              ? const Text(
                            "Upload prescription",
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          )
                              : Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.upload,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 85.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (quantity == 0) {
                              Snackbars.errorSnackBar(message: "Quantity cannot be zero", context: context);
                              return;
                            }
                            if (_imageUrl.isEmpty) {
                              Snackbars.errorSnackBar(message: "Please upload a prescription", context: context);
                              return;
                            }
                            final GeoPoint location = GeoPoint(userLocation.latitude, userLocation.longitude);
                            if(deliver) {
                              try {
                                await _pharmacyDatabaseServices.checkDrugQuantity(pharmacyDoc.id, drugDoc.id, quantity);
                                userAddOrder(userUid, pharmacyDoc.id, drugDoc.id, "${drugData['BrandName']} ${drugData['Dosage']}", _imageUrl, quantity, deliver, location);
                                if (pharmacyData['FCMTokens'] != null) {
                                  List<String> tokens = List<String>.from(pharmacyData['FCMTokens']);
                                  if (tokens.isNotEmpty) {
                                    for (var token in tokens) {
                                      print(token);
                                      _pushNotifications.sendNotificationToPharmacy(token, false, "${drugData['BrandName'].toString().capitalize} ${drugData['Dosage']}", userData['Name']);
                                    }
                                  }
                                }
                                Snackbars.successSnackBar(message: "Order placed successfully", context: context);
                                Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
                              } catch (e) {
                                if (e is InsufficientQuantityException) {
                                  Snackbars.errorSnackBar(message: e.message, context: context);
                                } else {
                                  Snackbars.errorSnackBar(message: 'Error placing order: $e', context: context);
                                }
                              }
                            }
                            else {
                              try {
                                await _pharmacyDatabaseServices.checkDrugQuantity(pharmacyDoc.id, drugDoc.id, quantity);
                                userAddOrder(userUid, pharmacyDoc.id, drugDoc.id, "${drugData['BrandName']} ${drugData['Dosage']}", _imageUrl, quantity, deliver);
                                if(pharmacyData['FCMTokens'] != null) {
                                  List<String> tokens = List<String>.from(pharmacyData['FCMTokens']);
                                  if(tokens.isNotEmpty) {
                                    for(var token in tokens) {
                                      print(token);
                                      _pushNotifications.sendNotificationToPharmacy(token, false, "${drugData['BrandName'].toString().capitalize} ${drugData['Dosage']}", userData['Name']);
                                    }
                                  }
                                }
                                Snackbars.successSnackBar(message: "Order placed successfully", context: context);
                                Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
                              } catch (e) {
                                if (e is InsufficientQuantityException) {
                                  Snackbars.errorSnackBar(message: e.message, context: context);
                                } else {
                                  Snackbars.errorSnackBar(message: 'Error placing order: $e', context: context);
                                }
                              }

                            }
                            //Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0CAC8F),
                              //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                              side: const BorderSide(color: Color(0xFF0CAC8F))),
                          child: const Text(
                            "Place Order",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 85.0,
                      )
                    ],
                  ),
                  const SizedBox(height: 27.0)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PageSkeleton extends StatelessWidget {
  const PageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SafeArea(
              child: SizedBox(
                height: 21.0,
              )),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 4.0,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[400]!,
                        highlightColor: Colors.grey[200]!,
                        period: const Duration(milliseconds: 800),
                        child: Container(
                          height: 20.0,
                          width: 150.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[400]!,
                        highlightColor: Colors.grey[200]!,
                        period: const Duration(milliseconds: 800),
                        child: Container(
                          height: 20.0,
                          width: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 4.0,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 31.0,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: const Duration(milliseconds: 800),
                  child: Container(
                    height: 18.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 19.0,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: const Duration(milliseconds: 800),
                  child: Container(
                    height: 45.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 19.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        height: 18.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        height: 35.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 19.0,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: const Duration(milliseconds: 800),
                  child: Container(
                    height: 18.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 19.0),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: const Duration(milliseconds: 800),
                  child: Container(
                    height: 45.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: const Duration(milliseconds: 800),
                  child: Container(
                    height: 45.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 27.0)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

