import 'package:flutter/material.dart';


class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      body: const SafeArea(
        child: Center(
          child: Text(
            "Stats Screen",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),



    );

  }
}