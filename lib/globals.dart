import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_advanced_networkimage/provider.dart'
    // show AdvancedNetworkImage;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:validators/validators.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:share/share.dart';

/// Global Function to return Screen Height
double mh(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Global Function to return Screen Width
double mw(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

void share() {
  Share.share('Bergabung bersama JLF - https://juallelangfauna.com');
}

String baseUrl = "http://192.168.100.119:8000";
String flavor = "Development";
String state = "Login";

User user;

// Global timeout setting
int timeOut = 30;

int getTimeOut() {
  return timeOut;
}

String getBaseUrl() {
  return baseUrl;
}

FirebaseMessaging _fcm = FirebaseMessaging();
generateToken() async {
  // Firestore _db = Firestore.instance;

  if (user != null && user.firebaseToken == null) {
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      User updateToken = User();
      updateToken.firebaseToken = fcmToken;

      String result = await update(updateToken.toJson(), user.id);

      if (result != null) {
        user.firebaseToken = fcmToken;
        print("User's Token updated: $fcmToken");
      } else {
        print("FAIL TO UPDATE USER'S TOKEN");
        // globals.showDialogs("Terjadi error, silahkan ulangi", context);
        // setState(() {
        //   registerLoading = false;
        //   autoValidate = true;
        // });
      }
    } else {
      print("GOT NULL FROM REQUEST TOKEN");
    }
  } else if (user != null && user.firebaseToken != null) {
    print("User Token has already set: ${user.firebaseToken}");
  }
}

notificationListener(context) {
  _fcm.configure(onMessage: (Map<String, dynamic> message) async {
    print("onMessage: $message");

    showDialogs(message['notification']['body'], context);

    // final snackbar = SnackBar(
    //   content: Text(message['notification']['title']),
    //   action: SnackBarAction(
    //     label: 'Go',
    //     onPressed: () => null,
    //   )
    // );

    // Scaffold.of(context).showSnackBar(snackbar);
  }, onLaunch: (Map<String, dynamic> message) async {
    print("onLaunch: $message");
  }, onResume: (Map<String, dynamic> message) async {
    print("onResume: $message");
  });
}

/// Global Function to return Alert Dialog
Future<bool> showDialogs(String content, BuildContext context,
    {String title = "Perhatian",
    String route = "",
    bool isDouble = false,
    Function openSetting,
    String text = "Tutup"}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.black)),
        content: myText(text: content),
        actions: <Widget>[
          FlatButton(
            child: Text(text),
            onPressed: () {
              if (text != "Tutup") {
                Navigator.pop(context);
                openSetting();
              } else {
                if (route == "") {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.popUntil(context, ModalRoute.withName(route));
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, route);
                }

                if (isDouble) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}

void loadingModel(context, {label = "Memuat. . ."}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
          title: Text(label),
          content: MaterialButton(
            onPressed: () {},
            height: 50,
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          ),
        ),
  );
}

Widget bottomNavigationBar(context) {
  return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/blacklist");
      },
      child: Container(
          height: 20,
          color: myColor("danger"),
          // color: Color.fromRGBO(201, 0, 0, 1),
          child: Center(
            child: Text(
              "Daftar Blacklist Member",
              // "Take care of your product, avoid blacklist member | check here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          )));
}

Widget appBar(GlobalKey<ScaffoldState> scaffoldKey, context) {
  return AppBar(
    title: GestureDetector(
      onTap: () {
        Navigator.popUntil(context, ModalRoute.withName("/"));
      },
      child:
          Container(child: Image.asset("assets/images/logo.png", height: 40)),
    ),
    leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          if (scaffoldKey.currentState.isDrawerOpen)
            scaffoldKey.currentState.openEndDrawer();
          else
            scaffoldKey.currentState.openDrawer();
        }),
    actions: <Widget>[myAppBarIcon(context)],
    centerTitle: true,
  );
}

