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
  final PharmacyDatabaseServices _databaseServices = PharmacyDatabaseServices();
  List<DocumentSnapshot> filteredPharmacies = [];
  bool searched = false;
  bool waiting = false;
  LatLng? location;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void handleSearch() async {
    setState(() {
      waiting = true;
    });
    String searchText = searchController.text.trim().toLowerCase();
    filteredPharmacies = await _databaseServices.getNearbyPharmacies(location!, searchText);
    setState(() {
      searched = true;
      waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && location == null) {
      location = args['location'] as LatLng;
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
              padding: const EdgeInsets.all(10.0),
              child: Row(
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
            _buildSearchBar(),
            const SizedBox(height: 21.0),
            _buildMapViewButton(),
            if (searched && !waiting)
              _buildPharmacyList()
            else if (waiting)
              const Center(child: CircularProgressIndicator())
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
            children: [
              Expanded(
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
              GestureDetector(
                onTap: handleSearch,
                child: const Icon(
                  Icons.search,
                  color: Color(0xFFC4C4C4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapViewButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: ElevatedButton(
        onPressed: () {
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
    );
  }

  Widget _buildPharmacyList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredPharmacies.length,
        itemBuilder: (context, index) {
          return PharmacyListItem(
            pharmacy: filteredPharmacies[index],
            onTap: () {
              Navigator.pushNamed(context, '/pharmacydetails', arguments: {'selectedPharmacy': filteredPharmacies[index], 'searchedDrug': searchController.text.trim().toLowerCase()});
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
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
      onTap: (int index) {
        if (index == 1) Navigator.pushNamed(context, '/activities');
        if (index == 2) Navigator.pushNamed(context, '/profile');
      },
      currentIndex: 0,
      selectedItemColor: const Color(0xFF12E7C0),
    );
  }
}

class PharmacyListItem extends StatelessWidget {
  final DocumentSnapshot pharmacy;
  final VoidCallback onTap;

  const PharmacyListItem({
    required this.pharmacy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
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
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pharmacy['Name'],
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        pharmacy['Ratings'].toString(),
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24.0,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                pharmacy['ContactNo'],
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
