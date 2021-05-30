import 'package:flutter/material.dart';
import 'google_signup_button_widget.dart';

class SignUpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Container(
        color: Colors.white,
      ),
      buildSignUp(),
    ],
  );

  Widget buildSignUp() => Column(
    children: [
      SizedBox(height: 150,),
      FlutterLogo(
        size: 300,
        style: FlutterLogoStyle.stacked,
      ),
      Spacer(),
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),

          child: Text(
            'Welcome To Task ',
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(height: 10,),
      GoogleSignupButtonWidget(),
      SizedBox(height: 12),
      Text(
        'Login to continue',
        style: TextStyle(fontSize: 16),
      ),
      Spacer(),
    ],
  );
}