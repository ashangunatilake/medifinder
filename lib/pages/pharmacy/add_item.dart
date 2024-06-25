import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:medifinder/models/drugs_model.dart';

class AddItem extends StatefulWidget {
  final DrugsModel? drug;

  AddItem({Key? key, this.drug}) : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    if (widget.drug != null) {
      nameController.text = widget.drug!.name;
      brandController.text = widget.drug!.brand;
      dosageController.text = widget.drug!.dosage;
      unitPriceController.text = widget.drug!.price.toString();
      quantityController.text = widget.drug!.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drug == null ? 'Add New Drug' : 'Edit Drug'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.drug == null
                        ? 'Add New Drug Details'
                        : 'Edit Drug Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Name',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the drug name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Brand Name',
                    controller: brandController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the brand name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Dosage',
                    controller: dosageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the dosage';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Unit Price',
                    controller: unitPriceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the unit price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    labelText: 'Quantity',
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              User? user = FirebaseAuth.instance.currentUser;
                              // Create or update a DrugModel
                              DrugsModel updatedDrug = DrugsModel(
                                name: nameController.text,
                                brand: brandController.text,
                                dosage: dosageController.text,
                                price: double.parse(unitPriceController.text),
                                quantity: double.parse(quantityController.text),
                              );

                              try {
                                if (widget.drug == null) {
                                  // Add new drug
                                  //await PharmacyDatabaseServices().addDrug(user!.uid, updatedDrug);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Drug added successfully!')),
                                  );
                                } else {
                                  // Update existing drug
                                  //await PharmacyDatabaseServices().updateDrug(updatedDrug);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Drug updated successfully!')),
                                  );
                                }

                                // Clear form
                                _formKey.currentState!.reset();
                                nameController.clear();
                                brandController.clear();
                                dosageController.clear();
                                unitPriceController.clear();
                                quantityController.clear();

                                setState(() {
                                  _isLoading = false;
                                });

                                // Optionally: Keep the form open to add more drugs
                                // Navigator.pop(context);
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to ${widget.drug == null ? 'add' : 'update'} drug: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(218, 3, 240, 212),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            widget.drug == null
                                ? 'Add to Stock'
                                : 'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            // Close the keyboard before navigating back
                            FocusScope.of(context).unfocus();
                            WidgetsBinding.instance!
                                .addPostFrameCallback((_) {
                              Navigator.pop(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}