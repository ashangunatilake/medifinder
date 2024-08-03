import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:medifinder/validators/validation.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(child: SizedBox()),
                Container(
                  padding: const EdgeInsets.all(10.0),
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
                      const SizedBox(height: 20.0,),
                      Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      const Text(
                        "Don't worry we will help you to recover your account. Enter your email and we will send you a password reset link.",
                        style: TextStyle(
                          fontSize: 14.0
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      TextFormField(
                        validator: (value) => Validator.validateEmail(emailController.text),
                        controller: emailController,
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
                            labelText: "Email",
                            hintText: "Email",
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
                      const SizedBox(height: 30.0,),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: ()
                              {
                                FocusScope.of(context).unfocus();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  Navigator.pop(context);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                  side: const BorderSide(color: Color(0xFF12E7C0))
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Color(0xFF12E7C0),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                                    Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Email sent successfully", context: context));
                                    Navigator.pushNamed(context, '/resetpassword', arguments: {'email': emailController.text});
                                  } on FirebaseAuthException catch (e) {
                                    print(e.code);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(218, 3, 240, 212),
                                  padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0)
                              ),
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

