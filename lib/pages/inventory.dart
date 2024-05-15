import 'package:flutter/material.dart';
import 'package:medifinder/pages/add_item.dart';
import 'package:medifinder/pages/drugs_stock.dart';

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/pharmacy_bg.png'),
                  fit: BoxFit.cover),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  'Pharmacy Name',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                  height: 200), // Add some space between the title and buttons
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Drugs()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(21, 201, 180, 1)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(200, 100), // Increase the size of the button
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Keep rounded corners
                          ),
                        ),
                      ),
                      child: Text(
                        'Drugs \nIn Store',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 90), // Add space between buttons
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddItem()),
                        );
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(21, 201, 180, 1)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(
                            color:
                                Colors.white, // Set the border color to white
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(200, 100), // Increase the size of the button
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Keep rounded corners
                          ),
                        ),
                      ),
                      child: Text('ADD \nNew Drug',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(21, 201, 180, 1),
                              fontSize: 22)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
