import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/chat_list_pagination.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/chat.dart';
import 'package:jlf_mobile/pages/send_OTP.dart';
import 'package:jlf_mobile/services/auction_services.dart' as AuctionService;
import 'package:jlf_mobile/services/firebase_chat_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:share/share.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:simple_share/simple_share.dart';
import 'package:http/http.dart' as http;

String version = "v0.1.6";
bool isProduction = false;

/// Global Function to return Screen Height
double mh(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Global Function to return Screen Width
double mw(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// void share(String from, int animalId) {
//   String param;
//   if (from != null && animalId != null) {
//     if (from == "LELANG") {
//       param = "/type/animalf1-$animalId";
//     }
//     if (from == "PASAR HEWAN") {
//       param = "/type/animalf2-$animalId";
//     }
//   }

//   Share.share('Bergabung bersama JLF - https://juallelangfauna.com$param');
// }

// void share(String from, int animalId) {
//   String param;
//   if (from != null && animalId != null) {
//     if (from == "LELANG") {
//       param = "/type/animalf1-$animalId";
//     }
//     if (from == "PASAR HEWAN") {
//       param = "/type/animalf2-$animalId";
//     }
//   }

//   Share.share('Bergabung bersama JLF - https://juallelangfauna.com$param');
// }

void share(String from, Animal animal) {
  String text, param;
  if (from != null && animal.id != null) {
    String category = animal.animalSubCategory.animalCategory.name;
    String subCategory = animal.animalSubCategory.name;

    if (from == "LELANG") {
      // param = "/type/animalf1-${animal.id}";
      param = "?animal=${animal.id}&type=LL";
      String openBid =
          convertToMoney(double.parse(animal.auction.openBid.toString()));
      String bin =
          convertToMoney(double.parse(animal.auction.buyItNow.toString()));
      String multiply =
          convertToMoney(double.parse(animal.auction.multiply.toString()));

      text =
          "Dilelang ${animal.name} ($category - $subCategory) dengan harga awal Rp. $openBid, beli sekarang (BIN) Rp. $bin, dan kelipatan Rp. $multiply";
    }
    if (from == "PASAR HEWAN") {
      param = "?animal=${animal.id}&type=PS";
      String price =
          convertToMoney(double.parse(animal.product.price.toString()));
      text =
          "Dijual ${animal.name} ($category - $subCategory) dengan harga Rp. $price";
    }
    //  dijual / dilelang {{nama barang}} harga {{}} cek segera
  }

  debugPrint("https://juallelangfauna.com/$param");

  Share.share(
      text + ' - Cek Segera Hanya di JLF - https://juallelangfauna.com/$param');
}

String baseUrl = "http://192.168.100.119:8000";
String flavor = "Development";
String state = "Login";

String norek = '8165246817';
String nohpAdmin = '6282223304275';

User user;

// Global timeout setting
int timeOut = 60;

int getTimeOut() {
  return timeOut;
}

String getBaseUrl() {
  return baseUrl;
}

String getNorek() {
  return norek;
}

String getNohpAdmin() {
  return nohpAdmin;
}

String generateInvoice(Auction auction) {
  if (auction == null ||
      auction.winnerAcceptedDate == null ||
      auction.verificationCode == null) return '-';

  String invoice = "JLF/";
  var acceptedDate = DateTime.parse(auction.winnerAcceptedDate);

  if (acceptedDate.day < 10) {
    invoice += "0${acceptedDate.day}";
  } else {
    invoice += "${acceptedDate.day}";
  }

  if (acceptedDate.month < 10) {
    invoice += "0${acceptedDate.month}";
  } else {
    invoice += "${acceptedDate.month}";
  }

  invoice += acceptedDate.year.toString().substring(2);

  invoice += "/AUC/${auction.id}/${auction.verificationCode}";

  return invoice;
}

FirebaseMessaging _fcm = FirebaseMessaging();
generateToken() async {
  // Firestore _db = Firestore.instance;
  debugPrint("Previous Token firebase ${user.firebaseToken}");
  debugPrint("Previous Token Rediss ${user.tokenRedis}");

  if (user != null) {
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      if (fcmToken != user.firebaseToken) {
        User updateToken = User();
        updateToken.firebaseToken = fcmToken;
        debugPrint(json.encode(updateToken.toJson()));
        String result = await updateUserLogin(
            updateToken.toJson(), user.id, user.tokenRedis);

        if (result != null) {
          user.firebaseToken = fcmToken;
          debugPrint("User's Token updated: $fcmToken");
        } else {
          debugPrint("FAIL TO UPDATE USER'S TOKEN");
        }
      } else {
        debugPrint("Current token already the same");
      }
    } else {
      debugPrint("GOT NULL FROM REQUEST TOKEN");
    }
  } else if (user != null && user.firebaseToken != null) {
    debugPrint("User Token has already set: ${user.firebaseToken}");
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

notificationListener(context) {
  _fcm.configure(onMessage: (Map<String, dynamic> message) async {
    debugPrint("onMessage: $message");

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _showNotificationWithDefaultSound(message);
    // var android = AndroidNotificationDetails(
    //   // 'com.jlf.mobile',
    // );

    // showDialogs(message['notification']['body'], context);

    // final snackbar = SnackBar(
    //   content: Text(message['notification']['title']),
    //   action: SnackBarAction(
    //     label: 'Go',
    //     onPressed: () => null,
    //   )
    // );

    // Scaffold.of(context).showSnackBar(snackbar);
  }, onLaunch: (Map<String, dynamic> message) async {
    debugPrint("onLaunch: $message");
  }, onResume: (Map<String, dynamic> message) async {
    debugPrint("onResume: $message");
  });
}

Future onSelectNotification(String payload) async {
  debugPrint(payload);
}

Future _showNotificationWithDefaultSound(Map<String, dynamic> message) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message['notification']['body'],
    message['notification']['title'],
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

/// Global Function to return Alert Dialog
Future<bool> showDialogs(String content, BuildContext context,
    {String title = "Perhatian",
    String route = "",
    bool isDouble = false,
    bool isLogout = false,
    bool needVerify = false,
    String text = "Tutup"}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.black)),
        content: myText(text: content),
        actions: <Widget>[
          needVerify
              ? FlatButton(
                  child: Text("Verifikasi Sekarang"),
                  onPressed: () {
                    // Navigator.of(context).pop(true);
                    // Navigator.pushNamed(context, "/verification");
                  },
                )
              : Container(),
          FlatButton(
            child: Text(text),
            onPressed: () {
              if (text != "Tutup") {
                Navigator.pop(context);
              } else if (isLogout) {
                deleteLocalData("user");
                state = "login";
                try {
                  logout(user.tokenRedis);
                } catch (e) {
                  debugPrint(e.toString());
                }
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/login");
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

Future<bool> showDialogsVerificationOptions(
    String content, BuildContext context,
    {String title = "Perhatian",
    String route = "",
    String option1 = "Via OTP WA",
    String option2 = "Via KTP",
    String phoneNumber,
    int userId}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.black)),
        content: myText(text: content),
        actions: <Widget>[
          FlatButton(
            child: Text("Via KTP"),
            onPressed: () {
              Navigator.pushNamed(context, "/verification");
            },
          ),
          FlatButton(
            child: Text("Via OTP WA"),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SendOTPPage(
                          phoneNumber: phoneNumber, userId: userId)));
              // Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

/// Global Function to confirm user when back key will resulting in closing App
Future<bool> willExit(BuildContext context,
    {String titleText = "Perhatian",
    String contentText = "Apakah anda yakin akan keluar?",
    String cancelText = "Batal",
    String exitText = "Keluar"}) {
  return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleText),
            content: Text(contentText, style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  exitText,
                  // style: TextStyle(color: Colors.black)
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(
                  cancelText,
                  // style: TextStyle(color: Colors.black)
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              VerticalDivider(
                width: 10,
                color: Colors.black,
              ),
            ],
          );
        },
      ) ??
      false;
}

String formaterTimer(int seconds) {
  int hours = (seconds / 3600).truncate();
  seconds = (seconds % 3600).truncate();
  int minutes = (seconds / 60).truncate();

  String hoursStr = (hours).toString().padLeft(2, '0');
  String minutesStr = (minutes).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  if (hours == 0) {
    return "$minutesStr:$secondsStr";
  }

  return "$hoursStr jam :$minutesStr menit :$secondsStr detik";
}

Future<bool> showDialogBlockRekber(List<Auction> content, BuildContext context,
    {String title = "BELUM TERBAYAR", String text = "Tutup"}) {
  Widget _buildCardBlocker(Auction auction) {
    // final dateNow = DateTime.now();
    // DateTime targetTime =
    //     DateTime.parse(auction.winnerAcceptedDate).add(Duration(days: 1));

    // final differenceSec = (targetTime.difference(dateNow).inSeconds).abs();
    // String timer = formaterTimer(differenceSec);

    String winnerDate = convertFormatDateTime(auction.winnerAcceptedDate);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ChatPage(auction: auction)));
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Container(
                height: 35,
                child: CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: auction.owner.photo != null &&
                                auction.owner.photo.isNotEmpty
                            ? FadeInImage.assetNetwork(
                                image: auction.owner.photo,
                                placeholder: 'assets/images/loading.gif',
                                fit: BoxFit.cover)
                            : Image.network('assets/images/account.png')))),
            Column(
              children: <Widget>[
                myText(
                  text: generateInvoice(auction),
                  decoration: TextDecoration.underline,
                  weight: "B",
                ),
                myText(
                    text: auction.owner.name,
                    textOverflow: TextOverflow.ellipsis),
                myText(
                    text: auction.animal.name,
                    textOverflow: TextOverflow.ellipsis),
                myText(
                    text: "Rp. " +
                        convertToMoney(auction.winnerBid.amount.toDouble()),
                    textOverflow: TextOverflow.ellipsis),
                myText(text: winnerDate),
                // myText(text: "$timer", size: 12),
              ],
            ),
            Icon(Icons.near_me),
          ],
        ),
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(title, style: TextStyle(color: Colors.black)),
        ),
        content: Container(
          width: mw(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/block-rekber.jpeg",
              ),
              myText(
                  text:
                      "Lakukan pelunasan rekber dahulu untuk melanjutkan proses lelang lainnya",
                  align: TextAlign.center,
                  size: 16),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              Expanded(
                child: Container(
                    color: Colors.white,
                    child: Scrollbar(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: content.length,
                          itemBuilder: (context, int index) {
                            return _buildCardBlocker(content[index]);
                          }),
                    )),
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
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

Widget appBar(GlobalKey<ScaffoldState> scaffoldKey, context,
    {bool isSubMenu = false,
    bool showNotification = true,
    bool hideNavigation = false}) {
  return AppBar(
    title: GestureDetector(
      onTap: () {
        Navigator.popUntil(context, ModalRoute.withName("/"));
      },
      child:
          Container(child: Image.asset("assets/images/logo.png", height: 45)),
    ),
    leading: hideNavigation
        ? Container()
        : isSubMenu
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })
            : IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  if (scaffoldKey.currentState.isDrawerOpen)
                    scaffoldKey.currentState.openEndDrawer();
                  else
                    scaffoldKey.currentState.openDrawer();
                }),
    actions: <Widget>[showNotification ? myAppBarIcon(context) : Container()],
    centerTitle: true,
  );
}