Widget myAppBarIcon(context) {
  return GestureDetector(
    onTap: () => Navigator.of(context).pushNamed('/notification'),
    child: Center(
      child: Container(
          margin: EdgeInsets.only(right: 10),
          width: 30,
          height: 30,
          child: Stack(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
              ),
              user != null && user.historiesCount != null && user.historiesCount > 0
                  ? Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 0),
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: myColor('prime'),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Center(
                            child: Text(
                              "${user.historiesCount}",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          )),
    ),
  );
}

Widget spacePadding() {
  return Padding(padding: EdgeInsets.only(bottom: 20));
}

// Future<ImageProvider> imageUrlProvider(String link,
//     [ImageProvider defaultPic =
//         const AssetImage("assets/images/error.png")]) async {
//   /// Variable to hold Image Provider to be returned later
//   ImageProvider retImg;
//   // check if the link is valid link or not
//   link = isURL(link) ? link : "-";
//   // if link is invalid, do not proceed
//   if (link == "-") {
//     retImg = defaultPic;
//   } else {
//     /// load local image as [ByteData] from bundle to be used as alternative on network failure
//     /// or a valid link does not provide a valid image
//     ByteData bytes = await rootBundle.load('assets/images/account.png');

//     /// buffer [bytes] as [Uint8List] to be used on [AdvancedNetworkImage] alternative
//     Uint8List list = bytes.buffer.asUint8List();
//     retImg = AdvancedNetworkImage(link, fallbackImage: list);
//   }
//   return retImg;
// }

void getNotificationCount() async {
  if (user != null && user.id != null) {
    int historiesCount = await getHistoriesCount(user.id);
    
    if (user.historiesCount != null) {
      user.historiesCount = historiesCount;
    }

    int bidsCount = await getBidsCount(user.id);
        
    if (user.bidsCount != null) {
      user.bidsCount = bidsCount;
    }
    
    return null;
  }
}

String convertToMoney(double number) {
  var moneyMasked = new MoneyMaskedTextController(
    decimalSeparator: '',
    precision: 0,
    thousandSeparator: '.',
    rightSymbol: ",-",
    // leftSymbol: "Rp."
  );
  moneyMasked.updateValue(number);
  return moneyMasked.text;
}

Widget buildFailedLoadingData(context, Function refresh) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
            shape: CircleBorder(),
            onPressed: () => refresh(),
            child: Icon(Icons.refresh,
                color: Theme.of(context).accentColor, size: 50)),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        Text("Gagal memuat data, klik untuk refresh",
            style: TextStyle(color: Colors.black)),
      ],
    ),
  );
}

String convertFormatDate(String date) {
  String newDate = "";
  List<String> splitDate = date.split("-");
  newDate = "${splitDate[2]}/${splitDate[1]}/${splitDate[0]}";
  return newDate;
}

String convertFormatDateTimeProduct(String date) {
  String newDate = "";
  List<String> split = date.split(" ");
  List<String> splitTime = split[1].split(":");

  List<String> splitDate = split[0].split("-");
  newDate = "${splitDate[2]}/${splitDate[1]} ${splitTime[0]}:${splitTime[1]}";
  return newDate;
}

String convertToAge(DateTime birthDate) {
  final date2 = DateTime.now();
  final year = date2.year - birthDate.year;
  var month = date2.month - birthDate.month;
  if (month < 0) {
    month = month * -1;
  }
  return "$year THN $month";
}

String convertMonthFromDigit(int monthDigit) {
  String month = 'Januari';

  switch (monthDigit) {
    case 2: month = 'Februari'; break;
    case 3: month = 'Maret'; break;
    case 4: month = 'April'; break;
    case 5: month = 'Mei'; break;
    case 6: month = 'Juni'; break;
    case 7: month = 'Juli'; break;
    case 8: month = 'Agustus'; break;
    case 9: month = 'September'; break;
    case 10: month = 'Oktober'; break;
    case 11: month = 'November'; break;
    case 12: month = 'Desember'; break;
    default:
  }

  return month;
}

Widget isLoading() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

Widget failLoadImage() {
  return Container(
    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
    height: 128,
    color: Colors.black,
    child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Image.asset("assets/images/image_not_found.png")),
  );
}

