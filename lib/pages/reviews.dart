import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  int selected = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
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
                )
              )
            ),
            SizedBox(
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
                        child: Text(
                          "Newest",
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black
                          ),
                        ),
                      )
                  ),
                  SizedBox(
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
                        child: Text(
                          "Highest",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                      )
                  ),
                  SizedBox(
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
                        child: Text(
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
                child: ListView(
                  reverse: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
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
                            ),
                            const SizedBox(
                                height: 17.0
                            ),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
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
                            ),
                            const SizedBox(
                                height: 17.0
                            ),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
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
                            ),
                            const SizedBox(
                                height: 17.0
                            ),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
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
                            ),
                            const SizedBox(
                                height: 17.0
                            ),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold
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
                            ),
                            const SizedBox(
                                height: 17.0
                            ),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addreview');
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

Color getColor(int num, int selected){
  if (selected == num)
  {
    return Color(0xFFCCC9C9);
  }
  else
  {
    return Colors.white;
  }
}
