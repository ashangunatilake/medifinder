import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RegisterPage extends StatelessWidget {
  double _deviceHeight = 0;
  double _deviceWidth = 0;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 240, 184, 60),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        //mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: _deviceHeight * 0.18,
            child: Container(),
          ),
          _avatarWidget()
        ],
      ),
    );
  }

  Widget _avatarWidget() {
    double _circleD = _deviceHeight * 0.14;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                'Pharmacy Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'City Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: _circleD,
          width: _circleD,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              image: AssetImage('assets/images/pharmacy_logo.png'),
            ),
          ),
        ),
      ],
    );
  }
}
