import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  List<DocumentSnapshot> filteredPharmacies = [];
  bool searched = false;
  bool waiting = false;
  late LatLng location;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      location = args['location'] as LatLng;
      print(location);
    } else {
      // Handle the case where args are null (optional)
      // You might want to throw an error or use default values
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              child: SizedBox(height: 5),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 21.0, 24.0, 0),
              child: Form(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(
                      color: const Color(0xFFCCC9C9),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: TextFormField(
                            controller: searchController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Medicine';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search Medicine",
                              hintStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15.0,
                                color: Color(0xFFC4C4C4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              waiting = true;
                            });
                            print(searchController.text.trim().toLowerCase());
                            filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase());
                            setState(() {
                              searched = true;
                              waiting = false;
                            });
                          },
                          child: Icon(
                            Icons.search,
                            color: Color(0xFFC4C4C4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 21.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/mapview', arguments: {'location': location, 'pharmacies': filteredPharmacies});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  "Map View",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if (searched && !waiting)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPharmacies.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: _pharmacyDatabaseServices.getDrugByName(searchController.text.trim().toLowerCase(), filteredPharmacies[index].id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(child: Text('No data available'));
                        } else {
                          DocumentSnapshot drugDoc = snapshot.data!;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/pharmacydetails', arguments: {'selectedPharmacy': filteredPharmacies[index], 'searchedDrug': searchController.text.trim().toLowerCase()});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                                  width: MediaQuery.of(context).size.width,
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 5.0, left: 14.0, right: 14.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              filteredPharmacies[index]['Name'],
                                              style: TextStyle(
                                                fontSize: 20.0,
                                              ),
                                            ),
                                            Container(
                                              width: 47.0,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    filteredPharmacies[index]['Ratings'].toString(),
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Text(
                                          drugDoc['UnitPrice'].toString(),
                                          style: TextStyle(
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7.0,
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              )
            else if (waiting)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(child: SizedBox()),
          ],
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
            label: "Profile",
          ),
        ],
        onTap: (int n) {
          if (n == 1) Navigator.pushNamed(context, '/activities');
          if (n == 2) Navigator.pushNamed(context, '/profile');
        },
        currentIndex: 0,
        selectedItemColor: const Color(0xFF12E7C0),
      ),
    );
  }
}
