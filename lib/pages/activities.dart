import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import '../services/database_services.dart';

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool ongoing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
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
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: ongoing ? _userDatabaseServices.getOngoingUserOrders(user!.uid) : _userDatabaseServices.getCompletedUserOrders(user!.uid),
                    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                          itemBuilder: (context, index){
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                              "Pharmacy Name",
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
                                          docs[index]['DrugID'],
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
                                          height: 20.0,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {

                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF12E7C0),
                                                    //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                                ),
                                                child: const Text(
                                                  "Directions",
                                                  style: TextStyle(
                                                    color: Colors.white,
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

                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF12E7C0),
                                                    //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                                ),
                                                child: const Text(
                                                  "Call",
                                                  style: TextStyle(
                                                    color: Colors.white,
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
                                                  continueDialog(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFFFFFF),
                                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                                ),
                                                child: const Text(
                                                  "Received",
                                                  style: TextStyle(
                                                    color: Color(0xFF12E7C0),
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
            label: "Activities",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          )
        ],
        currentIndex: 1,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamed(context, '/home');
          if (n == 2) Navigator.pushNamed(context, '/profile');
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}

Future<void> continueDialog(context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Received",
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pharmacy Name",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                "Medicine Name",
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
                        side: const BorderSide(color: Color(0xFF12E7C0))
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF12E7C0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {

                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12E7C0),
                        //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                        side: const BorderSide(color: Color(0xFF12E7C0))
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

