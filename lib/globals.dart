import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart'
    show AdvancedNetworkImage;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:validators/validators.dart';

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

String getBaseUrl() {
  return baseUrl;
}

/// Global Function to return Alert Dialog
Future<bool> showDialogs(String content, BuildContext context,
    {String title = "Perhatian",
    String route = "",
    bool isDouble = false,
    Function openSetting,
    String text = "Close"}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            child: Text(text),
            onPressed: () {
              if (text != "Close") {
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

Widget bottomAppBar() {
  return Container(
      height: 20,
      color: Color.fromRGBO(201, 0, 0, 1),
      child: Center(
        child: Text(
          "Take care of your product, avoid blacklist member | check here",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ));
}

Widget appBar(_scaffoldKey) {
  return AppBar(
    title: Text("JLF"),
    leading: new IconButton(
        icon: new Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState.openDrawer()),
    centerTitle: true,
  );
}

Widget drawer() {
  return Drawer(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: ListView(padding: EdgeInsets.all(10.0), children: []),
      ),
    ),
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
