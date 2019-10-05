import 'package:flutter/gestures.dart';
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

  TapGestureRecognizer _recognizerTap;

  @override
  void initState() {
    super.initState();
    _getHistories();
    globals.getNotificationCount();
    _recognizerTap = TapGestureRecognizer()
      ..onTap = () {
        //  globals.debugPrint();
      };
  }

  _getHistories() {
    getHistories(globals.user.tokenRedis, globals.user.id)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      histories = onValue;

      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  _setHistories(int listOfHistoryId) {
    setHistories(globals.user.tokenRedis, listOfHistoryId)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
    }).catchError((onError) {
      globals.debugPrint(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context,
            isSubMenu: true, showNotification: false),
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

                                  List<TextSpan> textSpans = List<TextSpan>();

                                  if (informationConvert is String) {
                                    textSpans.add(TextSpan(
                                        text: informationConvert,
                                        style: TextStyle(color: Colors.black)));

                                    informationBuild.add(globals.myText(
                                      text: informationConvert,
                                    ));
                                  } else {
                                    for (var value in informationConvert) {
                                      Widget output;
                                      if (value is String) {
                                        textSpans.add(TextSpan(
                                            text: value,
                                            style: TextStyle(
                                                color: Colors.black)));
                                        output = globals.myText(text: value);
                                      } else {
                                        textSpans.add(TextSpan(
                                            text: value['username'],
                                            style: TextStyle(
                                                color:
                                                    globals.myColor("primary"),
                                                fontWeight: FontWeight.bold),
                                            recognizer: _recognizerTap));

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

                                  List<int> listOfHistoryId = List<int>();
                                  listOfHistoryId.add(histories[i].id);

                                  return InkWell(
                                    onTap: () async {
                                      if (histories[i].auction != null) {
                                        _setHistories(histories[i].id);
                                        histories[i].read = 1;
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ProductDetailPage(
                                                          animalId: histories[i]
                                                              .auction
                                                              .animalId,
                                                          from: "LELANG",
                                                        )));
                                        setState(() {});
                                      } else {
                                        if (histories[i].animalId != null) {
                                          String from = 'LELANG';

                                          if (histories[i].type != null) {
                                            from =
                                                histories[i].type != 'auction'
                                                    ? ''
                                                    : 'LELANG';
                                          }
                                          histories[i].read = 1;
                                          _setHistories(histories[i].id);

                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProductDetailPage(
                                                            animalId:
                                                                histories[i]
                                                                    .animalId,
                                                            from: from,
                                                          )));
                                          setState(() {});
                                        } else {
                                          globals.showDialogs(
                                              "Notifikasi jual beli terbaru yang dapat menggunakan fitur ini",
                                              context);
                                        }
                                      }
                                    },
                                    child: Card(
                                        color: histories[i].read == 0
                                            ? Colors.grey[300]
                                            : Colors.white,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Flexible(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  8, 5, 8, 8),
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children:
                                                                      textSpans))
                                                          // child: Wrap(
                                                          //     children:
                                                          //         informationBuild)
                                                          ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 3,
                                                                left: 7),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 3),
                                                              child: globals.myText(
                                                                  size: 10,
                                                                  color:
                                                                      "unprime2",
                                                                  text: globals.convertFormatDateTime(
                                                                      histories[
                                                                              i]
                                                                          .createdAt
                                                                          .toString())),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  flex: 5,
                                                ),
                                                Flexible(
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    iconSize: 24,
                                                    onPressed: () async {
                                                      final res = await globals
                                                          .confirmDialog(
                                                              "Apakah anda yakin untuk menghapus?",
                                                              context);
                                                      if (res) {
                                                        deleteHistory("",
                                                            histories[i].id);
                                                        histories.remove(
                                                            histories[i]);
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                  flex: 1,
                                                )
                                              ],
                                            ),
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
