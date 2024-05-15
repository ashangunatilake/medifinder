import 'package:flutter/material.dart';

class AddItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Drug'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/add_bg.png'),
                  fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
