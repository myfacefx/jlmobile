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

  Widget _buildTutorial() {
    return Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 4),
              child: globals.myText(
                  text: "STEP 1", size: 15, weight: "XB", color: "primary"),
            ),
            Container(
                padding: EdgeInsets.all(0),
                height: 200,
                child: Card(
                    color: globals.myColor("primary"), child: Container())),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: globals.myText(
                  text: "STEP 2", size: 15, weight: "XB", color: "primary"),
            ),
            Container(
                padding: EdgeInsets.all(0),
                height: 200,
                child: Card(
                    color: globals.myColor("primary"), child: Container())),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: globals.myText(
                  text: "STEP 3", size: 15, weight: "XB", color: "primary"),
            ),
            Container(
                padding: EdgeInsets.all(0),
                height: 200,
                child: Card(
                    color: globals.myColor("primary"), child: Container())),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: globals.myText(
                  text: "STEP 4", size: 15, weight: "XB", color: "primary"),
            ),
            Container(
                padding: EdgeInsets.all(0),
                height: 200,
                child:
                    Card(color: globals.myColor("primary"), child: Container()))
          ],
        ));
  }

  Widget _buildListRekber() {
    return Container(
        child: ListView(
      children: <Widget>[
        ListTile(
          title: globals.myText(text: "Rekber Jakarta"),
        ),
        ListTile(
          title: globals.myText(text: "Rekber Yogyakarta"),
        )
      ],
    ));
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
                text: "Kami tidak pernah menerima biaya", color: "danger")
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
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
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
                              Divider(),
                              globals.myText(
                                  color: "dark",
                                  text:
                                      "Rekening Bersama (RekBer) merupakan salah satu jasa pihak ketiga yang sering digunakan dalam transaksi jual - beli secara online. Dengan menggunakan rekber maka transaksi jual beli online akan lebih mudah dan saling mempercayai antara penjual dan pembeli.")
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.topCenter,
                          child:
                              Image.asset('assets/images/rekber-pembeli.jpeg')),
                    ),
                    Card(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.topCenter,
                          child:
                              Image.asset('assets/images/rekber-penjual.jpeg')),
                    )
                  ]),
                )
              ],
            ))));
  }
}