Widget myAppBarIcon(context) {
  return Row(
    children: <Widget>[
      GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/chat-list'),
        child: Center(
          child: Container(
              margin: EdgeInsets.only(right: 10),
              width: 30,
              height: 30,
              child: Stack(
                children: [
                  Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 30,
                  ),
                  user != null &&
                          user.unreadChatCount != null &&
                          user.unreadChatCount > 0
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
                                  "${user.unreadChatCount}",
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
      ),
      GestureDetector(
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
                  user != null &&
                          user.historiesCount != null &&
                          user.historiesCount > 0
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
      ),
    ],
  );
}

Widget spacePadding({double padding = 20}) {
  return Padding(padding: EdgeInsets.only(bottom: padding));
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

void autoClose() async {
  await AuctionService.autoClose(user.tokenRedis);
}

void getNotificationCount() async {
  if (user != null && user.id != null) {
    int historiesCount = await getHistoriesCount(user.id, user.tokenRedis);

    if (historiesCount != null) {
      user.historiesCount = historiesCount;
    }

    int bidsCount = await getBidsCount(user.id, user.tokenRedis);

    if (bidsCount != null) {
      user.bidsCount = bidsCount;
    }

    int unreadChatCount = await getUnreadChatsCount(user.id, user.tokenRedis);

    if (unreadChatCount != null) {
      user.unreadChatCount = unreadChatCount;
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
  String spDate = date.split(" ")[0];
  List<String> splitDate = spDate.split("-");
  String month = convertMonthFromDigitSimple(int.parse(splitDate[1]));
  newDate = "${splitDate[2]}-$month-${splitDate[0]}";
  return newDate;
}

String convertFormatDayMonth(String date) {
  String newDate = "";
  String spDate = date.split(" ")[0];
  List<String> splitDate = spDate.split("-");
  String month =
      convertMonthFromDigitSimple(int.parse(splitDate[1])).toUpperCase();
  newDate = "${splitDate[2]} $month";
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

String convertFormatDateTime(String date) {
  String newDate = "";
  if (date == null || date == "") {
    return "-";
  }
  List<String> split = date.split(" ");
  List<String> splitTime = split[1].split(":");

  List<String> splitDate = split[0].split("-");
  newDate =
      "${splitDate[2]}/${splitDate[1]}/${splitDate[0]}  ${splitTime[0]}:${splitTime[1]}";
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
    case 2:
      month = 'Februari';
      break;
    case 3:
      month = 'Maret';
      break;
    case 4:
      month = 'April';
      break;
    case 5:
      month = 'Mei';
      break;
    case 6:
      month = 'Juni';
      break;
    case 7:
      month = 'Juli';
      break;
    case 8:
      month = 'Agustus';
      break;
    case 9:
      month = 'September';
      break;
    case 10:
      month = 'Oktober';
      break;
    case 11:
      month = 'November';
      break;
    case 12:
      month = 'Desember';
      break;
    default:
  }

  return month;
}

String convertMonthFromDigitSimple(int monthDigit) {
  String month = 'Jan';

  switch (monthDigit) {
    case 2:
      month = 'Feb';
      break;
    case 3:
      month = 'Mar';
      break;
    case 4:
      month = 'Apr';
      break;
    case 5:
      month = 'Mei';
      break;
    case 6:
      month = 'Jun';
      break;
    case 7:
      month = 'Jul';
      break;
    case 8:
      month = 'Ags';
      break;
    case 9:
      month = 'Sep';
      break;
    case 10:
      month = 'Okt';
      break;
    case 11:
      month = 'Nov';
      break;
    case 12:
      month = 'Des';
      break;
    default:
  }

  return month;
}

String convertFormatDateDayMonth(String date, {bool monthName = false}) {
  String newDate = "";
  String month = "";
  List<String> split = date.split(" ");
  List<String> splitDate = split[0].split("-");

  month = monthName
      ? convertMonthFromDigitSimple(int.parse(splitDate[1]))
      : splitDate[1];
  newDate = "${splitDate[2]}/$month";
  return newDate;
}

Widget isLoading() {
  return Container(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget failLoadImage() {
  return Container(
    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
    height: 110,
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
  def = "${(dateNow.difference(exptDate).inSeconds).abs()} Detik";

  //1 year
  if (differenceMinutes > 525600) {
    def = "${differenceMinutes ~/ 525600} Tahun";
  }
  //1 month
  else if (differenceMinutes > 43200) {
    def = "${differenceMinutes ~/ 43200} Bulan";
  }
  //1 day
  else if (differenceMinutes > 1440) {
    def = "${differenceMinutes ~/ 1440} Hari";
  }

  //1 hour
  else if (differenceMinutes > 60) {
    def = "${differenceMinutes ~/ 60} Jam";
  } else if (differenceMinutes > 1) {
    def = "$differenceMinutes Min";
  }

  return def;
}

int convertDateToHour(String dateTime) {
  final date = DateTime.parse(dateTime);
  final dateNow = DateTime.now();
  return (dateNow.difference(date).inHours).abs();
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
    case "light-blue":
      returnedColor = Color.fromRGBO(73, 187, 255, 1);
      break;
    case "mimosa":
      // for current bid
      returnedColor = Color.fromRGBO(239, 192, 80, 1);
      break;
    case "danger":
      returnedColor = Colors.red;
      break;
    case "hot-auction":
      returnedColor = Color.fromRGBO(221, 136, 68, 1);
      break;
    case "warning":
      returnedColor = Colors.deepOrange;
      break;
    case "secondary":
      returnedColor = Colors.deepOrange;
      break;
    case "success":
      returnedColor = Colors.green;
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
    case "grey":
      returnedColor = Colors.grey;
      break;
    case "unprime2":
      returnedColor = Color.fromRGBO(0, 0, 32, 1);
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

Future<bool> confirmDialog(String content, context,
    [String title = "Perhatian"]) {
  return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: myText(text: content),
            actions: <Widget>[
              FlatButton(
                child: Text("Ya",
                    style: TextStyle(color: Colors.red[300], fontSize: 18)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(
                  "Tidak",
                  style: TextStyle(color: Colors.blue[600], fontSize: 18),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              VerticalDivider(
                width: 10,
                color: Colors.white,
              ),
            ],
          );
        },
      ) ??
      false;
}

void mailError(String errrorFrom, String cause) async {
  String username = 'joe.technubi@gmail.com';
  String password = 'kmzway87AAA';

  if (!isProduction) {
    debugPrint(cause);
    return;
  }

  final smtpServer = gmail(username, password);

  // Create our message.
  final message = mailer.Message()
    ..from = mailer.Address(username, 'JLF Err')
    ..recipients.add('joe.technubi@gmail.com')
    ..recipients.add('ervansanjaya@gmail.com')
    ..subject =
        'Error $flavor $version JLF - $errrorFrom :: ${user.email} :: ${user.username} :: ${new DateTime.now()}'
    ..html = cause;

  await mailer.send(message, smtpServer);
  debugPrint("sended");
}

Future<bool> showUpdate(
    urlUpdate, bool isForceUpdate, String message, context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: !isForceUpdate,
        builder: (BuildContext context) {
          return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset("assets/images/new_update.png"),
                    SizedBox(
                      height: 20,
                    ),
                    myText(text: message)
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    color: myColor("primary"),
                    child: myText(text: "Perbaharui Aplikasi", color: "light"),
                    onPressed: () {
                      launch(urlUpdate);
                    },
                  ),
                ],
              ) ??
              false;
        },
      ) ??
      false;
}

void debugPrint(content) {
  if (!isProduction) {
    return print(content);
  }
}

void sendWhatsApp(phone, message) async {
  if (phone.isNotEmpty && message.isNotEmpty) {
    String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// TODO: Integrate with Laravel
void sendOTP(targetPhoneNumber) async {
  final header = {
    "Authorization":
        "u9CRJ3ZsFfD6JVa6rSa6QWvuz3IsZfIVs3XFer4ed0vNh7kHy2PtiqlurHYGsTSA"
  };
  final url = 'https://wablas.com/api/send-message';
  final message = 'OTP: 123456';
  final _params = {"phone": targetPhoneNumber, "message": message};

  http.Response res = await http
      .post(url, headers: header, body: json.encode(_params))
      .timeout(Duration(seconds: getTimeOut()));

  if (res.statusCode == 200) {
    debugPrint('OTP sent');
  } else {
    throw Exception(res.body);
  }

  // if (phone.isNotEmpty && message.isNotEmpty) {
  //   String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}
