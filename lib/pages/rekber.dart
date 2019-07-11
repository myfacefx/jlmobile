import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class RekberPage extends StatefulWidget {
  @override
  _RekberPageState createState() => _RekberPageState();
}

class _RekberPageState extends State<RekberPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                child: ListView(
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                  child: Column(children: <Widget>[
                    Container(
                      width: globals.mw(context),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              globals.myText(
                                  text: "APA ITU REKBER?",
                                  weight: "XB",
                                  color: "primary",
                                  size: 25,
                                  align: TextAlign.left),
                              globals.spacePadding(),
                              globals.myText(
                                  text:
                                      "Rekber atau kepanjangannya adalah Rekening Bersama, merupakan salah satu jasa pihak ketiga yang sering digunakan dalam transaksi jual - beli secara online. Dengan menggunakan rekber maka transaksi jual beli online akan lebih mudah dan saling mempercayai antara penjual dan pembeli.")
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: globals.mw(context),
                      child: Card(
                          child: Column(
                        children: <Widget>[
                          Container(
                              child: TabBar(
                            labelColor: globals.myColor("primary"),
                            indicatorColor: globals.myColor("primary"),
                            unselectedLabelColor: globals.myColor("primary"),
                            controller: _tabController,
                            tabs: <Widget>[
                              Tab(
                                child:
                                    globals.myText(text: "Tutorial", size: 12),
                              ),
                              Tab(
                                child: globals.myText(
                                    text: "List Rekber", size: 12),
                              ),
                              Tab(
                                child: globals.myText(
                                    text: "Tanya Jawab", size: 12),
                              )
                            ],
                          )),
                          Container(
                            height: 400,
                            // padding: EdgeInsets.all(5),
                            child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.all(10),
                                    child: globals.myText(
                                        text: "Stay Tune di JLF", size: 12)),
                                Container(
                                    padding: EdgeInsets.all(10),
                                    child: globals.myText(
                                        text: "Stay Tune di JLF", size: 12)),
                                Container(
                                    padding: EdgeInsets.all(10),
                                    child: globals.myText(
                                        text: "Stay Tune di JLF", size: 12)),
                              ],
                            ),
                          )
                        ],
                      )),
                    ),
                  ]),
                )
              ],
            ))));
  }
}
