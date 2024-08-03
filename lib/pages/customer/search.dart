import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medifinder/drugs/names.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/validators/validation.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
                          hintText: "Search Medicine/Brand",
                          hintStyle: TextStyle(
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
                              filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase());
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
                        filteredPharmacies = await _pharmacyDatabaseServices.getNearbyPharmacies(location, searchController.text.trim().toLowerCase());
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    searchController.text = suggestion!;
                  },
                  suggestionsCallback: (textEditingValue) {
                    if (textEditingValue != null && textEditingValue.length > 0) {
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
                    return SizedBox();
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
            if (searched && !waiting)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: filteredPharmacies.length,
                  itemBuilder: (context, index) {
                    var pharmacy = filteredPharmacies[index]['pharmacy'];
                    var drug = filteredPharmacies[index]['drug'];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/pharmacydetails', arguments: {'selectedPharmacy': pharmacy, 'searchedDrug': searchController.text.trim().toLowerCase(), 'searchedDrugDoc': drug, 'userLocation': location});
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
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              pharmacy['Ratings'].toStringAsFixed(1),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${drug['BrandName']} ${drug['Dosage']}",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Text(
                                        "Rs. ${drug['UnitPrice'].toString()}",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 7.0,
                        )
                      ],
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
    );
  }
}
