import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/models/user_model.dart';
import 'package:medifinder/services/database_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final UserDatabaseServices _databaseServices = UserDatabaseServices();
  bool isPressedUser = false;
  bool isPressedPharmacy = false;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  userSignUp() async {
    String name = namecontroller.text;
    String email = emailcontroller.text;
    String mobile = mobilecontroller.text;
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

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        mobile: mobile,
      );
      _databaseServices.addUser(userCredential.user!.uid, user);
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

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
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
                                        isPressedUser = !isPressedUser;
                                        isPressedPharmacy = false;
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
                                        isPressedPharmacy = !isPressedPharmacy;
                                        isPressedUser = false;
                                      });
                                    },
                                    style: ButtonStyle(
                                      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent), // Remove default overlay color
                                      backgroundColor: MaterialStateProperty.all<Color>(isPressedPharmacy ? const Color(0xFFE2D7D7): Colors.white), // Change background color based on pressed state
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            borderRadius: BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: const Color(0xFFCCC9C9),
                                            )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(17.0, 12.0, 0, 12.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please Enter Name';
                                                    }
                                                    return null;
                                                  },
                                                  controller: namecontroller,
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Name",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 15.0,
                                                        color: Color(0xFFC4C4C4),
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                              child: Icon(
                                                Icons.person,
                                                color: Color(0xFFC4C4C4),

                                              ),
                                            ),
                                          ],
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            borderRadius: BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: const Color(0xFFCCC9C9),
                                            )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(17.0, 12.0, 0, 12.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please Enter Email Address';
                                                    }
                                                    return null;
                                                  },
                                                  controller: emailcontroller,
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Email Address",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 15.0,
                                                        color: Color(0xFFC4C4C4),
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                              child: Icon(
                                                Icons.email_outlined,
                                                color: Color(0xFFC4C4C4),

                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Text(
                                        "Mobile Number",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            borderRadius: BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: const Color(0xFFCCC9C9),
                                            )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(17.0, 12.0, 0, 12.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please Enter Mobile Number';
                                                    }
                                                    return null;
                                                  },
                                                  controller: mobilecontroller,
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Mobile Number",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 15.0,
                                                        color: Color(0xFFC4C4C4),
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                              child: Icon(
                                                Icons.phone_android_outlined,
                                                color: Color(0xFFC4C4C4),

                                              ),
                                            ),
                                          ],
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            borderRadius: BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: const Color(0xFFCCC9C9),
                                            )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(17.0, 12.0, 0, 12.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please Enter Password';
                                                    }
                                                    return null;
                                                  },
                                                  controller: passwordcontroller,
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Password",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 15.0,
                                                        color: Color(0xFFC4C4C4),
                                                      )
                                                  ),
                                                  obscureText: true,
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: Color(0xFFC4C4C4),

                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Text(
                                        "Confirm Password",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF9F9F9),
                                            borderRadius: BorderRadius.circular(9.0),
                                            border: Border.all(
                                              color: const Color(0xFFCCC9C9),
                                            )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(17.0, 12.0, 0, 12.0),
                                                child: TextFormField(
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Please Enter Password';
                                                    }
                                                    return null;
                                                  },
                                                  controller: confirmpasswordcontroller,
                                                  decoration: const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Password",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 15.0,
                                                        color: Color(0xFFC4C4C4),
                                                      )
                                                  ),
                                                  obscureText: true,
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                              child: Icon(
                                                Icons.lock_outline,
                                                color: Color(0xFFC4C4C4),

                                              ),
                                            ),
                                          ],
                                        ),
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
                                onPressed: ()
                                {
                                  userSignUp();
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

