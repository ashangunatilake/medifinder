import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/pages/launcher.dart';
import 'package:medifinder/pages/pharmacy/full_screen_image.dart';
import 'package:medifinder/pages/pharmacy/pharmacyview.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PushNotifications _pushNotifications = PushNotifications();
  late DocumentSnapshot userDoc;
  late String pharmacyID;
  late DocumentSnapshot pharmacyDoc;
  List<DocumentSnapshot> user = [];
  late bool accepted;
  bool loading = true;

  Future<void> _acceptOrder(DocumentSnapshot<Map<String, dynamic>> orderDoc) async {
    UserOrder updatedOrder = UserOrder.fromSnapshot(orderDoc);
    updatedOrder = updatedOrder.copyWith(isAccepted: true);
    await _pharmacyDatabaseServices.updatePharmacyOrder(pharmacyID, userDoc.id, orderDoc.id, updatedOrder);
    await _pharmacyDatabaseServices.updateDrugQuantity(pharmacyDoc.id, updatedOrder.did, updatedOrder.quantity);
    print('Order Accepted');

    try {
      UserModel userData = userDoc.data() as UserModel;
      print(userData.tokens);
      List<String> tokens = List<String>.from(userData.tokens);
      if(tokens.isNotEmpty) {
        for(var token in tokens) {
          _pushNotifications.sendNotificationToCustomer(token, true, false, orderDoc['DrugName'].toString().capitalizeFirst!, pharmacyDoc['Name']);
        }
      }
        } catch (e) {
      Exception('Error getting FCM token: $e');
    }

    Future.delayed(Duration.zero, () {
      Snackbars.successSnackBar(message: "Order accepted successfully", context: context);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PharmacyView(index: 1,)), (route) => false);
    });
  }

  Future<void> _cancelOrder(BuildContext context, DocumentSnapshot<Map<String, dynamic>> orderDoc) async {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: TextField(
            controller: reasonController,
            decoration:
                const InputDecoration(hintText: 'Enter reason for cancellation'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                final reason = reasonController.text;
                if (reason.isNotEmpty) {
                  //Navigator.of(context).pop(); // Close the dialog
                  print('Order Cancelled with reason: $reason');

                  // This is where you would call the backend to cancel the order
                  await _pharmacyDatabaseServices.deletePharmacyOrder(pharmacyID, userDoc.id, orderDoc.id);
                  print('Order Cancelled');

                  Future.delayed(Duration.zero, () {
                    Snackbars.successSnackBar(message: "Order cancelled successfully", context: context);
                    Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
                  });

                  print(userDoc['FCMTokens']);
                  try {
                    UserModel userData = userDoc.data() as UserModel;
                    print(userData.tokens);
                    List<String> tokens = List<String>.from(userData.tokens);
                    if(tokens.isNotEmpty) {
                      for(var token in tokens) {
                        _pushNotifications.sendNotificationToCustomer(token, false, false, orderDoc['DrugName'].toString().capitalizeFirst!, pharmacyDoc['Name'], reason);
                      }
                    }
                  } catch (e) {
                    Exception('Error getting FCM token: $e');
                  }
                } else {
                    Snackbars.errorSnackBar(message: "Reason cannot be empty", context: context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeUserData();
  }

  void initializeUserData() async {
    try {
      pharmacyID = await _userDatabaseServices.getCurrentUserUid();
      pharmacyDoc = await _pharmacyDatabaseServices.getCurrentPharmacyDoc();
      print("!!! $pharmacyDoc['Name']");
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null) {
        userDoc = args['selectedUser'] as DocumentSnapshot;
        print("!!! $userDoc['Name']");
        accepted = args['accepted'] as bool;
        user.add(userDoc);
      }
      else {
        throw Exception("Arguments are missing");
      }
    }
    catch (e) {
      print("Error fetching user data: $e");
    }
    finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(),);
    }
    else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: (!accepted) ? Text("Pending Orders - ${userDoc["Name"]} ") : Text("Accepted Orders - ${userDoc["Name"]} "),
          backgroundColor: Colors.white38,
          elevation: 0.0,
          titleTextStyle: const TextStyle(
              fontSize: 16.0,
              color: Colors.black,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SafeArea(child: SizedBox()),
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: (!accepted) ? _pharmacyDatabaseServices.getToAcceptUserOrders(pharmacyID, userDoc.id) : _pharmacyDatabaseServices.getAcceptedUserOrders(pharmacyID, userDoc.id),
                  builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const OrderDetailsSkeleton();
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text('No data available');
                    }
                    else {
                      var docs = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4.0,
                                      offset: Offset(0, 4)
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order Details',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 16.0),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        docs[index]['DrugName'].toString().capitalizeFirst!,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0
                                      ),
                                      Text(
                                        "Quantity - ${docs[index]['Quantity'].toInt()}",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Text(
                                        (docs[index]['DeliveryMethod']) ? "Method of Delivery - Deliver" : "Method of Delivery - Meet at Pharmacy",
                                        style: const TextStyle(
                                            fontSize: 16.0
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Card(
                                  color: const Color.fromRGBO(8, 253, 228, 1),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: const Text('View Prescription'),
                                    trailing: const Icon(Icons.photo),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImagePage(imageUrl: docs[index]['PrescriptionURL']),));
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!accepted) ElevatedButton(
                                      onPressed: () {
                                        _acceptOrder(docs[index] as DocumentSnapshot<Map<String, dynamic>>);
                                        // Send a notification to the user
                                        
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 69, 255, 236)
                                      ),
                                      child: const Text(
                                        "Accept Order",
                                        style: TextStyle(color: Colors.black),
                                      )
                                    ),
                                    if (!accepted) ElevatedButton(
                                        onPressed: () {
                                          _cancelOrder(context, docs[index] as DocumentSnapshot<Map<String, dynamic>>);

                                          // Send a notification to the user with the reason

                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(245, 72, 70, 70)
                                        ),
                                        child: const Text(
                                          "Cancel Order",
                                          style: TextStyle(color: Colors.white),
                                        )
                                    ),
                                    if (accepted && docs[index]['DeliveryMethod']) ElevatedButton(
                                        onPressed: () {
                                          GeoPoint geopoint = docs[index]['UserLocation'];
                                          Launcher.openMap(geopoint);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 69, 255, 236),
                                            fixedSize: const Size(120, 20)
                                        ),
                                        child: const Text(
                                          "Directions",
                                          style: TextStyle(color: Colors.white),
                                        )
                                    ),
                                    if (accepted) ElevatedButton(
                                        onPressed: () {
                                          Launcher.openDialler(userDoc['Mobile']);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 69, 255, 236),
                                          fixedSize: const Size(120, 20)
                                        ),
                                        child: const Text(
                                          "Call",
                                          style: TextStyle(color: Colors.white),
                                        )
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      );
                    }
                  }
                ),
              )
            ],
          )
        ),
      );
    }

  }
}

class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, 4)
                )
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 200,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width: 150,
                        height: 25.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20.0
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width: 150,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 10.0
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width: 150,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[400]!,
                        highlightColor: Colors.grey[200]!,
                        period: const Duration(milliseconds: 800),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      width: 100.0,
                      height: 30,
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
                      width: 100.0,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0,)
            ],
          ),
        ),
      ],
    );
  }
}

