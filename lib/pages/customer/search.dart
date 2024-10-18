import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:medifinder/drugs/names.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shimmer/shimmer.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  List<Map<String, dynamic>> filteredPharmacies = [];
  bool searched = false;
  bool waiting = false;
  late LatLng location;
  final TextEditingController searchController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  double radius = 5.0;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: Colors.white38,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
            fontSize: 18.0,
            color: Colors.black
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              child: SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 21.0, 24.0, 0),
              child: Form(
                key: _formkey,
                child: TypeAheadField<String>(
                  controller: searchController,
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                      controller: searchController,
                      focusNode: focusNode,
                      autofocus: true,
                      validator: (value) => Validator.validateEmptyText("Medicine name", value),
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
                          hintText: "Search Medicine/Brand",
                          hintStyle: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 15.0,
                            color: Color(0xFFC4C4C4),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (!_formkey.currentState!.validate()) {
                                return;
                              }
                              setState(() {
                                waiting = true;
                              });
                              radius = 5.0;
                              filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase(), radius);
                              setState(() {
                                searched = true;
                                waiting = false;
                              });
                            },
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFFC4C4C4),
                            ),
                          )
                      ),
                      onFieldSubmitted: (value) async{
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        setState(() {
                          waiting = true;
                        });
                        print(searchController.text.trim().toLowerCase());
                        radius = 5.0;
                        filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase(), radius);
                        setState(() {
                          searched = true;
                          waiting = false;
                        });
                      },
                    );
                  },
                  itemBuilder: (context, String? suggestion) {
                    return ListTile(
                      title: Text(suggestion!),
                    );
                  },
                  onSelected: (String? suggestion) {
                    searchController.text = suggestion!;
                  },
                  suggestionsCallback: (textEditingValue) {
                    if (textEditingValue.isNotEmpty) {
                      List<String> suggestions = Drugs.names.where((element) => element.toLowerCase().contains(textEditingValue.toLowerCase())).toList();
                      suggestions.addAll(Drugs.brands.where((element) => element.toLowerCase().contains(textEditingValue.toLowerCase())).toList());
                      suggestions.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
                      return suggestions;
                    }
                    else {
                      return [];
                    }
                  },
                  emptyBuilder: (context) {
                    return const SizedBox();
                  },
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
            if (waiting)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: 5, // Display 5 skeletons as a placeholder
                  itemBuilder: (context, index) {
                    return const Column(
                      children: [
                        PharmacyItemSkeleton(),
                        SizedBox(
                          height: 7.0,
                        ),
                      ],
                    );
                  },
                ),
              )
            else if (searched && !waiting)
              (filteredPharmacies.isEmpty && radius == 5.0) ?
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(height: 10.0,),
                        Container(
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
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 14.0, right: 14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Lottie.network('https://lottie.host/76a6dd18-442e-4c72-b74b-621f93a5c093/dUL4MzxPZc.json'),
                                const SizedBox(height: 20.0),
                                Text(
                                  "No nearby pharmacies found within 5 km radius with the drug ${searchController.text.toString().capitalize}. Do you want to extend your search to 10 km radius?",
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(height: 10.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          waiting = true;
                                        });
                                        print(searchController.text.trim().toLowerCase());
                                        radius = 10.0;
                                        filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase(), radius);
                                        setState(() {
                                          searched = true;
                                          waiting = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0CAC8F),
                                          padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0)
                                      ),
                                      child: const Text(
                                        "Extend",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: ()
                                      {
                                        setState(() {
                                          radius = 10.0;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFFFFF),
                                          padding: const EdgeInsets.fromLTRB(45.0, 13.0, 45.0, 11.0),
                                          side: const BorderSide(color: Color(0xFF0CAC8F))
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Color(0xFF0CAC8F),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ): (filteredPharmacies.isEmpty && radius == 10.0) ?
              Column(
                children: [
                  const SizedBox(height: 10.0,),
                  Container(
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
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 14.0, right: 14.0),
                      child: Text(
                        "Sorry! No nearby pharmacies found with the drug ${searchController.text.toString().capitalize}.",
                        style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ) :

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: filteredPharmacies.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot pharmacy = filteredPharmacies[index]['pharmacy'];
                    DocumentSnapshot drug = filteredPharmacies[index]['drug'];
                    return Column(
                      children: [
                        PharmacyItem(
                          pharmacy: pharmacy,
                          drug: drug,
                          location: location,
                          radius: radius,
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class PharmacyItem extends StatelessWidget {
  final DocumentSnapshot pharmacy;
  final DocumentSnapshot drug;
  final LatLng location;
  final double radius;

  const PharmacyItem({
    super.key,
    required this.pharmacy,
    required this.drug,
    required this.location,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/pharmacydetails', arguments: {'selectedPharmacy': pharmacy, 'searchedDrug': drug, 'userLocation': location, 'radius': radius},);
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
                    pharmacy['Name'],
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['Ratings'].toStringAsFixed(1),
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
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${drug['BrandName'].toString().capitalize} ${drug['Dosage']}",
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "Rs. ${drug['UnitPrice'].toString()}",
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PharmacyItemSkeleton extends StatelessWidget {
  const PharmacyItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 150, // Approximate width of the pharmacy name
                  height: 20, // Approximate height of the text
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 50, // Approximate width for the rating text
                  height: 20, // Approximate height of the text
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 180, // Approximate width of the drug name and dosage
                  height: 16, // Approximate height of the text
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  width: 80, // Approximate width for the price text
                  height: 20, // Approximate height of the text
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}






