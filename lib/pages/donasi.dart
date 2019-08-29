import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class DonasiPage extends StatefulWidget {
  @override
  _DonasiPageState createState() => _DonasiPageState();
}

class _DonasiPageState extends State<DonasiPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    globals.getNotificationCount();
  }

  Widget _buildQuestionAnswers() {
    return Container(
        child: ListView(
      children: <Widget>[
        ExpansionTile(
          title: globals.myText(
              text: "Silakan donasi ke ", color: "primary"),
          children: <Widget>[globals.myText(text: "TEST", color: "primary")],
        ),
        ExpansionTile(
          title: globals.myText(
              text: "Silakan donasi ke",
              color: "primary"),
          children: <Widget>[
            globals.myText(
                text: "-----", color: "primary")
          ],
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
              child: 1 == 1 ? Container(margin: EdgeInsets.all(10), alignment: Alignment.center, child: globals.myText(text: "Nantikan segera..")) : ListView(children: <Widget>[
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
                                text: "Donasi",
                                size: 12,
                                color: "primary",
                                weight: "B"),
                          ),
                          Tab(
                            child: globals.myText(
                                text: "Sumbangan Donasi",
                                size: 12,
                                color: "primary",
                                weight: "B"),
                          ),
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
                          ],
                        ),
                      )
                    ],
                  )),
                ),
              ]),
            )));
  }
}
