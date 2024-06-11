import 'package:flutter/material.dart';
import 'package:medifinder/pages/pharmacy/inventory.dart';
import 'package:medifinder/pages/pharmacy/orders.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  double _deviceHeight = 0;
  double _deviceWidth = 0;
  int _selectedIndex = 0;
  bool _isEditing = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _openHoursController = TextEditingController();
  TextEditingController _contactController = TextEditingController();

  Future<Map<String, dynamic>> _fetchPharmacyData() async {
    final userDoc = await _pharmacyDatabaseServices.getCurrentPharmacyDoc();
    return userDoc.data() as Map<String, dynamic>;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Inventory()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Orders()));
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(21, 201, 180, 1),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPharmacyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var pharmacyData = snapshot.data!;
            _nameController.text = pharmacyData['Name'];
            _emailController.text = pharmacyData['Address'];
            _openHoursController.text = pharmacyData['HoursOfOperation'];
            _contactController.text = pharmacyData['ContactNo'];

            return SingleChildScrollView(
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
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
            _profileDetailRow('Email', _emailController),
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
