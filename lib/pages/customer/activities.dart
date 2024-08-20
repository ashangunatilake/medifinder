import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/user_order_model.dart';
import '../../services/database_services.dart';
import '../launcher.dart';
import 'package:badges/badges.dart' as badges;

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool ongoing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x40FFFFFF),
                          blurRadius: 4.0,
                          offset: Offset(0, 4)
                      )
                    ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height:20.0
                    ),
                    Text(
                      "Your Activities",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                ongoing = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                        color: ongoing ? Colors.grey : Color(0xFFFFFFFF),
                                        width: 2.0,
                                      )
                                  )
                              ),
                              child: Text(
                                "Ongoing",
                                style: TextStyle(
                                    fontSize: 14.0
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                ongoing = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                        color: !ongoing ? Colors.grey : Color(0xFFFFFFFF),
                                        width: 2.0,
                                      )
                                  )
                              ),
                              child: Text(
                                "Completed",
                                style: TextStyle(
                                    fontSize: 14.0
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<List<DocumentSnapshot>>(
                      stream: ongoing ? _userDatabaseServices.getOngoingUserOrders(user!.uid) : _userDatabaseServices.getCompletedUserOrders(user!.uid),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ActivitiesItemSkeleton(ongoing),
                                  const SizedBox(height: 10.0)
                                ],
                              );
                            }
                          );
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        }
                        else {
                          var docs = snapshot.data!;
                          print(docs.length);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      return FutureBuilder<DocumentSnapshot>(
                                          future: _pharmacyDatabaseServices.getPharmacyDoc(docs[index]['PharmacyID']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Column(
                                                children: [
                                                  ActivitiesItemSkeleton(ongoing),
                                                  const SizedBox(height: 10.0)
                                                ],
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return Text('Error: ${snapshot.error}');
                                            }
                                            if (!snapshot.hasData || snapshot.data == null) {
                                              return Text('No data available');
                                            }
                                            var pharmacyDoc = snapshot.data!;
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(10.0),
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(0x40FFFFFF),
                                                            blurRadius: 4.0,
                                                            offset: Offset(0, 4)
                                                          )
                                                        ]
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              pharmacyDoc['Name'],
                                                              style: TextStyle(
                                                                  fontSize: 20.0
                                                              ),
                                                            ),
                                                            if (!docs[index]['Completed']) Container(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.circle,
                                                                    color: docs[index]['Accepted'] ? Color(0xFF008000) : Colors.grey,
                                                                    size: 8.0,
                                                                  ),
                                                                  Text(
                                                                    docs[index]['Accepted'] ? " Accepted" : " Pending",
                                                                    style: TextStyle(
                                                                      fontSize: 14.0,
                                                                      color: docs[index]['Accepted'] ? Color(0xFF008000) : Colors.grey,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          "${docs[index]['DrugName'].toString().capitalizeFirst}",
                                                          style: TextStyle(
                                                              fontSize: 16.0
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Method of Delivery : ",
                                                              style: TextStyle(
                                                                  fontSize: 16.0
                                                              ),
                                                            ),
                                                            Text(
                                                              docs[index]['DeliveryMethod'] ? "Deliver" : "Meet at Pharmacy",
                                                              style: TextStyle(
                                                                  fontSize: 16.0
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          "Quantity : ${docs[index]['Quantity'].toInt()}",
                                                          style: TextStyle(
                                                              fontSize: 16.0
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  GeoPoint geopoint = pharmacyDoc['Position']['geopoint'];
                                                                  Launcher.openMap(geopoint);
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color(0xFF0CAC8F),
                                                                    //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                                    side: const BorderSide(
                                                                        color: Color(0xFF0CAC8F))
                                                                ),
                                                                child: const Text(
                                                                  "Directions",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  Launcher.openDialler(pharmacyDoc['ContactNo']);
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                    backgroundColor: const Color(0xFF0CAC8F),
                                                                    //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                                    side: const BorderSide(
                                                                        color: Color(0xFF0CAC8F)
                                                                    )
                                                                ),
                                                                child: const Text(
                                                                  "Call",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height: 10.0
                                                        ),
                                                        ongoing ? Row(
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  continueDialog(context, pharmacyDoc, docs[index], user!.uid, () {setState(() {docs.removeAt(index);});});
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color(0xFFFFFFFF),
                                                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                                    side: const BorderSide(
                                                                        color: Color(0xFF0CAC8F))
                                                                ),
                                                                child: const Text(
                                                                  "Received",
                                                                  style: TextStyle(
                                                                    color: Color(0xFF0CAC8F),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ) : SizedBox(height: 0)
                                                      ],
                                                    )
                                                ),
                                                SizedBox(
                                                  height: 10.0,
                                                ),
                                              ],
                                            );
                                          }
                                      );
                                    }
                                ),
                              ),
                            ],
                          );
                        }
                      }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Activities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          )
        ],
        currentIndex: 1,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamedAndRemoveUntil(context, '/customer_home', (route) => false);
          if (n == 2) Navigator.pushNamedAndRemoveUntil(context, '/message', (route) => false);
          if (n == 3) Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
        },
        selectedItemColor: const Color(0xFF0CAC8F),
      ),
    );
  }
}

