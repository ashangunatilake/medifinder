import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController nameController = TextEditingController(text: "Ashan Gunatilake");
  TextEditingController emailController = TextEditingController(text: "manuruddhaashan@gmail.com");
  TextEditingController numberController = TextEditingController(text: "0718764732");
  bool readonly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,),
        ),
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.fromLTRB(10.0,10.0,10.0,10.0),
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
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      nameController.text,
                      style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        size: 130.0,
                        color: Colors.black,
                      ),
                      radius: 75.0,

                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.0,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                fontSize: 16.0
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: readonly,
                              controller: nameController,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.0,
                            child: Text(
                              "Email",
                              style: TextStyle(
                                  fontSize: 16.0
                              )
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: emailController,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.0,
                            child: Text(
                                "Mobile No.",
                                style: TextStyle(
                                    fontSize: 16.0
                                )
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: readonly,
                              controller: numberController,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    readonly ?
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        readonly = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFFFF),
                                        padding: const EdgeInsets.fromLTRB(
                                            45.0, 13.0, 45.0, 11.0),
                                        side: const BorderSide(
                                            color: Color(0xFF12E7C0))
                                    ),
                                    child: const Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                        color: Color(0xFF12E7C0),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {

                                    },
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                    side: const BorderSide(
                                      color: Color(0xFF12E7C0))
                                    ),
                                    child: const Text(
                                      "Change Password",
                                      style: TextStyle(
                                      color: Color(0xFF12E7C0),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {

                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFFFFF),
                                        padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                        side: const BorderSide(
                                            color: Color(0xFF12E7C0))
                                    ),
                                    child: const Text(
                                      "Log out",
                                      style: TextStyle(
                                        color: Color(0xFF12E7C0),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                        ],
                      ) :
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  readonly = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  padding: const EdgeInsets.fromLTRB(
                                      45.0, 13.0, 45.0, 11.0),
                                  side: const BorderSide(
                                      color: Color(0xFF12E7C0))
                              ),
                              child: const Text(
                                "Done",
                                style: TextStyle(
                                  color: Color(0xFF12E7C0),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                      SizedBox(
                        height: 20.0,
                      ),


                  ],
                ),
              ]
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          )
        ],
        currentIndex: 2,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamed(context, '/home');
          if (n == 1) Navigator.pushNamed(context, '/activities');
        },
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}



