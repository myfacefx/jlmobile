import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/static_services.dart';

class UpComingPage extends StatefulWidget {
  @override
  _UpComingPageState createState() => _UpComingPageState();
}

class _UpComingPageState extends State<UpComingPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String url = "https://placeimg.com/300/420/animals?4";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
    getAllStatics("token").then((onValue) {
      if (onValue.length > 0) {
        if (onValue[0].imageUpcoming != "" &&
            onValue[0].imageUpcoming != null) {
          print(onValue[0].imageUpcoming);
          url = onValue[0].imageUpcoming;
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
                      height: globals.mh(context),
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.contain,
                        placeholder: 'assets/images/loading.gif',
                        image: url,
                      ),
                    ),
            )));
  }
}
