import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
                              text: "Tentang JLF", weight: "B", size: 20),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                            child: globals.myText(
                                text: "JLF merupakan sebuah platform marketplace untuk para pecinta fauna, disini anda dapat melakukan jual beli" +
                                    "dan lelang. JLF terus bertumbuh dan berkembang dengan visi dapat menjadi sebuah wadah terbesar di" +
                                    "Indonesia untuk marketplace di sektor hewan, dengan misi untuk memberikan kemudahan, kenyamanan serta" +
                                    "integrasi dengan berbagai fitur lainya seperti logistik, asuransi, payment gateway dan berbagai integrasi" +
                                    " lainya.",
                                    align: TextAlign.center,
                                    letterSpacing: 1,
                                    size: 16
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
