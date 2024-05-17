import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:medifinder/pages/reviews.dart';

import '../models/pharmacy_model.dart';

class PharmacyDetails extends StatefulWidget {
  const PharmacyDetails({super.key});

  @override
  State<PharmacyDetails> createState() => _PharmacyDetailsState();
}

class _PharmacyDetailsState extends State<PharmacyDetails> {
  @override
  Widget build(BuildContext context) {
    final pharmacy = ModalRoute.of(context)!.settings.arguments as PharmacyModel;
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
          const SizedBox(
            height: 21.0
          ),
          Container(
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
                        pharmacy.name, //"Pharmacy 1"
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
                              pharmacy.ratings.toString(),
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
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10.0,0,10.0,5.0),
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
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/reviews');
                              },
                              child: const Text(
                                "See all reviews",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Color(0xFF0386D0)
                                ),
                              ),
                            )
                          ],
                        ),
                        const Text(
                            "Latest Reviews",
                            style: TextStyle(
                              fontSize: 18.0,
                            )
                        ),
                        const SizedBox(
                            height: 2.0
                        ),
                        Container(
                          height: 280.0,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: ListView(
                            reverse: false,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 9.0, top: 9.0),
                                    child: Text(
                                      "Name",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  RatingBar(
                                    ignoreGestures: true,
                                    initialRating: 4,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 24.0,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                    ratingWidget: RatingWidget(
                                      full: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      half: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      empty: Icon(
                                        Icons.star,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5.0
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                                  style: TextStyle(
                                    fontSize: 14.0
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 9.0, top: 9.0),
                                    child: Text(
                                      "Name",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  RatingBar(
                                    ignoreGestures: true,
                                    initialRating: 3,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 24.0,
                                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                    ratingWidget: RatingWidget(
                                      full: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      half: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      empty: Icon(
                                        Icons.star,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 5.0
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                                  style: TextStyle(
                                      fontSize: 14.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {

                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                ),
                                child: const Text(
                                  "Get directions",
                                  style: TextStyle(
                                    color: Color(0xFF12E7C0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {

                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                ),
                                child: const Text(
                                  "Call",
                                  style: TextStyle(
                                    color: Color(0xFF12E7C0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  continueDialog(context, pharmacy);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                ),
                                child: const Text(
                                  "Order",
                                  style: TextStyle(
                                    color: Color(0xFF12E7C0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/addreview', arguments: pharmacy,);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                    side: const BorderSide(color: Color(0xFF12E7C0))
                                ),
                                child: const Text(
                                  "Add a review",
                                  style: TextStyle(
                                    color: Color(0xFF12E7C0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                ]
              ),
            ),
          ),

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

Future<void> continueDialog(context, PharmacyModel pharmacy) async {
  return showDialog(
  context: context,
  barrierDismissible: false,
  builder: (BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery :",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          if(pharmacy.isDeliveryAvailable)
            Text(
              "Available",
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF008000)
              ),
            ),
          if(!pharmacy.isDeliveryAvailable)
            Text(
              "Not-Available",
              style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF008000)
              ),
            ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Note :\nPrescription should be uploaded"
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
                  Navigator.pushNamed(context, '/order', arguments: pharmacy,);

                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12E7C0),
                    //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                    side: const BorderSide(color: Color(0xFF12E7C0))
                ),
                child: const Text(
                  "Continue",
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