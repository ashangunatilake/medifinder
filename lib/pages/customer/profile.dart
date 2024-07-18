import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/models/user_model.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  late DocumentSnapshot<Map<String, dynamic>> userDoc;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  final _formkey = GlobalKey<FormState>();
  bool enabled = false;
  bool nameFieldModified = false;
  bool mobileFieldModified = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    numberController = TextEditingController();

    nameController.addListener(() {
      setState(() {
        nameFieldModified = true;
      });
    });
    numberController.addListener(() {
      setState(() {
        mobileFieldModified = true;
      });
    });

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      userDoc = await _userDatabaseServices.getCurrentUserDoc() as DocumentSnapshot<Map<String, dynamic>>;
      final userData = userDoc.data();
      if (userData != null) {
        setState(() {
          nameController.text = userData['Name'];
          emailController.text = userData['Email'];
          numberController.text = userData['Mobile'];
        });
      }
    } catch (e) {
      // Handle error
      print('Error fetching user data: $e');
    }
    setState(() {
      loaded = true;
    });
  }

  UserModel _updateUserProfile(DocumentSnapshot<Map<String, dynamic>> doc) {
    final UserModel currentUser = UserModel.fromSnapshot(doc);
    UserModel updatedUser = currentUser;

    if (nameFieldModified) {
      updatedUser = updatedUser.copyWith(name: nameController.text);
    }
    if (mobileFieldModified) {
      updatedUser = updatedUser.copyWith(mobile: numberController.text);
    }

    return updatedUser;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    numberController.dispose();
    super.dispose();
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
            child: loaded ? ListView(
              children: [
                Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10.0),
                      Text(
                        userDoc['Name'],
                        style: const TextStyle(fontSize: 28.0, color: Colors.black),
                      ),
                      const SizedBox(height: 20.0),
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 130.0, color: Colors.black),
                        radius: 75.0,
                      ),
                      const SizedBox(height: 30.0),
                      _buildTextFieldRow("Name", nameController, enabled),
                      const SizedBox(height: 10.0),
                      _buildTextFieldRow("Email", emailController, false),
                      const SizedBox(height: 10.0),
                      _buildTextFieldRow("Mobile No.", numberController, enabled),
                      const SizedBox(height: 30.0),
                      _buildActionButtons(context),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ],
            ) : const Center(child: CircularProgressIndicator(),),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Activities"),
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

  Widget _buildTextFieldRow(String label, TextEditingController controller, bool enabled) {
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
              enabled: enabled,
              controller: controller,
              validator: (value) => (label == "Name") ? Validator.validateEmptyText(label, value) : (label == "Mobile No." ? Validator.validateMobileNumber(value) : null),
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
        if (!enabled)
          _buildButton(
            context,
            "Edit Profile",
                () {
              setState(() {
                enabled = true;
              });
            },
          ),
        if (!enabled)
          _buildButton(
            context,
            "Change Password",
                () {
              Navigator.pushNamed(context, '/changepassword');
            },
          ),
        if (!enabled)
          _buildButton(
            context,
            "Log out",
                () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('isLoggedIn');
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        if (enabled)
          _buildButton(
            context,
            "Done",
                () async {
              if (!_formkey.currentState!.validate()) {
                return;
              }
              await _userDatabaseServices.updateUser(userDoc.id, _updateUserProfile(userDoc));
              print('Updated successfully!');
              // setState(() {
              //   enabled = false;
              //   nameFieldModified = false;
              //   mobileFieldModified = false;
              // });
              Snackbars.successSnackBar(message: "Updated successfully", context: context);
              Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
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