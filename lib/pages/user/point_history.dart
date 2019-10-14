import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/point_history.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/point_history_services.dart';

class PointHistoryPage extends StatefulWidget {
  @override
  _PointHistoryPageState createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PointHistory> histories = List<PointHistory>();

  bool isLoading = true;

  TapGestureRecognizer _recognizerTap;

  @override
  void initState() {
    super.initState();
    _getHistories();
    globals.getNotificationCount();
  }

  _getHistories() {
    getPointHistories(globals.user.tokenRedis, globals.user.id)
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
                                  text: "Riwayat Poin",
                                  weight: "B",
                                  color: "dark",
                                  size: 22))),
                      Flexible(
                        child: histories.length > 0
                            ? ListView.builder(
                                padding: EdgeInsets.all(5),
                                itemCount: histories.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return histories.length > 0 ? Card(
                                    color: Colors.white,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              // Created At
                                              Container(
                                                color: Color.fromRGBO(223, 219, 236, 1),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: globals.mw(context) * 0.85,
                                                      padding: EdgeInsets.all(5),
                                                      child: globals.myText(
                                                                size: 10,
                                                                color:
                                                                    "unprime2",
                                                                text: histories[i].createdAt != null ? globals.convertFormatDateTime(
                                                                    histories[
                                                                            i]
                                                                        .createdAt
                                                                        .toString()) : '-')
                                                    ),
                                                    histories[i].point != null ? 
                                                    Container(
                                                      width: globals.mw(context) * 0.10,
                                                      padding: EdgeInsets.all(5),
                                                      child: globals.myText(
                                                                size: 10,
                                                                color:
                                                                    "success",
                                                                weight:  'B',
                                                                align: TextAlign.right,
                                                                text: histories[i].point.toString())) : Container(),
                                                  ],
                                                ),
                                              ),
                                              // Information
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(10),
                                                        child: globals.myText(text: histories[i].information, align: TextAlign.start),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ]
                                    )
                                  ) : Container(
                                child: globals.myText(
                                    text: "Belum ada poin reward yang didapatkan",
                                    color: "dark"));
                                }
                      ) : Container())
                    ]),
                  )));
  }
}
