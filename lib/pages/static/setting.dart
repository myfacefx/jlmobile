import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
                child: Center(
                  child: Column(children: <Widget>[
                    Text("Pengaturan",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.black)),
                    globals.spacePadding(),
                    // Text("JLF atau Jual Lelang Fauna merupakan situs rintisan awal dari para pecinta reptil yang juga senang berbisnis, mengingat hingga saat ini masih belum ada marketplace yang nyaman digunakan maka kami ingin mencoba memberikan inovasi marketplace yang tidak hanya sekedar untuk jual beli namun juga lelang.", style: Theme.of(context).textTheme.subtitle, textAlign: TextAlign.justify)
                  ]),
                ),
              ),
            )));
  }
}
