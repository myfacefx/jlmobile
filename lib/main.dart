import 'package:flutter/material.dart';
import 'package:jlf_mobile/pages/about.dart';
import 'package:jlf_mobile/pages/chat_list.dart';
import 'package:jlf_mobile/pages/faq.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/blacklist.dart';
import 'package:jlf_mobile/pages/how_to.dart';
import 'package:jlf_mobile/pages/intro.dart';
import 'package:jlf_mobile/pages/our_bid.dart';
import 'package:jlf_mobile/pages/our_product.dart';
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
import 'package:jlf_mobile/pages/rekber.dart';
import 'package:jlf_mobile/pages/chat.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays ([]);
    return MaterialApp(
      title: 'JLF',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      initialRoute: globals.state == "intro"
          ? "/intro"
          : (globals.state == "home" ? "/" : "/login"),
      routes: <String, WidgetBuilder>{
        //Root Page
        '/': (BuildContext context) => HomePage(),
        '/login': (BuildContext context) => LoginPage(),
        '/register': (BuildContext context) => RegisterPage(),
        '/blacklist': (BuildContext context) => BlacklistPage(),
        '/rekber': (BuildContext context) => RekberPage(),
        '/about': (BuildContext context) => AboutPage(),
        '/how-to': (BuildContext context) => HowToPage(),
        '/faq': (BuildContext context) => FAQPage(),
        '/setting': (BuildContext context) => SettingPage(),
        '/logout': (BuildContext context) => LoginPage(),
        '/profile': (BuildContext context) => ProfilePage(),
        '/edit-profile': (BuildContext context) => EditProfilePage(),
        '/our-bid': (BuildContext context) => OurBidTopPage(),
        '/our-product': (BuildContext context) => OurProducTopPage(),
        '/auction/create': (BuildContext context) => CreateAuctionPage(),
        '/notification': (BuildContext context) => NotificationPage(),
        '/intro': (BuildContext context) => IntroPage(),
        '/chat': (BuildContext context) => ChatPage(),
        '/chat-list': (BuildContext context) => ChatListPage()
      },
    );
  }
}
