import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {

  String deliver = "Meet at pharmacy";
  XFile? _image;
  final picker = ImagePicker();

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.name);
      }
    });
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.name);
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text("Gallery"),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text("Camera"),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Medicine Name",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              margin: const EdgeInsets.only(left:10.0, right: 10.0),
              padding: const EdgeInsets.only(left:10.0, right: 10.0),
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
                    height: 31.0,
                  ),
                  Text(
                    "Delivery Method",
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                  SizedBox(
                    height: 19.0,
                  ),
                  DropdownButton(
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "Meet at pharmacy",
                          style: TextStyle(
                            fontSize: 14.0
                          ),
                        ),
                        value: "Meet at pharmacy",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Deliver",
                          style: TextStyle(
                              fontSize: 14.0
                          ),
                        ),
                        value: "Deliver",
                      ),
                    ],
                    isExpanded: true,
                    onChanged: (String? selectedValue) {
                      setState(() {
                        deliver = selectedValue!;
                      }
                      );
                    },
                    value: deliver,
                  ),
                  SizedBox(
                    height: 19.0,
                  ),
                  Text(
                    "Prescription",
                    style: TextStyle(
                        fontSize: 18.0
                    ),
                  ),
                  SizedBox(
                    height: 19.0
                  ),
                  GestureDetector(
                    onTap: showOptions,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          border: Border.all(color: Color(0xFFC4C4C4)),
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x40FFFFFF),
                                blurRadius: 4.0,
                                offset: Offset(0, 4)
                            )
                          ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _image == null ? Text(
                            "Upload prescription",
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ) : Expanded(
                            child: Text(
                              _image!.name,
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.upload,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 85.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/activities');
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12E7C0),
                              //padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                              side: const BorderSide(color: Color(0xFF12E7C0))
                          ),
                          child: const Text(
                            "Place Order",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 85.0,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 27.0
                  )
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
