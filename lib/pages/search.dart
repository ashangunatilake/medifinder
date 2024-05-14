import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/pharmacy_database_services.dart';


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final DatabaseServices _databaseServices = DatabaseServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              child: SizedBox(
                height: 5,
              )
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0,21.0,24.0,0),
              child: Form(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(9.0),
                      border: Border.all(
                        color: const Color(0xFFCCC9C9),
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Medicine';
                              }
                              return null;
                            },
                            //controller: emailcontroller,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search Medicine",
                                hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15.0,
                                  color: Color(0xFFC4C4C4),
                                )
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFFC4C4C4),

                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            const SizedBox(height: 21.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0,0,0,0),
              child: ElevatedButton(
                onPressed: () {
                  _databaseServices.getPharmacies().listen((QuerySnapshot snapshot) {
                    snapshot.docs.forEach((DocumentSnapshot doc) {
                      print('Pharmacy Name: ${doc['Name']}');
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    //padding: const EdgeInsets.fromLTRB(54.0, 13.0, 54.0, 11.0)
                ),
                child: const Text(
                  "Map View",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                reverse: false,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/pharmacydetails');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left:10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
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
                        padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // we need to take the names of the pharmacies from the api or the database
                                //only the list of nearby pharmacies must be displayed
                                //therefore the display need to be adjusted for that

                                // child:StreamBuilder(
                                //     stream: _databaseServices.getPharmaciess(),
                                //     builder: (context, snapshot) {
                                //       List users = snapshot.data?docs ?? [];
                                //       return ListView();
                                //     }
                                // )

                                Text(
                                  "Pharmacy 1",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                Container(
                                  width: 47.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4.6",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 24.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Price 1",
                              style: TextStyle(
                                fontSize: 20.0
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin: const EdgeInsets.only(left:10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
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
                        padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pharmacy 1",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                Container(
                                  width: 47.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4.6",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 24.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Price 1",
                              style: TextStyle(
                                  fontSize: 20.0
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin: const EdgeInsets.only(left:10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
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
                        padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pharmacy 1",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                Container(
                                  width: 47.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4.6",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 24.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Price 1",
                              style: TextStyle(
                                  fontSize: 20.0
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin: const EdgeInsets.only(left:10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
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
                        padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pharmacy 2",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                Container(
                                  width: 47.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4.7",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 24.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Price 2",
                              style: TextStyle(
                                  fontSize: 20.0
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                      margin: const EdgeInsets.only(left:10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
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
                        padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pharmacy 1",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                Container(
                                  width: 47.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "4.6",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 24.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Price 1",
                              style: TextStyle(
                                  fontSize: 20.0
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
          ],

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
        onTap: (int n) {
          if (n == 1) Navigator.pushNamed(context, '/activities');
          if (n == 2) Navigator.pushNamed(context, '/profile');
        },
        currentIndex: 0,
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}
//>>>>>>> b96531b6defded7e38a360d73d3995994aef4aee
