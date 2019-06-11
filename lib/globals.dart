import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_networkimage/provider.dart'
    show AdvancedNetworkImage;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:validators/validators.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

/// Global Function to return Screen Height
double mh(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Global Function to return Screen Width
double mw(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

String baseUrl = "http://192.168.100.119:8000";
String flavor = "Development";
String state = "Login";

// Global timeout setting
int timeOut = 30;

int getTimeOut() {
  return timeOut;
}

String getBaseUrl() {
  return baseUrl;
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
        content: Text(content),
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
      color: Color.fromRGBO(201, 0, 0, 1),
      child: Center(
        child: Text(
          "Take care of your product, avoid blacklist member | check here",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      )
    )
  );
}

Widget appBar(GlobalKey<ScaffoldState> scaffoldKey, context) {
  return AppBar(
    title: Text("JLF"),
    leading: new IconButton(
      icon: new Icon(Icons.menu),
      onPressed: () {
        if (scaffoldKey.currentState.isDrawerOpen) scaffoldKey.currentState.openEndDrawer();
        else scaffoldKey.currentState.openDrawer();
      }
    ),
    actions: <Widget>[
      myAppBarIcon(context)
    ],
    centerTitle: true,
  );
}

Widget myAppBarIcon(context){
  return GestureDetector(
    onTap: () {
        
    },
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
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 0),
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffc32c37),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Text(
                      "1",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    ),
  );
}

Widget _buildDrawerNavigationButtonBig(title, route, context) {
  return Container(
    padding: EdgeInsets.fromLTRB(0, 3, 20, 5),
    child: FlatButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.all(0),
      // shape: StadiumBorder(side: BorderSide),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10)
        )
      ),
      color: Colors.white,
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 8),
              child: Text(title,  style: TextStyle(color: Theme.of(context).primaryColor)),
            )
            // Container(
            //   width: 20,
            //   child: RaisedButton(
            //     onPressed: () {},
            //     color: Theme.of(context).primaryColor,
            //     child: Text("10", style: Theme.of(context).textTheme.display4)
            //   )
            // )
          ]
        )
      ),
    ),
  );
}

Widget _buildDrawerNavigationButtonSmall(title, route, context) {
  return Container(
    padding: EdgeInsets.fromLTRB(0, 5, 60, 0),
    height: 35,
    child: OutlineButton(
      padding: EdgeInsets.only(left: 8),
      borderSide: BorderSide(
        color: Colors.white
      ),
      highlightColor: Colors.white10,
      highlightedBorderColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10)
        )
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      }, 
      child: SizedBox(
        width: double.infinity,
        child: Text(title, style: Theme.of(context).textTheme.display1)
      ),
    )
  );
}

Widget drawer(context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.55,
    child: Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: ListView(
          children: <Widget>[
            // Avatar
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
              height: 150,
              child: CircleAvatar(
                radius: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FadeInImage.assetNetwork(
                    image:'https://66.media.tumblr.com/d3a12893ef0dfec39cf7335008f16c7f/tumblr_pcve4yqyEO1uaogmwo8_400.png',
                    placeholder: 'assets/images/loading.gif',
                    fit: BoxFit.cover
                  )
                )
              )
            ),          
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: OutlineButton(
                  onPressed: () {},
                  color: Colors.transparent,
                  highlightColor: Colors.white10,
                  highlightedBorderColor: Colors.white,
                  borderSide: BorderSide(color: Colors.white),
                  child: Text("Edit Profile", style: Theme.of(context).textTheme.display4),
                )
              )
            ),
            spacePadding(),
            _buildDrawerNavigationButtonBig("Auction", '/home', context),
            // _buildDrawerNavigationButtonBig("Our Shop Products", context),
            _buildDrawerNavigationButtonBig("Bid", '/home', context),
            // _buildDrawerNavigationButtonBig("Our Carts", context),
            // _buildDrawerNavigationButtonBig("Notification", '/notification', context),
            spacePadding(),
            _buildDrawerNavigationButtonSmall("About", "/about", context),
            _buildDrawerNavigationButtonSmall("How To", "/how-to", context),
            _buildDrawerNavigationButtonSmall("FAQ", "/faq", context),
            _buildDrawerNavigationButtonSmall("Setting", "/setting", context),
            _buildDrawerNavigationButtonSmall("Log Out", "/logout", context),
            spacePadding()
            // Container()
          ],
        )
      )
      // child: Align(
      //   alignment: Alignment.bottomCenter,
      //   child: Container(
      //     child: ListView(padding: EdgeInsets.all(10.0), children: []),
      //   ),
      // ),
    ),
  );
}

Widget spacePadding() {
  return Padding(
    padding: EdgeInsets.only(bottom: 20)
  );
}

Future<ImageProvider> imageUrlProvider(String link,
    [ImageProvider defaultPic =
        const AssetImage("assets/images/error.png")]) async {
  /// Variable to hold Image Provider to be returned later
  ImageProvider retImg;
  // check if the link is valid link or not
  link = isURL(link) ? link : "-";
  // if link is invalid, do not proceed
  if (link == "-") {
    retImg = defaultPic;
  } else {
    /// load local image as [ByteData] from bundle to be used as alternative on network failure
    /// or a valid link does not provide a valid image
    ByteData bytes = await rootBundle.load('assets/images/account.png');

    /// buffer [bytes] as [Uint8List] to be used on [AdvancedNetworkImage] alternative
    Uint8List list = bytes.buffer.asUint8List();
    retImg = AdvancedNetworkImage(link, fallbackImage: list);
  }
  return retImg;
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