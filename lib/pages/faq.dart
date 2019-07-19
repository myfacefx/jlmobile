import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    globals.getNotificationCount();
  }

  Widget _buildQuestionAnswers() {
    return Container(
        child: ListView(
      children: <Widget>[
        ExpansionTile(
          title: globals.myText(
              text: "Kenapa Saya harus menggunakan Rekber?", color: "primary"),
          children: <Widget>[globals.myText(text: "TEST", color: "primary")],
        ),
        ExpansionTile(
          title: globals.myText(
              text: "Berapa biaya jasa untuk menggunakan rekber?",
              color: "primary"),
          children: <Widget>[
            globals.myText(
                text: "Kami tidak pernah menerima biaya", color: "primary")
          ],
        )
      ],
    ));
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
                children: <Widget>[
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
                              child: globals.myText(
                                  text: "FAQ",
                                  size: 12,
                                  color: "primary",
                                  weight: "B"),
                            ),
                            Tab(
                              child: globals.myText(
                                  text: "What's New",
                                  size: 12,
                                  color: "primary",
                                  weight: "B"),
                            ),
                            Tab(
                              child: globals.myText(
                                  text: "Credit",
                                  size: 12,
                                  color: "primary",
                                  weight: "B"),
                            )
                          ],
                        )),
                        Container(
                          height: 400,
                          // padding: EdgeInsets.all(5),
                          child: TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              _buildQuestionAnswers(),
                              _buildQuestionAnswers(),
                              _buildQuestionAnswers()
                            ],
                          ),
                        )
                      ],
                    )),
                  ),
                ],
                // children: <Widget>[
                //   // padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                //   child: TabBar(
                //     controller: _tabController,
                //     tabs: <Widget>[
                //       Tab(
                //         child: globals.myText(text: "FAQ", size: 12, color: "primary", weight: "B"),
                //       ),
                //       Tab(
                //         child: globals.myText(text: "Whats's New", size: 12, color: "primary", weight: "B"),
                //       ),
                //       Tab(
                //         child: globals.myText(text: "Credit", size: 12, color: "primary", weight: "B"),
                //       )
                //     ]),
                // ],
              ),
            )));
  }
}
