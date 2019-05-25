import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays ([]);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme:buildThemeData(),
      home: HomePage(),
    );
  }
}