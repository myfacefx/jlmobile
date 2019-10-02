import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatefulWidget {
  final String title, html, image, startDate, endDate;

  const ArticlePage(
      {Key key,
      @required this.title,
      @required this.html,
      @required this.image,
      @required this.endDate,
      @required this.startDate})
      : super(key: key);
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context,
            isSubMenu: true, showNotification: false),
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
                      Stack(
                        children: <Widget>[
                          ImageOverlay(image: widget.image),
                          Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 40),
                              globals.myText(
                                  text: widget.title.toUpperCase(), weight: "XB", size: 22, color: "light"),
                              SizedBox(height: 16),
                              globals.myText(
                                  text: "${globals.convertFormatDate(widget.startDate, simple: false)} - ${globals.convertFormatDate(widget.endDate, simple: false)}", size: 14, color: "light"),
                            ],
                          ))
                        ],
                      ),
                      Html(
                        data: widget.html,
                        onLinkTap: (url) {
                          if (canLaunch(url) != null) {
                            launch(url);
                          }
                        },
                        defaultTextStyle: TextStyle(
                          color: Colors.black
                        ),
                        padding: EdgeInsets.all(10)
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

class ImageOverlay extends StatefulWidget {
  final String image;
  ImageOverlay({this.image});
  @override
  _ImageOverlayState createState() => _ImageOverlayState();
}

class _ImageOverlayState extends State<ImageOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(height: 200, color: Color.fromRGBO(0, 0, 0, 0.8)),
      height: 200,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: new NetworkImage(this.widget.image), fit: BoxFit.fill)),
    );
  }
}
