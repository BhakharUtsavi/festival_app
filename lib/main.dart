import 'package:festival_app/screens/detailpage.dart';
import 'package:festival_app/screens/editpage.dart';
import 'package:festival_app/screens/homepage.dart';
import 'package:festival_app/screens/splash.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/":(context){
            return Splash();
          },
          "home":(context){
            return HomePage();
          },
          "detail":(context){
            return DetailPage();
          },
          "edit":(context){
            return EditPage();
          },
        },
      )
  );
}