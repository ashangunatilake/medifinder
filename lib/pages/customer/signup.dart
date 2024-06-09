import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/pages/locationpicker.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/pharmacy_model.dart';
import '../../services/database_services.dart';

enum Delivery {available, notavailable}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final geo = GeoFlutterFire();
  bool isPressedUser = true;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  TextEditingController openingtimecontroller = TextEditingController();
  TextEditingController closingtimecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TimeOfDay openingTime = TimeOfDay.now();
  TimeOfDay closingTime = TimeOfDay.now();
  LatLng location = LatLng(0, 0);
  Delivery? selected = Delivery.available;
  bool deliveryAvailable = true;
  final _formkey = GlobalKey<FormState>();

  // Future<void> storeUserData(String userID) async {
  //   final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   UserModel user = UserModel(
  //     id: userID,
  //     name: namecontroller.text,
  //     email: emailcontroller.text,
  //     mobile: mobilecontroller.text,
  //   );
  //   String userdata = jsonEncode(user);
  //   sharedPreferences.setString('userdata', userdata);
  // }

  userSignUp() async {

    if (!_formkey.currentState!.validate()) {
      return;
    }

    String name = namecontroller.text;
    String email = emailcontroller.text;
    String mobile = mobilecontroller.text;
    String password = passwordcontroller.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        mobile: mobile,
      );
      await _userDatabaseServices.addUser(userCredential.user!.uid, user);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'customer');
      //storeUserData(userCredential.user!.uid);
      print("User account created");
      Navigator.pushNamed(context, "/login");
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == "email-already-in-use") {
        print("Email already in use");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(13.0, 22.0, 0, 50.0),
                  child: Text(
                    "Error",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(13.0, 0, 0, 20.0),
                  child: Text(
                    "Email already in use",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  pharmacySignUp() async {
    String name = namecontroller.text.trim();
    String email = emailcontroller.text.trim();
    String mobile = mobilecontroller.text.trim();
    String operationHours = '${formatTimeOfDay(openingTime)} - ${formatTimeOfDay(closingTime)}';
    bool delivery = deliveryAvailable;
    GeoFirePoint pharmacyLocation = geo.point(latitude: location.latitude, longitude: location.longitude);
    String password = passwordcontroller.text;
    String confirmpassword = confirmpasswordcontroller.text;
    if (password != confirmpassword) {
      print("Passwords not same");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(13.0, 22.0, 0, 50.0),
                child: Text(
                  "Error",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(13.0, 0, 0, 20.0),
                child: Text(
                  "The password and confirm password fields do not match",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )
            ],
          ),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      PharmacyModel pharmacy = PharmacyModel(id: userCredential.user!.uid, name: name, address: email, contact: mobile, ratings: 0, isDeliveryAvailable: delivery, operationHours: operationHours, position: pharmacyLocation);
      print('User registered');
      await _pharmacyDatabaseServices.addPharmacy(userCredential.user!.uid, pharmacy);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'pharmacy');
      print("Pharmacy account created");
      Navigator.pushNamed(context, "/login");
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == "email-already-in-use") {
        print("Email already in use");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(13.0, 22.0, 0, 50.0),
                  child: Text(
                    "Error",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(13.0, 0, 0, 20.0),
                  child: Text(
                    "Email already in use",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  void getTime(String time) async{
    if (time == "Opening Time")
      {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.dial
        );
        if (selectedTime != null)
          {
            setState(() {
              openingTime = selectedTime;
              openingtimecontroller.text = "${openingTime.hour.toString()}:${openingTime.minute.toString().padLeft(2, "0")}";
            });
          }
      }
    else if (time == "Closing Time")
      {
        final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.dial
        );
        if (selectedTime != null)
        {
          setState(() {
            closingTime = selectedTime;
            closingtimecontroller.text = "${closingTime.hour.toString()}:${closingTime.minute.toString().padLeft(2, "0")}";
          });
        }
      }
  }

  Future<void> selectLocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPicker(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        location = result;
        locationcontroller.text = "(${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)})";
      });
    }
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
        child: ListView(
            reverse: false,
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
              Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 49.0,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "MEDIFINDER",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 40.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Your Instant Medicine Finder",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 46.0
                    ),
                    Container(
                      margin:const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                      width: MediaQuery.of(context).size.width - 20.0,
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
                          const SizedBox(height: 17.0,),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 13.0),
                            child: Text(
                              "Account Type",
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPressedUser = true;
                                      });
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent), // Remove default overlay color
                                      backgroundColor: MaterialStateProperty.all<Color>(isPressedUser ? const Color(0xFFE2D7D7): Colors.white), // Change background color based on pressed state
                                      shape: MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 68.0,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "User",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    )
                                ),
                                // const SizedBox(
                                //   width: 51.0,
                                // ),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPressedUser = false;
                                      });
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent), // Remove default overlay color
                                      backgroundColor: MaterialStateProperty.all<Color>(!isPressedUser ? const Color(0xFFE2D7D7): Colors.white), // Change background color based on pressed state
                                      shape: MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(
                                          Icons.local_pharmacy,
                                          size: 68.0,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "Pharmacy",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 26.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13.0),
                            child: Form(
                                key: _formkey,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Name",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      TextFormField(
                                        validator: (value) => Validator.validateEmptyText("Name", value),
                                        controller: namecontroller,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCCC9C9),
                                            ),
                                            borderRadius: BorderRadius.circular(9.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCCC9C9),
                                            ),
                                            borderRadius: BorderRadius.circular(9.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCCC9C9),
                                            ),
                                            borderRadius: BorderRadius.circular(9.0),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF9F9F9),
                                          hintText: "Name",
                                          hintStyle: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 15.0,
                                            color: Color(0xFFC4C4C4),
                                          ),
                                          suffixIcon: Icon(
                                            Icons.person,
                                            color: Color(0xFFC4C4C4),
                                          )
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Text(
                                        "Email Address",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      TextFormField(
                                        validator: (value) => Validator.validateEmptyText("Email Address", value),
                                        controller: emailcontroller,
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF9F9F9),
                                            hintText: "Email Address",
                                            hintStyle: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 15.0,
                                              color: Color(0xFFC4C4C4),
                                            ),
                                            suffixIcon: Icon(
                                              Icons.email_outlined,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      if (!isPressedUser) Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Opening Time",
                                            style: TextStyle(
                                              fontSize: 15.0
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          TextFormField(
                                            validator: (value) => Validator.validateEmptyText("Opening Time", value),
                                            controller: openingtimecontroller,
                                            readOnly: true,
                                            onTap: () {
                                              getTime("Opening Time");
                                            },
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                filled: true,
                                                fillColor: const Color(0xFFF9F9F9),
                                                hintText: "Opening Time",
                                                hintStyle: const TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.0,
                                                  color: Color(0xFFC4C4C4),
                                                ),
                                                suffixIcon: Icon(
                                                  Icons.timelapse,
                                                  color: Color(0xFFC4C4C4),
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          const Text(
                                            "Closing Time",
                                            style: TextStyle(
                                                fontSize: 15.0
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          TextFormField(
                                            validator: (value) => Validator.validateEmptyText("Closing Time", value),
                                            controller: closingtimecontroller,
                                            onTap: () {
                                              getTime("Closing Time");
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                filled: true,
                                                fillColor: const Color(0xFFF9F9F9),
                                                hintText: "Closing Time",
                                                hintStyle: const TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.0,
                                                  color: Color(0xFFC4C4C4),
                                                ),
                                                suffixIcon: Icon(
                                                  Icons.timelapse,
                                                  color: Color(0xFFC4C4C4),
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          const Text(
                                            "Delivery",
                                            style: TextStyle(
                                                fontSize: 15.0
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Radio<Delivery>(
                                                    value: Delivery.available,
                                                    groupValue: selected,
                                                    onChanged: (Delivery? value) {
                                                      setState(() {
                                                        selected = value;
                                                        deliveryAvailable = true;
                                                      });
                                                    }
                                                  ),
                                                  Text("Available", style: TextStyle(fontSize: 15.0),)
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Radio<Delivery>(
                                                        value: Delivery.notavailable,
                                                        groupValue: selected,
                                                        onChanged: (Delivery? value) {
                                                          setState(() {
                                                            selected = value;
                                                            deliveryAvailable = false;
                                                          });
                                                        }
                                                    ),
                                                    Text("Not available", style: TextStyle(fontSize: 15.0),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5.0),
                                          const Text(
                                            "Location",
                                            style: TextStyle(
                                                fontSize: 15.0
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          TextFormField(
                                            validator: (value) => Validator.validateEmptyText("Location", value),
                                            controller: locationcontroller,
                                            onTap: () {
                                              selectLocation(context);
                                            },
                                            readOnly: true,
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFCCC9C9),
                                                  ),
                                                  borderRadius: BorderRadius.circular(9.0),
                                                ),
                                                filled: true,
                                                fillColor: const Color(0xFFF9F9F9),
                                                hintText: "Location",
                                                hintStyle: const TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 15.0,
                                                  color: Color(0xFFC4C4C4),
                                                ),
                                                suffixIcon: Icon(
                                                  Icons.location_on,
                                                  color: Color(0xFFC4C4C4),
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                        ],
                                      ),
                                      const Text(
                                        "Mobile Number",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      TextFormField(
                                        validator: (value) => Validator.validateMobileNumber(value),
                                        controller: mobilecontroller,
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF9F9F9),
                                            hintText: "Mobile Number",
                                            hintStyle: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 15.0,
                                              color: Color(0xFFC4C4C4),
                                            ),
                                            suffixIcon: Icon(
                                              Icons.phone_android_outlined,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Text(
                                        "Password",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      TextFormField(
                                        validator: (value) => Validator.validatePassword(value),
                                        controller: passwordcontroller,
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF9F9F9),
                                            hintText: "Password",
                                            hintStyle: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 15.0,
                                              color: Color(0xFFC4C4C4),
                                            ),
                                            suffixIcon: Icon(
                                              Icons.lock_outline,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                        obscureText: true,
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Text(
                                        "Confirm Password",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      TextFormField(
                                        validator: (value) => Validator.validateConfirmPassword(passwordcontroller.text, value),
                                        controller: confirmpasswordcontroller,
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Color(0xFFCCC9C9),
                                              ),
                                              borderRadius: BorderRadius.circular(9.0),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF9F9F9),
                                            hintText: "Password",
                                            hintStyle: const TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 15.0,
                                              color: Color(0xFFC4C4C4),
                                            ),
                                            suffixIcon: Icon(
                                              Icons.lock_outline,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                        obscureText: true,
                                      ),
                                    ]
                                )
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if(isPressedUser) {
                                    await userSignUp();
                                  }
                                  if(!isPressedUser) {
                                    await pharmacySignUp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF12E7C0),
                                    padding: const EdgeInsets.fromLTRB(54.0, 13.0, 54.0, 11.0)
                                ),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12.0),
                        ],
                      ),
                    )

                  ]
              ),
            ]
        ),
      ),
    );
  }
}

String formatTimeOfDay(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

