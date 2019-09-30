import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
  }

  Widget _buildBackground() {
    return Positioned(
      child: Center(
        child: Image.asset(
          'assets/images/jlf-back.png',
          width: globals.mw(context),
          height: globals.mh(context),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
        height: globals.mh(context) * 0.4,
        child: Center(
          child: Image.asset("assets/images/logo.png", height: 140),
        ));
  }

  Widget _buildEssayTeam() {
    return Container(
      child: globals.myText(
          text: "Berikut adalah team yang akan berhubungan dengan customer JLF , apabila" +
              "anda mendapati dihubungi nomor diluar yang tertera di bawah ini silahkan" +
              "abaikan atau hubungi nomor dibawah ini untuk verifikasi.",
          align: TextAlign.center,
          letterSpacing: 1,
          size: 16),
    );
  }

  Widget _buildContact(String content, String number) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Desc's Container
          Container(
            width: globals.mw(context) * 0.70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: globals.myText(
                      text: content,
                      weight: "B",
                      size: 16,
                      align: TextAlign.start),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: globals.myText(text: number, size: 16),
                ),
              ],
            ),
          ),

          // Button Copy
          Container(
            width: globals.mw(context) * 0.10,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(new ClipboardData(text: number));
                globals.showDialogs("Berhasil menyalin", context);
              },
              child: Container(
                  padding: EdgeInsets.all(3),
                  width: 30,
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.content_copy,
                          size: 14, color: globals.myColor("primary")),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
          key: _scaffoldKey,
          drawer: drawer(context),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  _buildBackground(),
                  ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _logo(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: globals.mh(context) * 0.1,
                          ),
                          globals.myText(
                              text: "Tim JLF", weight: "B", size: 20),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                            child: Column(
                              children: <Widget>[
                                _buildEssayTeam(),
                                SizedBox(height: 25),
                                _buildContact("KERJASAMA BISNIS","+62 856-4387-8166"),
                                SizedBox(height: 10),
                                _buildContact("ADMIN DAN CUSTOMER SERVICE", "+62 822-2330-4275"),
                                SizedBox(height: 10),
                                _buildContact("ADMIN SEKTOR BURUNG", "+62 817-723-617"),
                                SizedBox(height: 10),
                                _buildContact("SALES DAN MARKETING", "+62 877-0831-0833"),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
