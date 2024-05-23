// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:medifinder/pages/inventory.dart';

// class RegisterPage extends StatelessWidget {
//   double _deviceHeight = 0;
//   double _deviceWidth = 0;
//   int _selectIndex = 0;

//   void _onItemTapped(BuildContext context, int index) {
//     //Implement logic to navigate different pages.
//     if (index == 0) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => Inventory()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _deviceHeight = MediaQuery.of(context).size.height;
//     _deviceWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(21, 201, 180, 1),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           SizedBox(
//             height: _deviceHeight * 0.1,
//             child: Container(),
//           ),
//           _avatarWidget()
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectIndex,
//         onTap: (index) =>
//             _onItemTapped(context, index), // Pass the context here,
//         selectedItemColor: const Color.fromRGBO(62, 221, 170, 1),

//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "Inventory",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Orders",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//           )
//         ],
//       ),
//     );
//   }

//   Widget _avatarWidget() {
//     double _circleD = _deviceHeight * 0.14;
//     return Padding(
//       padding: const EdgeInsets.only(top: 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Align(
//             alignment: Alignment.topCenter,
//             child: Column(
//               children: [
//                 Text(
//                   'Pharmacy Name',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Poppins',
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'City Name',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Poppins',
//                     fontSize: 24,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             height: _circleD,
//             width: _circleD,
//             margin: const EdgeInsets.only(top: 10),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(500),
//               image: const DecorationImage(
//                 image: AssetImage('assets/images/pharmacy_logo.png'),
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),
//           Container(
//             height: 486,
//             width: 390,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Name ',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 86),
//                         Text(
//                           'User name', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Username ',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 50),
//                         Text(
//                           '@Username', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Email ',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 90),
//                         Text(
//                           'name@domain.com', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Location',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 70),
//                         Text(
//                           'Add location', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Bio',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 110),
//                         Expanded(
//                           child: Text(
//                             'A description of the pharmacy', //Replace with the correct name
//                             style:
//                                 TextStyle(fontSize: 16, color: Colors.black54),
//                             softWrap: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Open Hours',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 50),
//                         Text(
//                           '10.00 am - 9.00 pm', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Text(
//                           'Contact No.',
//                           style: TextStyle(fontSize: 16, color: Colors.black),
//                         ),
//                         SizedBox(width: 50),
//                         Text(
//                           'Add Number', //Replace with the correct name
//                           style: TextStyle(fontSize: 16, color: Colors.black54),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 90),
//                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           // IMPLEMENT THE ACTION
//                         },
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all<Color>(
//                               Color.fromRGBO(21, 201, 180,
//                                   1)), // Change the background color of the button
//                           foregroundColor: MaterialStateProperty.all<Color>(
//                               Colors
//                                   .white), // Change the text color of the button
//                         ),
//                         child: Text('Edit Profile'),
//                       ),

//                       SizedBox(width: 50), // Add space between buttons
//                       OutlinedButton(
//                         onPressed: () {
//                           // IMPLEMENT THE ACTION
//                         },
//                         style: ButtonStyle(
//                           foregroundColor: MaterialStateProperty.all<Color>(
//                               Color.fromRGBO(21, 201, 180, 1)),
//                           side: MaterialStateProperty.all<BorderSide>(
//                             BorderSide(color: Color.fromRGBO(21, 201, 180, 1)),
//                           ),
//                         ),
//                         child: Text('Save Changes'),
//                       ),
//                     ]),
//                   ],
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:medifinder/pages/inventory.dart';
import 'package:medifinder/pages/orders.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  double _deviceHeight = 0;
  double _deviceWidth = 0;
  int _selectedIndex = 0;
  bool _isEditing = false;

  TextEditingController _nameController =
      TextEditingController(text: 'Pharmacy Name');
  TextEditingController _usernameController =
      TextEditingController(text: '@Username');
  TextEditingController _emailController =
      TextEditingController(text: 'name@domain.com');
  TextEditingController _locationController =
      TextEditingController(text: 'Add location');
  TextEditingController _bioController =
      TextEditingController(text: 'A description of the pharmacy');
  TextEditingController _openHoursController =
      TextEditingController(text: '10.00 am - 9.00 pm');
  TextEditingController _contactController =
      TextEditingController(text: 'Add Number');

  void _onItemTapped(int index) {
    // Implement logic to navigate different pages.
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Inventory()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Orders()));
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(21, 201, 180, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: _deviceHeight * 0.1,
                child: Container(),
              ),
              _avatarWidget(),
              SizedBox(height: 20),
              _profileDetails(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        //There's a little issue in changing the color of the icon. Check it******
        selectedItemColor: const Color.fromRGBO(62, 221, 170, 1),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? const Color.fromRGBO(62, 221, 170, 1)
                  : Colors.grey,
            ),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _avatarWidget() {
    double _circleD = _deviceHeight * 0.14;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  'Pharmacy Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'City Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: _circleD,
            width: _circleD,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(500),
              image: const DecorationImage(
                image: AssetImage('assets/images/pharmacy_logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDetails() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileDetailRow('Name', _nameController),
            SizedBox(height: 20),
            _profileDetailRow('Username', _usernameController),
            SizedBox(height: 20),
            _profileDetailRow('Email', _emailController),
            SizedBox(height: 20),
            _profileDetailRow('Location', _locationController),
            SizedBox(height: 20),
            _profileDetailRow('Bio', _bioController, isMultiLine: true),
            SizedBox(height: 20),
            _profileDetailRow('Open Hours', _openHoursController),
            SizedBox(height: 20),
            _profileDetailRow('Contact No.', _contactController),
            SizedBox(height: 20),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _profileDetailRow(String label, TextEditingController controller,
      {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          '$label ',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: controller,
                  maxLines: isMultiLine ? null : 1,
                  decoration: InputDecoration(
                    hintText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : Text(
                  controller.text,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromRGBO(21, 201, 180, 1)),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
        ),
      ],
    );
  }
}
