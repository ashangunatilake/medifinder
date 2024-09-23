import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:medifinder/snackbars/snackbar.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldpassowrdController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String oldpassword = oldpassowrdController.text;
    String newpassword = newpasswordController.text;
    User? currentUser = FirebaseAuth.instance.currentUser;
    try {
      var cred = EmailAuthProvider.credential(email: currentUser!.email!, password: oldpassword);
      await currentUser.reauthenticateWithCredential(cred).then((value) => currentUser.updatePassword(newpassword));
      Future.delayed(Duration.zero).then((value) => Snackbars.successSnackBar(message: "Password changed successfully", context: context));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == "invalid-credential") {
        Snackbars.errorSnackBar(message: "Invalid old password", context: context);
      }
      if (e.code == "too-many-requests") {
        Snackbars.errorSnackBar(message: "Too many tries. Try again later.", context: context);
      }
      if (e.code == "network-request-failed") {
        Snackbars.errorSnackBar(message: "Network error occured", context: context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    oldpassowrdController.dispose();
    newpasswordController.dispose();
    confirmpasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
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
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafeArea(child: SizedBox()),
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
                      TextFormField(
                        validator: (value) => Validator.validateEmptyText("Old password", oldpassowrdController.text),
                        controller: oldpassowrdController,
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
                            labelText: "Old password",
                            hintText: "Old password",
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
                      const SizedBox(height: 20.0,),
                      TextFormField(
                        validator: (value) => Validator.validatePassword(newpasswordController.text),
                        controller: newpasswordController,
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
                            labelText: "New password",
                            hintText: "New password",
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
                      const SizedBox(height: 20.0,),
                      TextFormField(
                        validator: (value) => Validator.validateConfirmPassword(newpasswordController.text, value),
                        controller: confirmpasswordController,
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
                            labelText: "Confirm new password",
                            hintText: "Confirm new password",
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
                                  //padding: const EdgeInsets.symmetric(vertical: 13.0),
                                  side: const BorderSide(color: Color(0xFF0CAC8F),)
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Color(0xFF0CAC8F),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                changePassword();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0CAC8F),
                                //padding: const EdgeInsets.symmetric(vertical: 13.0),
                              ),
                              child: const Text(
                                "Change Password",
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
