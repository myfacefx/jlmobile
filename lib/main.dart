import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/about.dart';
import 'package:jlf_mobile/pages/auction/create.dart';
import 'package:jlf_mobile/pages/blacklist.dart';
import 'package:jlf_mobile/pages/blacklist_animal.dart';
import 'package:jlf_mobile/pages/chat_list.dart';
import 'package:jlf_mobile/pages/donasi.dart';
import 'package:jlf_mobile/pages/faq.dart';
import 'package:jlf_mobile/pages/home.dart';
import 'package:jlf_mobile/pages/how_to.dart';
import 'package:jlf_mobile/pages/intro.dart';
import 'package:jlf_mobile/pages/list_event.dart';
import 'package:jlf_mobile/pages/our_bid.dart';
import 'package:jlf_mobile/pages/our_product.dart';
import 'package:jlf_mobile/pages/rekber.dart';
import 'package:jlf_mobile/pages/send_OTP.dart';
import 'package:jlf_mobile/pages/setting.dart';
import 'package:jlf_mobile/pages/team.dart';
import 'package:jlf_mobile/pages/up_coming.dart';
import 'package:jlf_mobile/pages/user/edit_password.dart';
import 'package:jlf_mobile/pages/user/edit_profile.dart';
import 'package:jlf_mobile/pages/user/forgot_password.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/pages/user/notification.dart';
import 'package:jlf_mobile/pages/user/point_history.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/pages/user/register.dart';
import 'package:jlf_mobile/pages/verification.dart';
import 'package:jlf_mobile/pages/reward.dart';
import 'package:jlf_mobile/themes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays ([]);
    // print("Verification Status: ${globals.user.verificationStatus}");
    String initialRoute = "/";

    print(globals.state);

    if (globals.state == "intro")
      initialRoute = "/intro";
    else if (globals.state == "login")
      initialRoute = "/login";
    else if (globals.user != null) {
      if (globals.user.verificationStatus == null) {
        initialRoute = "/verification";
      } else if (globals.user.verificationStatus != null) {
        if (globals.user.verificationStatus == "denied") {
          initialRoute = "/verification";
        }
      }
    } else if (globals.state == "verification") {
      initialRoute = "/verification";
    }

    return MaterialApp(
      title: 'JLF',
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      theme: buildThemeData(),
      initialRoute: initialRoute,
      // initialRoute: globals.state == "intro"
      //     ? "/intro"
      //     : (globals.user.verificationStatus == null || globals.user.verificationStatus == 'denied') ? "/verification" : (globals.state == "home" ? "/" : "/login"),
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
        '/blacklist-animal': (BuildContext context) => BlacklistAnimalPage(),
        '/verification': (BuildContext context) => VerificationPage(),
        '/upcoming': (BuildContext context) => UpComingPage(),
        '/forget-password': (BuildContext context) => ForgotPasswordPage(),
        '/list-event': (BuildContext context) => ListEventPage(),
        '/send-otp': (BuildContext context) => SendOTPPage(),
        '/reward': (BuildContext context) => RewardPage(),
        '/team': (BuildContext context) => TeamPage(),

        // '/edit-product': (BuildContext context) => EditProductPage()
      },
    );
  }
}
