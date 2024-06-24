import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import 'package:medifinder/pages/locationpicker.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PharmacyProfile extends StatefulWidget {
  const PharmacyProfile({super.key});

  @override
  State<PharmacyProfile> createState() => _PharmacyProfileState();
}

class _PharmacyProfileState extends State<PharmacyProfile> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  late DocumentSnapshot<Map<String, dynamic>> pharmacyDoc;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late TextEditingController openingTimeController;
  late TextEditingController closingTimeController;
  late TextEditingController locationController;
  bool enabled = false;
  bool nameFieldModified = false;
  bool mobileFieldModified = false;
  bool timeFieldModified = false;
  bool locationFieldModified = false;
  bool loaded = false;
  LatLng location = LatLng(0, 0);
  late GeoPoint point;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    numberController = TextEditingController();
    openingTimeController = TextEditingController();
    closingTimeController = TextEditingController();
    locationController = TextEditingController();

    _fetchUserData();

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
    locationController.addListener(() {
      if (locationController.text != "(${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)})")
      setState(() {
        locationFieldModified = true;
      });
    });
    openingTimeController.addListener(() {
      setState(() {
        timeFieldModified = true;
      });
    });
    closingTimeController.addListener(() {
      setState(() {
        timeFieldModified = true;
      });
    });


  }

  Future<void> _fetchUserData() async {
    try {
      pharmacyDoc = await _pharmacyDatabaseServices.getCurrentPharmacyDoc() as DocumentSnapshot<Map<String, dynamic>>;
      final userData = pharmacyDoc.data();
      if (userData != null) {
        setState(() {
          nameController.text = userData['Name'];
          emailController.text = userData['Address'];
          numberController.text = userData['ContactNo'];
          openingTimeController.text = userData['HoursOfOperation'].split(' - ')[0];
          closingTimeController.text = userData['HoursOfOperation'].split(' - ')[1];
          point = userData['Position']['geopoint'];
          locationController.text = "(${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)})";
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

  void getTime(String time) async{

    if (time == "Opening Time")
    {
      TimeOfDay openingTime = TimeOfDay.now();
      final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.dial
      );
      if (selectedTime != null)
      {
        setState(() {
          openingTime = selectedTime;
          openingTimeController.text = formatTimeOfDay(openingTime);
        });
      }
    }
    else if (time == "Closing Time")
    {
      TimeOfDay closingTime = TimeOfDay.now();
      final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.dial
      );
      if (selectedTime != null)
      {
        setState(() {
          closingTime = selectedTime;
          closingTimeController.text = formatTimeOfDay(closingTime);
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
        locationController.text = "(${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)})";
      });
    }
  }

  PharmacyModel _updatePharmacyProfile(DocumentSnapshot<Map<String, dynamic>> doc) {
    final PharmacyModel currentUser = PharmacyModel.fromSnapshot(doc);
    PharmacyModel updatedUser = currentUser;

    if (nameFieldModified) {
      updatedUser = updatedUser.copyWith(name: nameController.text);
    }
    if (mobileFieldModified) {
      updatedUser = updatedUser.copyWith(contact: numberController.text);
    }
    if (timeFieldModified) {
      String operationHours = '${openingTimeController.text} - ${closingTimeController.text}';
      updatedUser = updatedUser.copyWith(operationHours: operationHours);
    }
    if (locationFieldModified) {
      GeoFirePoint pharmacyLocation = geo.point(latitude: location.latitude, longitude: location.longitude);
      updatedUser = updatedUser.copyWith(position: pharmacyLocation);
    }
    return updatedUser;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    numberController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    locationController.dispose();
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10.0),
                    Text(
                      pharmacyDoc['Name'],
                      style: const TextStyle(fontSize: 28.0, color: Colors.black),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pharmacyDoc['Ratings'].toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24.0,
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.local_pharmacy, size: 130.0, color: Colors.black),
                      radius: 75.0,
                    ),
                    const SizedBox(height: 30.0),
                    _buildTextFieldRow("Name", nameController, enabled),
                    const SizedBox(height: 10.0),
                    _buildTextFieldRow("Email", emailController, false),
                    const SizedBox(height: 10.0),
                    _buildTextFieldRow("Mobile No.", numberController, enabled),
                    const SizedBox(height: 10.0),
                    _buildTextFieldRow("Opening Time", openingTimeController, enabled),
                    const SizedBox(height: 10.0),
                    _buildTextFieldRow("Closing Time", closingTimeController, enabled),
                    const SizedBox(height: 10.0),
                    _buildTextFieldRow("Location", locationController, enabled),
                    const SizedBox(height: 30.0),
                    _buildActionButtons(context),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ],
            ) : const Center(child: CircularProgressIndicator(),),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 2,
        onTap: (int n) {
          if (n == 0) Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_home', (route) => false);
          if (n == 1) Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
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
            width: 110.0,
            child: Text(label, style: const TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TextFormField(
              enabled: enabled,
              readOnly: (label == "Opening Time" || label == "Closing Time" || label == "Location") ? true : false,
              controller: controller,
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
              onTap: () {
                if ((label == "Opening Time" || label == "Closing Time") && enabled) {
                  getTime(label);
                }
                else if (label == "Location"  && enabled) {
                  selectLocation(context);
                }
                else {

                }
              },
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
              // Add your change password logic here
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
              await _pharmacyDatabaseServices.updatePharmacy(pharmacyDoc.id, _updatePharmacyProfile(pharmacyDoc));
              print('Updated successfully!');
              // setState(() {
              //   enabled = false;
              //   nameFieldModified = false;
              //   mobileFieldModified = false;
              // });
              Snackbars.successSnackBar(message: "Updated successfully", context: context);
              Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_profile', (route) => false);
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

String formatTimeOfDay(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}