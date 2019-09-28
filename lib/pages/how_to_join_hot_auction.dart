import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/static_services.dart';

class HowToJoinHotAuctionPage extends StatefulWidget {
  @override
  _HowToJoinHotAuctionState createState() => _HowToJoinHotAuctionState();
}

class _HowToJoinHotAuctionState extends State<HowToJoinHotAuctionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String url = "https://placeimg.com/300/420/animals?4";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
    getAllStatics().then((onValue) {
      if (onValue.length > 0) {
        if (onValue[0].howToJoinHotAuctionImageUrl != "" &&
            onValue[0].howToJoinHotAuctionImageUrl != null) {
          globals.debugPrint(onValue[0].howToJoinHotAuctionImageUrl);
          url = onValue[0].howToJoinHotAuctionImageUrl;
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: isLoading
                  ? globals.isLoading()
                  : Container(
                      width: globals.mw(context),
                      height: globals.mh(context),
                      child: 
                        Column(
                          children: <Widget>[
                            FlatButton(
                              color: globals.myColor("primary"),
                              child: globals.myText(
                                  text: "Tekan disini untuk Hubungi Admin WA JLF", color: "light"),
                              onPressed: () {
                                  globals.sendWhatsApp(globals.getNohpAdmin(),
                                  "Halo . . .");
                              },
                            ),
                            FadeInImage.assetNetwork(
                              fit: BoxFit.contain,
                              placeholder: 'assets/images/loading.gif',
                              image: url,
                            ),
                          ],
                        )
                    ),
            )));
  }
}