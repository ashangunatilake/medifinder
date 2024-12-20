import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:medifinder/pages/customer/customerview.dart';
import 'package:medifinder/pages/customer/signup.dart';
import 'package:medifinder/pages/pharmacy/pharmacyview.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  PushNotifications pushNotifications = PushNotifications();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.beat(
              color: Colors.white,
              size: 100.0
            ),
          );
        }
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        Navigator.pushNamed(context, "/emailverification", arguments: {'email': email});
      }
      else {
        print("User logged in");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        String userUid = userCredential.user!.uid;
        String userRole = await _userDatabaseServices.getUserRole(userUid);
        await prefs.setString('role', userRole);
        if(userRole == 'customer') {
          await pushNotifications.addDeviceToken(userRole, userUid);
          await prefs.setStringList('notifications', []);
          Navigator.pop(context);
          Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Login successful", context: context));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CustomerView()), (route) => false);
        }
        else if(userRole == 'pharmacy') {
          await pushNotifications.addDeviceToken(userRole, userUid);
          await prefs.setStringList('notifications', []);
          Navigator.pop(context);
          Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Login successful", context: context));
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PharmacyView()), (route) => false);
        }
        else
        {
          throw Exception('Error logging in.');
        }
      }
    } on FirebaseAuthException catch(e) {
      Navigator.pop(context);
      print(e.code);
      if (e.code == "user-not-found" || e.code == "wrong-password" || e.code == "invalid-credential") {
        Snackbars.errorSnackBar(message: "Incorrect email or password", context: context);
      }
      if (e.code == "too-many-requests") {
        Snackbars.errorSnackBar(message: "Too many requests. Try again later", context: context);
      }
      if (e.code == "network-request-failed") {
        Snackbars.errorSnackBar(message: "Network error occured", context: context);
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
    return content();
  }

  Widget content() {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background2.png'),
              fit: BoxFit.cover,),
          ),
          child: ListView(
              reverse: false,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 200.0,
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
                      height: 53.0,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 16.0),
                              margin: const EdgeInsets.only(bottom: 21.0),
                              width: double.infinity,
                              child: const Text(
                                "Please login to your account to continue : ",
                                style: TextStyle(
                                  overflow: TextOverflow.clip,
                                  fontSize: 14.0,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Form(
                                key: _formkey,
                                child: Column(
                                    children: [
                                      TextFormField(
                                        validator: (value) => Validator.validateEmptyText("Email Address", value),
                                        controller: emailcontroller,
                                        decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0),
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
                                            suffixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                      ),
                                      const SizedBox(height: 27.0),
                                      TextFormField(
                                        validator: (value) => Validator.validateEmptyText("Password", value),
                                        controller: passwordcontroller,
                                        decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0),
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
                                            suffixIcon: const Icon(
                                              Icons.lock_outline,
                                              color: Color(0xFFC4C4C4),
                                            )
                                        ),
                                        obscureText: true,
                                      ),
                                    ]
                                )
                            ),
                            const SizedBox(
                                height: 26.0
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 7.0, bottom: 34.0,),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                      text: TextSpan(
                                          text: "Forgot password?",
                                          style: const TextStyle(
                                            color: Color(0xFF0386D0),
                                            fontSize: 14.0,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(context, '/forgotpassword');
                                            }
                                      )
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      userLogin();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0CAC8F),
                                        padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0)
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: ()
                                    {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFFFF),
                                        padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                        side: const BorderSide(color: Color(0xFF0CAC8F))
                                    ),
                                    child: const Text(
                                      "Register",
                                      style: TextStyle(
                                        color: Color(0xFF0CAC8F),
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30.0,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0,)
                  ],
                ),
              ]
          ),
        )
    );
  }
}

