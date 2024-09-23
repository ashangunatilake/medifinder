import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:medifinder/models/user_review_model.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:shimmer/shimmer.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  int selected = 1;
  double overallRating = 0;
  late DocumentSnapshot pharmacyDoc;
  late Map<String, dynamic> data;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      pharmacyDoc = args['selectedPharmacy'] as DocumentSnapshot;
      data = pharmacyDoc.data() as Map<String, dynamic>;
      listenToOverallRating(pharmacyDoc.id);
    } else {
      // Handle the case where args are null (optional)
      // You might want to throw an error or use default values
    }
  }

  void listenToOverallRating(String pharmacyID) {
    _pharmacyDatabaseServices.getPharmacyDocReference(pharmacyID).snapshots().listen((snapshot) {
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
        title: Text("${pharmacyDoc["Name"]} - Reviews"),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
                child: SizedBox(
                  height: 21.0,
                )
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
                              data['Name'],
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    overallRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 24.0,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15.0,
                        )
                      ],
                    )
                )
            ),
            const SizedBox(
                height: 19.0
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 1;
                          });

                        },
                        autofocus: true,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getColor(1, selected),
                        ),
                        child: const Text(
                          "Newest",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                      )
                  ),
                  const SizedBox(
                    width: 17.0,
                  ),
                  Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 2;
                          });


                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getColor(2, selected),
                        ),
                        child: const Text(
                          "Highest",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                      )
                  ),
                  const SizedBox(
                    width: 17.0,
                  ),
                  Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selected = 3;
                          });

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getColor(3, selected),
                        ),
                        child: const Text(
                          "Lowest",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                      )
                  ),

                ],
              ),
            ),
            // SizedBox(
            //   height: 20.0,
            // ),
            Expanded(
                child: StreamBuilder(
                    stream: _pharmacyDatabaseServices.getPharmacyReviews(pharmacyDoc.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return const Column(
                                children: [
                                  ReviewItemSkeleton(),
                                ],
                              );
                            }
                        );
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No data available');
                      }
                      else{
                        List<UserReview> reviews = snapshot.data!.docs.map((doc) => doc.data()).toList();
                        if (selected == 1) {
                          reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                        }
                        if (selected == 2) {
                          reviews.sort((a, b) => b.rating.compareTo(a.rating));
                        }
                        if (selected == 3) {
                          reviews.sort((a, b) => a.rating.compareTo(b.rating));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            UserReview review = reviews[index];
                            print('Review Comment: ${review.comment}, Rating: ${review.rating}');
                            return FutureBuilder<DocumentSnapshot>(
                              future: _userDatabaseServices.getUserDoc(review.id),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Column(
                                      children: [
                                        ReviewItemSkeleton(),
                                        SizedBox(height: 20.0),
                                      ]
                                  );
                                }
                                if (userSnapshot.hasError) {
                                  return const ListTile(
                                    title: Text('Error loading data'),
                                  );
                                }
                                if (userSnapshot.hasData && userSnapshot.data != null) {
                                  UserModel userData = userSnapshot.data!.data() as UserModel;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: ReviewItem(userData: userData, review: review),
                                      ),
                                      const SizedBox(height: 20.0),
                                    ],
                                  );
                                }
                                // Handle the case where snapshot has no data
                                return const ListTile(
                                  title: Text('No data available'),
                                );
                              },
                            );
                          },
                        );
                      }

                    }
                )
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addreview', arguments: pharmacyDoc);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                          side: const BorderSide(color: Color(0xFF0CAC8F))
                      ),
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
            ),
            const SizedBox(
              height: 10.0,
            ),
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
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.person),
      //         label: "Profile"
      //     )
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

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    super.key,
    required this.userData,
    required this.review,
  });

  final UserModel userData;
  final UserReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userData.name, // Assuming UserModel has a 'name' property
                  style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                RatingBar(
                  ignoreGestures: true,
                  initialRating: review.rating,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 24.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                  ratingWidget: RatingWidget(
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
                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 17.0),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

class ReviewItemSkeleton extends StatelessWidget {
  const ReviewItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95, // Set a shorter width
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3, // Reduced width for the name
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    Row(
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
                  ],
                ),
              ),
              const SizedBox(height: 17.0),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.87, // Adjusted to be shorter
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

Color getColor(int num, int selected){
  if (selected == num)
  {
    return const Color(0xFFCCC9C9);
  }
  else
  {
    return Colors.white;
  }
}