Future<void> continueDialog(BuildContext context,  DocumentSnapshot pharmacyDoc, DocumentSnapshot orderDoc, String uid, Function updateState) async {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final PushNotifications _pushNotifications = PushNotifications();
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Received?",
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pharmacyDoc['Name'],
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                "${orderDoc['DrugName'][0].toUpperCase()}${orderDoc['DrugName'].substring(1)}",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                        side: const BorderSide(color: Color(0xFF0CAC8F))
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF0CAC8F),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if(orderDoc['Accepted'])
                      {
                        UserOrder updatedOrder = UserOrder.fromJson(uid, orderDoc.data() as Map<String, dynamic>).copyWith(isCompleted: true);
                        await _pharmacyDatabaseServices.updatePharmacyOrder(pharmacyDoc.id, uid, orderDoc.id, updatedOrder);

                        final DocumentSnapshot userDoc = await _userDatabaseServices.getUserDoc(uid);

                        if(pharmacyDoc['FCMTokens'] != null) {
                          List<String> tokens = List<String>.from(pharmacyDoc['FCMTokens']);
                          if(tokens.isNotEmpty) {
                            for(var token in tokens) {
                              _pushNotifications.sendNotificationToPharmacy(token, true, orderDoc['DrugName'].toString().capitalizeFirst!, userDoc['Name']);
                            }
                          }
                        }

                        Navigator.of(context).pop();
                        updateState();
                      }
                      else
                      {
                        Snackbars.errorSnackBar(message: "Pharmacy has not accepted the order", context: context);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CAC8F),
                        //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                        side: const BorderSide(color: Color(0xFF0CAC8F))
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],

            )
          ],
        );

      }
  );
}

class ActivitiesItemSkeleton extends StatelessWidget {
  const ActivitiesItemSkeleton(this.ongoing, {super.key});
  final bool ongoing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40FFFFFF),
            blurRadius: 4.0,
            offset: Offset(0, 4)
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: Duration(milliseconds: 800),
                  child: Container(
                    width: 150,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                ongoing ? Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[200]!,
                  period: Duration(milliseconds: 800),
                  child: Container(
                    width: 50,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ) : const SizedBox(width: 0,),
              ],
            ),
            const SizedBox(
              height: 20.0
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: Duration(milliseconds: 800),
              child: Container(
                width: 100,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: Duration(milliseconds: 800),
              child: Container(
                width: 150,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: Duration(milliseconds: 800),
              child: Container(
                width: 100,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            ongoing ? Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: Duration(milliseconds: 800),
                    child: Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                )
              ],
            ) : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}


