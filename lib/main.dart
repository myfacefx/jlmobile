import 'package:flutter/material.dart';
import 'package:jlf_mobile/pages/about.dart';
import 'package:jlf_mobile/pages/faq.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/blacklist.dart';
import 'package:jlf_mobile/pages/how_to.dart';
import 'package:jlf_mobile/pages/our_bid.dart';
import 'package:jlf_mobile/pages/setting.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/themes.dart';
import 'package:jlf_mobile/pages/user/register.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/pages/user/edit_profile.dart';
import 'package:jlf_mobile/pages/auction/create.dart';
import 'package:jlf_mobile/pages/auction/activate.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/user/notification.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays ([]);
    return MaterialApp(
      title: 'JLF',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      home: globals.state == "home" ? HomePage() : LoginPage(),
      routes: <String, WidgetBuilder>{
        //Root Page
        '/home': (BuildContext context) => HomePage(),
        '/login': (BuildContext context) => LoginPage(),
        '/register': (BuildContext context) => RegisterPage(),
        '/blacklist': (BuildContext context) => BlacklistPage(),
        '/about': (BuildContext context) => AboutPage(),
        '/how-to': (BuildContext context) => HowToPage(),
        '/faq': (BuildContext context) => FAQPage(),
        '/setting': (BuildContext context) => SettingPage(),
        '/logout': (BuildContext context) => LoginPage(),
        '/profile': (BuildContext context) => ProfilePage(),
        '/edit-profile': (BuildContext context) => EditProfilePage(),
        '/our-bid': (BuildContext context) => OurBidPage(),
        '/auction/create': (BuildContext context) => CreateAuctionPage(),
        '/auction/activate': (BuildContext context) => ActivateAuctionPage(),
        '/notification': (BuildContext context) => NotificationPage()
      },
    );
  }
}
