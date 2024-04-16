import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:medifinder/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email = "", password = "";
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e) {
      if (e.code == "user-not-found" || e.code == "wrong-password")
        {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(13.0, 22.0, 0, 50.0),
                    child: Text(
                      "Error",
                      style: TextStyle(
                        fontSize: 20.0,
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(13.0, 0, 0, 20.0),
                    child: Text(
                      "Incorrect Email or Password",
                      style: TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                  )
                ],
              )
          )
          );
        }
    }
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
                image: AssetImage('assets/background.png'),
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
                margin:const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                width: double.infinity,
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
                                            return 'Please Enter E-mail';
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
                            const SizedBox(height: 27.0),
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
                              text: "Forget me",
                              style: const TextStyle(
                                color: Color(0xFF0386D0),
                                fontSize: 14.0,
                              ),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                                              //onTap logic
                              }
                              )),
          
                                ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: ()
                              {
          
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF12E7C0),
                                padding: const EdgeInsets.fromLTRB(54.0, 13.0, 54.0, 11.0)
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFFFF),
                              padding: const EdgeInsets.fromLTRB(54.0, 13.0, 54.0, 11.0),
                              side: const BorderSide(color: Color(0xFF12E7C0))
                            ),
                            child: const Text(
                              "Register",
                                style: TextStyle(
                                  color: Color(0xFF12E7C0),
                                ),
                            ),
                        )
          
                        ],
                        ),
                      ),
                      const SizedBox(
                        height: 74.0,
                      )
                    ],
                  ),
                ),
          
          

                  ),

          
            ],
          ),
        ]
        ),
        )
    );
  }
}

