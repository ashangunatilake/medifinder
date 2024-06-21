import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medifinder/services/database_services.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  bool readonly = true;

  Future<Map<String, dynamic>> _fetchUserData() async {
    final userDoc = await _userDatabaseServices.getCurrentUserDoc();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(10.0),
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No user data found.'));
                } else {
                  final userData = snapshot.data!;
                  nameController = TextEditingController(text: userData['Name']);
                  emailController = TextEditingController(text: userData['Email']);
                  numberController = TextEditingController(text: userData['Mobile']);

                  return ListView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10.0),
                          Text(
                            nameController.text,
                            style: const TextStyle(fontSize: 28.0, color: Colors.black),
                          ),
                          const SizedBox(height: 20.0),
                          const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 130.0, color: Colors.black),
                            radius: 75.0,
                          ),
                          const SizedBox(height: 30.0),
                          _buildTextFieldRow("Name", nameController),
                          const SizedBox(height: 10.0),
                          _buildTextFieldRow("Email", emailController, readonly: true),
                          const SizedBox(height: 10.0),
                          _buildTextFieldRow("Mobile No.", numberController),
                          const SizedBox(height: 30.0),
                          _buildActionButtons(context),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 2,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamedAndRemoveUntil(context, '/customer_home', (route) => false);
          if (n == 1) Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller, {bool readonly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 100.0,
            child: Text(label, style: const TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TextFormField(
              readOnly: readonly,
              controller: controller,
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (readonly)
          _buildButton(
            context,
            "Edit Profile",
                () {
              setState(() {
                readonly = false;
              });
            },
          ),
        if (readonly)
          _buildButton(
            context,
            "Change Password",
                () {
              // Add your change password logic here
            },
          ),
        if (readonly)
          _buildButton(
            context,
            "Log out",
                () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('isLoggedIn');
              Navigator.pushNamed(context, '/login');
            },
          ),
        if (!readonly)
          _buildButton(
            context,
            "Done",
                () {
              setState(() {
                readonly = true;
              });
            },
          ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                side: const BorderSide(color: Color(0xFF12E7C0)),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF12E7C0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
