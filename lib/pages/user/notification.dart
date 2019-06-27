import 'package:flutter/material.dart';

import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/history.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/history_services.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<History> histories = List<History>();
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getHistories();
  }

  _getHistories() {
    getHistories("Token", globals.user.id).then((onValue) {
      histories = onValue;
      print(histories);
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: isLoading
                ? globals.isLoading()
                : SafeArea(
                    child: Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Center(
                              child: globals.myText(
                                  text: "NOTIFIKASI",
                                  weight: "B",
                                  color: "dark",
                                  size: 22))),
                      Flexible(
                        child: histories.length > 0 ? ListView.builder(
                          itemCount: histories.length,
                          itemBuilder: (BuildContext context, int i) {
                            if (i.isOdd) return Divider();
                            return ListTile(
                              leading: Icon(Icons.notifications_active),
                              title: globals.myText(text: histories[i].information, color: "dark")
                            );
                          },
                        ) : Container(
                          child: globals.myText(text: "Tidak ada notifikasi", color: "dark")
                        ),
                      )
                    ]),
                  )));
  }
}
