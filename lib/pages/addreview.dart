import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReview extends StatefulWidget {
  const AddReview({super.key});

  @override
  State<AddReview> createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {

  TextEditingController reviewcontroller = TextEditingController();

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
                      height: 15.0,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
                height: 19.0
            ),
            Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 22.0,
                      ),
                      Text(
                        "Ratings :",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      RatingBar(
                        initialRating: 5,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 30.0,
                        itemPadding: EdgeInsets.only(right: 15.0),                        ratingWidget: RatingWidget(
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
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(9.0),
                              border: Border.all(
                                color: const Color(0xFFCCC9C9),
                              )
                          ),
                          child: TextField(
                            controller: reviewcontroller,
                            expands: true,
                            maxLines: null,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Write the review here",
                                hintStyle: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15.0,
                                  color: Color(0xFFC4C4C4),
                                )
                            ),
                          )
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/reviews');
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                  side: const BorderSide(color: Color(0xFF12E7C0))
                              ),
                              child: const Text(
                                "Submit Review",
                                style: TextStyle(
                                  color: Color(0xFF12E7C0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      )

                    ],

                  )
                )
            ),
            SizedBox(
              height: 10.0,
            ),
          ],

        )
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
