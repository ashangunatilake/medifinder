import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/models/user_order_model.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'orderDetails.dart';

class Orders extends StatefulWidget {
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final PharmacyDatabaseServices _databaseServices = PharmacyDatabaseServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  User? user = FirebaseAuth.instance.currentUser;

  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
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
                      "Customer Orders",
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
                                accepted = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                        color: !accepted ? Colors.grey : Color(0xFFFFFFFF),
                                        width: 2.0,
                                      )
                                  )
                              ),
                              child: Text(
                                "Pending",
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
                                accepted = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                        color: accepted ? Colors.grey : Color(0xFFFFFFFF),
                                        width: 2.0,
                                      )
                                  )
                              ),
                              child: Text(
                                "Accepted",
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
                  //margin: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<List<DocumentSnapshot>>(
                      stream: !accepted ? _databaseServices.getUsersWithToAcceptOrders(user!.uid) : _databaseServices.getUsersWithAcceptedOrders(user!.uid),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        }
                        else {
                          var docs = snapshot.data!;
                          print(docs.length);
                          return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<DocumentSnapshot>(
                                    future: _userDatabaseServices
                                        .getUserDoc(
                                        docs[index].id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return Text('No data available');
                                      }
                                      var userDoc = snapshot.data!;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            // _navigateToOrderDetails(context, order);
                                            Navigator.pushNamed(
                                              context,
                                              '/order_details',
                                              arguments: {'selectedUser': userDoc, 'accepted': accepted}
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4.0,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              userDoc['Name'],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                );
                              }
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          )
        ],
        currentIndex: 1,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_home', (route) => false);
          if (n == 2) Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_profile', (route) => false);
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}
