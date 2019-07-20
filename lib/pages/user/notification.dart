import 'package:flutter/material.dart';

import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/history.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/history_services.dart';
import 'dart:convert';

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
    globals.getNotificationCount();
  }

  _getHistories() {
    List<int> listOfHistoryId = List<int>();

    getHistories("Token", globals.user.id).then((onValue) {
      histories = onValue;

      for (var history in histories) {
        // Iterate, if found 'read' = 0, add it to listOfHistoryId
        if (history.read == 0) {
          listOfHistoryId.add(history.id);
        }
      }

      setState(() {
        isLoading = false;
      });

      if (listOfHistoryId.length > 0) {
        _setHistories(listOfHistoryId);
      }
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  _setHistories(listOfHistoryId) {
    setHistories("Token", listOfHistoryId)
        .then((onValue) {})
        .catchError((onError) {
      print(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true, showNotification: false),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: isLoading
                ? globals.isLoading()
                : SafeArea(
                    child: Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Center(
                              child: globals.myText(
                                  text: "NOTIFIKASI",
                                  weight: "B",
                                  color: "dark",
                                  size: 22))),
                      Flexible(
                        child: histories.length > 0
                            ? ListView.builder(
                                padding: EdgeInsets.all(5),
                                itemCount: histories.length,
                                itemBuilder: (BuildContext context, int i) {
                                  List<Widget> informationBuild =
                                      List<Widget>();

                                  var informationConvert =
                                      json.decode(histories[i].information);

                                  if (informationConvert is String) {
                                    informationBuild.add(globals.myText(
                                        text: informationConvert,
                                        color: "dark"));
                                  } else {
                                    for (var value in informationConvert) {
                                      Widget output;
                                      if (value is String) {
                                        output = globals.myText(
                                            text: value, color: "dark");
                                      } else {
                                        var valueConvert = value;

                                        int userId = valueConvert['id'];

                                        output = GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProfilePage(
                                                              userId: userId))),
                                          child: globals.myText(
                                              text: valueConvert['username'],
                                              color: "primary",
                                              weight: "B"),
                                        );
                                      }

                                      informationBuild.add(output);
                                    }
                                  }
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ProductDetailPage(
                                                    animalId: histories[i]
                                                        .auction
                                                        .animalId,
                                                  )));
                                    },
                                    child: Card(
                                        color: histories[i].read == 0
                                            ? Colors.white
                                            : Colors.grey,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 3, right: 3),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  globals.myText(
                                                      weight: "B",
                                                      text: globals
                                                          .convertFormatDateTimeProduct(
                                                              histories[i]
                                                                  .createdAt
                                                                  .toString())),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    8, 5, 8, 8),
                                                child: Wrap(
                                                    children: informationBuild))
                                          ],
                                        )),
                                  );
                                },
                              )
                            : Container(
                                child: globals.myText(
                                    text: "Tidak ada notifikasi",
                                    color: "dark")),
                      )
                    ]),
                  )));
  }
}
