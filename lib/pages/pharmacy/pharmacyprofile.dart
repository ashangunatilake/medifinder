import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/models/pharmacy_model.dart';
import 'package:medifinder/pages/locationpicker.dart';
import 'package:medifinder/pages/pharmacy/pharmacyview.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:medifinder/snackbars/snackbar.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PharmacyProfile extends StatefulWidget {
  const PharmacyProfile({super.key});

  @override
  State<PharmacyProfile> createState() => _PharmacyProfileState();
}

class _PharmacyProfileState extends State<PharmacyProfile> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  final PushNotifications _pushNotifications = PushNotifications();
  late DocumentSnapshot<Map<String, dynamic>> pharmacyDoc;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late TextEditingController openingTimeController;
  late TextEditingController closingTimeController;
  late TextEditingController locationController;
  final _formkey = GlobalKey<FormState>();
  bool enabled = false;
  bool nameFieldModified = false;
  bool mobileFieldModified = false;
  bool timeFieldModified = false;
  bool locationFieldModified = false;
  bool loaded = false;
  LatLng location = const LatLng(0, 0);
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
      if (locationController.text != "(${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)})") {
        setState(() {
          locationFieldModified = true;
        });
      }
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
            image: AssetImage('assets/images/background2.png'),
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
                Form(
                  key: _formkey,
                  child: Column(
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
                            style: const TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24.0,
                          )
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 75.0,
                        child: Icon(Icons.local_pharmacy, size: 130.0, color: Colors.black),
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
                ),
              ],
            ) : const PharmacyProfileSkeleton(),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.0,
            child: Text(label, style: const TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TextFormField(
              enabled: enabled,
              readOnly: (label == "Opening Time" || label == "Closing Time" || label == "Location") ? true : false,
              controller: controller,
              validator: (value) => (label == "Opening Time" || label == "Closing Time" || label == "Location" || label == "Name") ? Validator.validateEmptyText(label, value) : (label == "Mobile No." ? Validator.validateMobileNumber(value) : null),
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
              Navigator.pushNamed(context, '/changepassword');
            },
          ),
        if (!enabled)
          _buildButton(
            context,
            "Log out",
                () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              //prefs.remove('isLoggedIn');
              await prefs.clear();

              final String? deviceToken = await _pushNotifications.getDeviceToken();
              if (deviceToken != null) {
                Map<String, dynamic> userData = pharmacyDoc.data() as Map<String, dynamic>;
                print(userData['FCMTokens']);
                List<String> tokens = List<String>.from(userData['FCMTokens']);
                if (tokens.contains(deviceToken)) {
                  tokens.remove(deviceToken);
                  await pharmacyDoc.reference.update({'FCMTokens': tokens});
                }
              } else {
                print('Error: Device token is null.');
              }

              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        if (enabled)
          _buildButton(
            context,
            "Done",
                () async {
              if (!_formkey.currentState!.validate()) {
                return;
              }
              await _pharmacyDatabaseServices.updatePharmacy(pharmacyDoc.id, _updatePharmacyProfile(pharmacyDoc));
              print('Updated successfully!');
              // setState(() {
              //   enabled = false;
              //   nameFieldModified = false;
              //   mobileFieldModified = false;
              // });
              Snackbars.successSnackBar(message: "Updated successfully", context: context);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PharmacyView(index: 3)), (route) => false);
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
                side: const BorderSide(color: Color(0xFF0CAC8F)),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF0CAC8F)),
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

class PharmacyProfileSkeleton extends StatelessWidget {
  const PharmacyProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10.0),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: const Duration(milliseconds: 800),
              child: Container(
                width: 200,
                height: 30.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: const Duration(milliseconds: 800),
              child: Container(
                width: 100,
                height: 30.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 75.0,
              child: Icon(Icons.local_pharmacy, size: 130.0, color: Colors.black),
            ),
            const SizedBox(height: 50.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}