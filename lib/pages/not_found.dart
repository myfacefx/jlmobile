import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class NotFoundPage extends StatefulWidget {
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
      body: Center(
        child: globals.myText(text: "Halaman Yang Dicari Tidak Ditemukan"),
      ),
    );
  }
}
