import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.of(context).pushNamed("home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),

      body: Center(
        child:CircleAvatar(
          radius: 80,
          backgroundImage: NetworkImage("https://tse3.mm.bing.net/th?id=OIP.pka1tMZnOysnOzsBfidNOAHaHa&pid=Api&P=0&h=180",),
        ),
      ),
    );
  }
}
