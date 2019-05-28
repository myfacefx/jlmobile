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
        child: ListView(padding: EdgeInsets.all(10.0), children: [
         DrawerHeader(
           
         )
        ]),
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
