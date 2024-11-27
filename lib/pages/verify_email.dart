import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/controllers/verifyemailcontroller.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String email = "";

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      email = args['email'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController(context));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white38,
        elevation: 0.0,
        leading: BackButton(
          onPressed: () => {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)
          },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SafeArea(
              child: Container(
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
                    const Image(
                      image: AssetImage('assets/images/notes-email.png'),
                      width: 150,
                    ),
                    const SizedBox(height: 20.0,),
                    const Text(
                      "Verify your email address!",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      )
                    ),
                    const SizedBox(height: 10.0,),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16.0
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    const Text(
                      "Congratulations! Your account has been created. Verify your email address to start using MediFinder.",
                      textAlign: TextAlign.center,
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
                              controller.checkEmailVerificationStatus();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0CAC8F),
                            ),
                            child: const Text(
                              "Continue",
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
                                controller.sendEmailVerification();
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
