import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/auction/create.dart';
import 'package:jlf_mobile/pages/event_promotion/list_event.dart';
import 'package:jlf_mobile/pages/event_promotion/promo.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/static/about.dart';
import 'package:jlf_mobile/pages/static/donasi.dart';
import 'package:jlf_mobile/pages/static/faq.dart';
import 'package:jlf_mobile/pages/static/how_to.dart';
import 'package:jlf_mobile/pages/static/intro.dart';
import 'package:jlf_mobile/pages/static/rekber.dart';
import 'package:jlf_mobile/pages/static/reward.dart';
import 'package:jlf_mobile/pages/static/setting.dart';
import 'package:jlf_mobile/pages/static/team.dart';
import 'package:jlf_mobile/pages/transaction/chat_list.dart';
import 'package:jlf_mobile/pages/user/blacklist.dart';
import 'package:jlf_mobile/pages/user/edit_password.dart';
import 'package:jlf_mobile/pages/user/edit_profile.dart';
import 'package:jlf_mobile/pages/user/forgot_password.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/pages/user/notification.dart';
import 'package:jlf_mobile/pages/user/our_bid.dart';
import 'package:jlf_mobile/pages/user/our_product.dart';
import 'package:jlf_mobile/pages/user/point_history.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/pages/user/register.dart';
import 'package:jlf_mobile/pages/verification/verification.dart';
import 'package:jlf_mobile/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays ([]);
    String initialRoute = "/";

    if (globals.state == "intro")
      initialRoute = "/intro";
    else if (globals.state == "login") initialRoute = "/login";

    return MaterialApp(
      title: 'JLF',
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      theme: buildThemeData(),
      initialRoute: initialRoute,
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
        '/edit-password': (BuildContext context) => EditPasswordPage(),
        '/our-bid': (BuildContext context) => OurBidTopPage(),
        '/our-product': (BuildContext context) => OurProducTopPage(),
        '/auction/create': (BuildContext context) => CreateAuctionPage(),
        '/notification': (BuildContext context) => NotificationPage(),
        '/point-history': (BuildContext context) => PointHistoryPage(),
        '/intro': (BuildContext context) => IntroPage(),
        '/chat-list': (BuildContext context) => ChatListPage(),
        '/donasi': (BuildContext context) => DonasiPage(),
        '/verification': (BuildContext context) => VerificationPage(),
        '/forget-password': (BuildContext context) => ForgotPasswordPage(),
        '/list-event': (BuildContext context) => ListEventPage(),
        '/reward': (BuildContext context) => RewardPage(),
        '/team': (BuildContext context) => TeamPage(),
        '/promo': (BuildContext context) => PromoPage(),

        // '/edit-product': (BuildContext context) => EditProductPage()
      },
    );
  }
}
