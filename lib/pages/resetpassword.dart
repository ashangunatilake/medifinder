import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/snackbars/snackbar.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  @override
  Widget build(BuildContext context) {
    String email = "";
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      email = args['email'];
    } else {
      throw Exception('Something went wrong.');
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Reset Password"),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10.0,),
                    Image(
                      image: AssetImage('assets/images/resetpassword.png')
                    ),
                    const SizedBox(height: 10.0,),
                    Text(
                      "Password Reset Email Sent",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                    const SizedBox(height: 20.0,),
                    Text(
                      "We have sent you a secure link to reset your password. Please check your email $email",
                      style: TextStyle(
                          fontSize: 14.0
                      ),
                    ),
                    const SizedBox(height: 20.0,),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(218, 3, 240, 212),
                            ),
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0,),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                  Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Email sent successfully", context: context));
                                } on FirebaseAuthException catch (e) {
                                  print(e.code);
                                }
                              },
                              child: const Text(
                                "Resend Email",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF0386D0)
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0,),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}