String convertTimer(String expiryTime) {
  final exptDate = DateTime.parse(expiryTime);
  final dateNow = DateTime.now();
  final differenceMinutes = (dateNow.difference(exptDate).inMinutes).abs();
  String def = "";
  def = "${(dateNow.difference(exptDate).inSeconds).abs()} Sec";

  //1 year
  if (differenceMinutes > 525600) {
    def = "${differenceMinutes ~/ 525600} Year";
  }
  //1 month
  else if (differenceMinutes > 43200) {
    def = "${differenceMinutes ~/ 43200} Month";
  }
  //1 day
  else if (differenceMinutes > 1440) {
    def = "${differenceMinutes ~/ 1440} Day";
  }

  //1 hour
  else if (differenceMinutes > 60) {
    def = "${differenceMinutes ~/ 60} Hour";
  } else if (differenceMinutes > 1) {
    def = "$differenceMinutes Min";
  }

  return def;
}

/// get color by Style Name : `primary`,`unprime`,`secondary`,`active`,`warnig`,`danger`,`disabled`.
Color myColor([String color = "default"]) {
  Color returnedColor;
  switch (color) {
    case "primary":
      // red pink
      // returnedColor = Color.fromRGBO(255, 77, 77, 1);

      // light blue
      // returnedColor = Color.fromRGBO(73, 187, 255, 1);

      // blue navy
      returnedColor = Color.fromRGBO(60, 90, 153, 1);
      break;
    case "mimosa":
      // for current bid
      returnedColor = Color.fromRGBO(239, 192, 80, 1);
      break;
    case "danger":
      returnedColor = Colors.red;
      break;
    case "warning":
      returnedColor = Colors.deepOrange;
      break;
    case "secondary":
      returnedColor = Colors.deepOrange;
      break;
    case "active":
      returnedColor = Colors.black;
      break;
    case "unprime":
      returnedColor = Color.fromRGBO(136, 136, 136, 1);
      break;
    case "disabled":
      returnedColor = Color.fromRGBO(178, 178, 178, 1);
      break;
    case "light":
      returnedColor = Colors.white;
      break;
    case "dark":
      returnedColor = Colors.grey[700];
      break;
    default:
      returnedColor = Colors.black;
      break;
  }
  return returnedColor;
}

/// get weight by Style Name : `T`/`XL`/`L`/`N`/`M`/`SB`/`B`/`XB`/`TB`
///
/// `T` : Thin.
/// `XL` : Extra Light.
/// `L`  : Light.
/// `N`  : Normal.
/// `M`  : Medium.
/// `SB` : Semi-Bold.
/// `B`  : Bold.
/// `XB` : Extra Bold.
/// `TB` : True Bold/ Real Black.
FontWeight myFontWeight([String weight = 'N']) {
  FontWeight returnedFW;
  switch (weight) {
    case 'T':
      returnedFW = FontWeight.w100;
      break;
    case 'XL':
      returnedFW = FontWeight.w200;
      break;
    case 'L':
      returnedFW = FontWeight.w300;
      break;
    case 'N':
      returnedFW = FontWeight.w400;
      break;
    case 'M':
      returnedFW = FontWeight.w500;
      break;
    case 'SB':
      returnedFW = FontWeight.w600;
      break;
    case 'B':
      returnedFW = FontWeight.w700;
      break;
    case 'XB':
      returnedFW = FontWeight.w800;
      break;
    case 'TB':
      returnedFW = FontWeight.w900;
      break;
  }
  return returnedFW;
}

/// Global Function to return Text with [color] as in [myColor] and [weight] as in [myFontWeight]
Text myText(
    {@required String text,
    String color = "default",
    double size = 14,
    String weight = "N",
    TextDecoration decoration = TextDecoration.none,
    TextAlign align = TextAlign.start,
    TextOverflow textOverflow = TextOverflow.visible,
    double letterSpacing = 0}) {
  if (text == null || text == "") text = "-";
  return Text(
    text,
    textAlign: align,
    overflow: textOverflow,
    style: TextStyle(
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: myColor(color),
      color: myColor(color),
      fontSize: size,
      fontWeight: myFontWeight(weight),
    ),
  );
}
