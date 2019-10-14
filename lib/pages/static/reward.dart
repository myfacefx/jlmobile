import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/static_services.dart';

class RewardPage extends StatefulWidget {
  @override
  _RewardState createState() => _RewardState();
}

class _RewardState extends State<RewardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String url = "https://placeimg.com/300/420/animals?4";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
    getAllStatics().then((onValue) {
      if (onValue.length > 0) {
        if (onValue[0].rewardImageUrl != "" &&
            onValue[0].rewardImageUrl != null) {
          globals.debugPrint(onValue[0].rewardImageUrl);
          url = onValue[0].rewardImageUrl;
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