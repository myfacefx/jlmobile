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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
          key: _scaffoldKey,
          drawer: drawer(context),
          body: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          globals.myText(
                              text: "Tentang JLF", weight: "B", size: 20),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                            child: globals.myText(
                                text: "JLF merupakan sebuah platform marketplace untuk para pecinta fauna, disini anda dapat melakukan jual beli " +
                                    "dan lelang. \n\nJLF terus bertumbuh dan berkembang dengan visi dapat menjadi sebuah wadah terbesar di " +
                                    "Indonesia untuk marketplace di sektor hewan, dengan misi untuk memberikan kemudahan, kenyamanan serta " +
                                    "integrasi dengan berbagai fitur lainya seperti logistik, asuransi, payment gateway dan berbagai integrasi " +
                                    "lainya.",
                                align: TextAlign.justify,
                                letterSpacing: 0.5,
                                size: 15),
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
