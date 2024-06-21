import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import '../../services/database_services.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  bool deliver = false;
  XFile? _image;
  final picker = ImagePicker();
  double quantity = 0;
  late String _imageUrl;
  late String userUid;
  late DocumentSnapshot userDoc;
  late Map<String, dynamic> userData;
  late DocumentSnapshot pharmacyDoc;
  late Map<String, dynamic> pharmacyData;
  late String drugName;
  late Map<String, dynamic> drugData;
  bool loading = false;

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
      userUid = await _userDatabaseServices.getCurrentUserUid() as String;
      userDoc = await _userDatabaseServices.getCurrentUserDoc();
      userData = userDoc!.data() as Map<String, dynamic>;
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null)
      {
        pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
        pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
        drugName = args['searchedDrug'] as String;
        DocumentSnapshot drugDoc = await _pharmacyDatabaseServices.getDrugByName(drugName, pharmacyDoc.id);
        drugData = drugDoc.data() as Map<String, dynamic>;
      }
      else {
        throw Exception("Arguments are missing");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  //Image Picker function to get image from gallery
  Future<void> getImageFromGalleryAndSave(String pName, String uName) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });

    if (_image != null) {
      _imageUrl = await _userDatabaseServices.uploadPrescription(_image!, pName, uName);
    }
  }

  //Image Picker function to get image from camera
  Future<void> getImageFromCameraAndSave(String pName, String uName) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      }
    });

    if (_image != null) {
      _imageUrl = await _userDatabaseServices.uploadPrescription(_image!, pName, uName);
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

  Future<void> userAddOrder(String uid, String pid, String drugName, String imageUrl, double quantity, bool delivery) async {
    try {
      UserOrder order = UserOrder(
        id: uid,
        did: drugName,
        pid: pid,
        url: imageUrl,
        quantity: quantity,
        delivery: delivery,
        isAccepted: false,
        isCompleted: false,
      );
      await _pharmacyDatabaseServices.addPharmacyOrder(pid, uid, order);
      print('User order added successfully!');
      Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Order placed successfully", context: context));
      Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
    } catch (e) {
      Snackbars.errorSnackBar(message: "Error placing the order", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: (!loading) ? Text("${pharmacyData["Name"]} - Order") : Text("Order"),
        backgroundColor: Colors.white54,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: (loading) ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
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
                          drugName,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Rs. ${drugData['UnitPrice'].toString()}",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
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
                  SizedBox(
                    height: 31.0,
                  ),
                  Text(
                    "Delivery Method",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 19.0,
                  ),
                  DropdownButton(
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "Meet at pharmacy",
                          style: TextStyle(fontSize: 14.0),
                        ),
                        value: false,
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Deliver",
                          style: pharmacyData['DeliveryServiceAvailability'] ? TextStyle(fontSize: 14.0)
                              : TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey
                          ),
                        ),
                        value: true,
                        enabled: pharmacyData['DeliveryServiceAvailability'],
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
                  SizedBox(
                    height: 19.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
                            border: Border.all(color: Color(0xFFC4C4C4)),
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                            boxShadow: [
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
                                icon: Icon(
                                  Icons.remove,
                                  color: Colors.black,
                                )
                            ),
                            Text(
                              "${quantity.toInt()}",
                              style: TextStyle(
                                  fontSize: 14.0
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    ++quantity;
                                  });
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                )
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 19.0,
                  ),
                  Text(
                    "Prescription",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 19.0),
                  GestureDetector(
                    onTap: () {
                      showOptions(pharmacyData['Name'], userData['Name']);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          border: Border.all(color: Color(0xFFC4C4C4)),
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x40FFFFFF),
                                blurRadius: 4.0,
                                offset: Offset(0, 4))
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _image == null
                              ? const Text(
                            "Upload prescription",
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          )
                              : Expanded(
                            child: Text(
                              _image!.name,
                              style: TextStyle(
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
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 85.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            userAddOrder(userUid, pharmacyDoc.id, drugName, _imageUrl, quantity, deliver);
                            //Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12E7C0),
                              //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                              side: const BorderSide(color: Color(0xFF12E7C0))),
                          child: const Text(
                            "Place Order",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 85.0,
                      )
                    ],
                  ),
                  SizedBox(height: 27.0)
                ],
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: "Orders",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
      //   ],
      //   currentIndex: 0,
      //   onTap: (int n) {
      //     if (n == 1) Navigator.pushNamed(context, '/activities');
      //     if (n == 2) Navigator.pushNamed(context, '/profile');
      //   },
      //   selectedItemColor: const Color(0xFF12E7C0),
      // ),
    );
  }
}
