import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: globals.drawer(context),
            body: SafeArea(
              child: Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                  child: Column(children: <Widget>[
                    Text("FAQ",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    globals.spacePadding(),
                    Text("Bagaimana cara mendaftar akun pada JLF?",
                        style: Theme.of(context).textTheme.subtitle,
                        textAlign: TextAlign.center)
                  ]),
                ),
              ),
            )));
  }
}
