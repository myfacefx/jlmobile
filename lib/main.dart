import 'package:flutter/material.dart';
import 'package:jlf_mobile/pages/about.dart';
import 'package:jlf_mobile/pages/faq.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/blacklist.dart';
import 'package:jlf_mobile/pages/how_to.dart';
import 'package:jlf_mobile/pages/setting.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays ([]);
    return MaterialApp(
      title: 'JLF',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        //Root Page
        '/home': (BuildContext context) => HomePage(),
        '/blacklist': (BuildContext context) => BlacklistPage(),
        '/about': (BuildContext context) => AboutPage(),
        '/how-to': (BuildContext context) => HowToPage(),
        '/faq': (BuildContext context) => FAQPage(),
        '/setting': (BuildContext context) => SettingPage(),
        '/logout': (BuildContext context) => LoginPage()
      },
    );
  }
}