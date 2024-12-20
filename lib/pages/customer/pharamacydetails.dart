import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/models/user_review_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/pages/launcher.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:shimmer/shimmer.dart';

class PharmacyDetails extends StatefulWidget {
  const PharmacyDetails({super.key});

  @override
  State<PharmacyDetails> createState() => _PharmacyDetailsState();
}

class _PharmacyDetailsState extends State<PharmacyDetails> {
  final PharmacyDatabaseServices _databaseServices = PharmacyDatabaseServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  late DocumentSnapshot pharmacyDoc;
  late Map<String, dynamic> pharmacyData;
  late DocumentSnapshot drugDoc;
  late Map<String, dynamic> drugData;
  late LatLng userLocation;
  late double radius;
  double overallRating = 0;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
      pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
      drugDoc = args['searchedDrug'] as DocumentSnapshot;
      drugData = drugDoc.data() as Map<String, dynamic>;
      userLocation = args['userLocation'] as LatLng;
      radius = args['radius'] as double;
      listenToOverallRating(pharmacyDoc.id);
    } else {
      throw Exception('Something went wrong.');
    }
  }

  void listenToOverallRating(String pharmacyID) {
    _databaseServices.getPharmacyDocReference(pharmacyID).snapshots().listen((snapshot) {
      if (mounted) {
        if (snapshot.exists) {
          setState(() {
            overallRating = snapshot['Ratings'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Pharmacy details"
        ),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: Container(
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
              ),
            ),
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 10.0, left: 14.0, right: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pharmacyData['Name'], //"Pharmacy 1"
                          style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                overallRating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 26.0,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      "Hours of Operation - ${pharmacyData['HoursOfOperation']}",
                      style: const TextStyle(
                          fontSize: 16.0
                      ),
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
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40FFFFFF),
                    blurRadius: 4.0,
                    offset: Offset(0, 4),
                  ),
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 5.0),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40FFFFFF),
                      blurRadius: 4.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/reviews',
                                      arguments: {'selectedPharmacy': pharmacyDoc});
                                },
                                child: const Text(
                                  "See all reviews",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Color(0xFF0386D0)),
                                ),
                              )
                            ],
                          ),
                          const Text("Latest Reviews",
                              style: TextStyle(
                                fontSize: 18.0,
                              )),
                          const SizedBox(height: 2.0),
                          Container(
                            height: 280.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: StreamBuilder(
                              stream: _databaseServices
                                  .getOnlyThreePharmacyReviews(pharmacyDoc.id),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot<UserReview>>
                                  snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListView.builder(
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return const Column(
                                          children: [
                                            LatestReviewItemSkeleton(),
                                          ],
                                        );
                                      }
                                  );
                                }
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return const Text('No data available');
                                } else {
                                  List<UserReview> reviews = snapshot.data!.docs
                                      .map((doc) => doc.data())
                                      .toList();
                                  return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      itemCount: reviews.length,
                                      itemBuilder: (context, index) {
                                        UserReview review = reviews[index];
                                        return FutureBuilder<DocumentSnapshot>(
                                          future: _userDatabaseServices
                                              .getUserDoc(review.id),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                              userSnapshot) {
                                            if (userSnapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Column(
                                                  children: [
                                                    LatestReviewItemSkeleton(),
                                                    SizedBox(height: 5.0),
                                                  ]
                                              );
                                            }
                                            if (userSnapshot.hasError) {
                                              return const ListTile(
                                                title: Text('Error loading data'),
                                              );
                                            }
                                            if (userSnapshot.hasData) {
                                              UserModel userData =
                                              userSnapshot.data!.data()
                                              as UserModel;
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  LatestReviewItem(userData: userData, review: review),
                                                  //SizedBox(height: 5.0),
                                                  ]
                                              );
                                            } else {
                                              return const ListTile(
                                                title: Text('No data'),
                                              );
                                            }
                                          },
                                        );
                                      });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    GeoPoint geopoint =
                                    pharmacyData['Position']['geopoint'];
                                    Launcher.openMap(geopoint);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFFFF),
                                      padding: const EdgeInsets.fromLTRB(
                                          45.0, 13.0, 45.0, 11.0),
                                      side: const BorderSide(
                                          color: Color(0xFF0CAC8F))),
                                  child: const Text(
                                    "Get directions",
                                    style: TextStyle(
                                      color: Color(0xFF0CAC8F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Launcher.openDialler(
                                        pharmacyData['ContactNo']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFFFF),
                                      padding: const EdgeInsets.fromLTRB(
                                          45.0, 13.0, 45.0, 11.0),
                                      side: const BorderSide(
                                          color: Color(0xFF0CAC8F))),
                                  child: const Text(
                                    "Call",
                                    style: TextStyle(
                                      color: Color(0xFF0CAC8F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    continueDialog(
                                        context, pharmacyDoc, drugDoc, userLocation, radius);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFFFF),
                                      padding: const EdgeInsets.fromLTRB(
                                          45.0, 13.0, 45.0, 11.0),
                                      side: const BorderSide(
                                          color: Color(0xFF0CAC8F))),
                                  child: const Text(
                                    "Order",
                                    style: TextStyle(
                                      color: Color(0xFF0CAC8F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/addreview',
                                        arguments: pharmacyDoc);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFFFF),
                                      padding: const EdgeInsets.fromLTRB(
                                          45.0, 13.0, 45.0, 11.0),
                                      side: const BorderSide(
                                          color: Color(0xFF0CAC8F))),
                                  child: const Text(
                                    "Add a review",
                                    style: TextStyle(
                                      color: Color(0xFF0CAC8F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatestReviewItem extends StatelessWidget {
  const LatestReviewItem({
    super.key,
    required this.userData,
    required this.review,
  });

  final UserModel userData;
  final UserReview review;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
          children: [
            Padding(
              padding:
              const EdgeInsets.only(
                  left: 9.0,
                  top: 9.0),
              child: Text(
                userData.name,
                style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight:
                    FontWeight
                        .bold),
              ),
            ),
            RatingBar(
              ignoreGestures: true,
              initialRating:
              review.rating,
              direction:
              Axis.horizontal,
              itemCount: 5,
              itemSize: 24.0,
              itemPadding:
              const EdgeInsets.symmetric(
                  horizontal: 2.0),
              ratingWidget:
              RatingWidget(
                full: const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                half: const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                empty: const Icon(
                  Icons.star,
                  color: Colors.grey,
                ),
              ),
              onRatingUpdate:
                  (rating) {
                print(rating);
              },
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Padding(
          padding:
          const EdgeInsets.symmetric(
              horizontal: 9.0),
          child: Text(
            review.comment,
            style: const TextStyle(
                fontSize: 14.0),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
      ],
    );
  }
}

class LatestReviewItemSkeleton extends StatelessWidget {
  const LatestReviewItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9.0, top: 9.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 100.0, // Adjust width as necessary
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 24.0,
              child: Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[400]!,
            highlightColor: Colors.grey[200]!,
            period: const Duration(milliseconds: 800),
            child: Container(
              width: double.infinity,
              height: 14.0,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
      ],
    );
  }
}

Future<void> continueDialog(context, DocumentSnapshot pharmacyDoc, DocumentSnapshot drugDoc, LatLng userLocation, double radius) async {
  Map<String, dynamic> data = pharmacyDoc.data() as Map<String, dynamic>;
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Delivery :",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              if(data['DeliveryServiceAvailability'] && radius == 5.0)
                Row(
                  children: [
                    const Text(
                      "Available\t",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF008000)
                      ),
                    ),
                    Text(
                      "(Rs. ${data['DeliveryRate']} per km)",
                    )
                  ],
                ),
              if(data['DeliveryServiceAvailability'] && radius == 10.0)
                const Text(
                  "Not-Available",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFFF0F0F)
                  ),
                ),
              if(!data['DeliveryServiceAvailability'])
                const Text(
                  "Not-Available",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFFF0F0F)
                  ),
                ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
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
                const SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/order', arguments: {'selectedPharmacy': pharmacyDoc, 'searchedDrug': drugDoc, 'userLocation': userLocation, 'radius': radius});

                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0CAC8F),
                        //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                        side: const BorderSide(color: Color(0xFF0CAC8F))
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