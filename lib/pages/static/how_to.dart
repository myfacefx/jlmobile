import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class HowToPage extends StatefulWidget {
  @override
  _HowToPageState createState() => _HowToPageState();
}

class _HowToPageState extends State<HowToPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                child: Column(children: <Widget>[
                  Text("Tutorial",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  globals.spacePadding(),
                  globals.myText(text: "Panduan untuk menggunakan seluruh fitur pada aplikasi JLF dapat dilihat pada Youtube Channel Sobat JLF", align: TextAlign.center),
                  SizedBox(height: 10),
                  FlatButton(
                    onPressed: () => launch("https://www.youtube.com/channel/UCW-Y3yIisBSOIJhV3ToA5oA"),
                    color: globals.myColor("primary"),
                    child: globals.myText(text: "Klik Disini", color: "light")
                  )
                ]),
              ),
            )));
  }
}
