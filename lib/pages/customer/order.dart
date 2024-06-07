import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/services/database_services.dart';

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
  late String _imageUrl;

  Future<Map<String, dynamic>> initializeData() async {
    String userUid = await _userDatabaseServices.getCurrentUserUid();
    DocumentSnapshot userDoc = await _userDatabaseServices.getCurrentUserDoc();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      DocumentSnapshot pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
      Map<String, dynamic> pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
      String drugName = args['searchedDrug'] as String;
      DocumentSnapshot drugDoc = await _pharmacyDatabaseServices.getDrugByName(drugName, pharmacyDoc.id);
      Map<String, dynamic> drugData = drugDoc.data() as Map<String, dynamic>;
      return {
        'userUid': userUid,
        'userDoc': userDoc,
        'userData': userData,
        'pharmacyDoc': pharmacyDoc,
        'pharmacyData': pharmacyData,
        'drugName': drugName,
        'drugData': drugData,
      };
    } else {
      throw Exception("Arguments are missing");
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
        url: imageUrl,
        quantity: quantity,
        delivery: delivery,
        isAccepted: false,
        isCompleted: false,
      );
      _pharmacyDatabaseServices.addPharmacyOrder(pid, uid, order);
      print('User order added successfully!');
      Navigator.pushNamed(context, "/login");
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final userData = data['userData'];
            final pharmacyData = data['pharmacyData'];
            final drugName = data['drugName'];
            final drugData = data['drugData'];
            final userUid = data['userUid'];
            final pharmacyDoc = data['pharmacyDoc'];

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SafeArea(
                    child: SizedBox(
                      height: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 21.0),
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
                          const SizedBox(
                            height: 12.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                drugData['UnitPrice'].toString(),
                                style: TextStyle(
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
                        DropdownButton<bool>(
                          items: const [
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
                                style: TextStyle(fontSize: 14.0),
                              ),
                              value: true,
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
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
                                onPressed: () {
                                  userAddOrder(userUid, pharmacyDoc.id, drugName, _imageUrl, 5, deliver);
                                  Navigator.pushNamed(context, '/activities');
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF12E7C0),
                                    side: const BorderSide(color: Color(0xFF12E7C0))),
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
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        currentIndex: 0,
        onTap: (int n) {
          if (n == 1) Navigator.pushNamed(context, '/activities');
          if (n == 2) Navigator.pushNamed(context, '/profile');
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}
