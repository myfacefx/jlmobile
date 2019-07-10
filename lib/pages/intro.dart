import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/pages/user/login.dart';
import 'package:jlf_mobile/services/user_services.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

const intros = <String>[
  'assets/images/intro/intro1.jpg',
  'assets/images/intro/intro2.jpg',
  'assets/images/intro/intro3.jpg',
  'assets/images/intro/intro4.jpg',
  'assets/images/intro/intro5.jpg',
  'assets/images/intro/intro6.jpg',
];

class _IntroPageState extends State<IntroPage> {
  int count = 0;

  Widget _image(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return DefaultTabController(
      length: intros.length,
      child: Scaffold(
        body: Builder(
            builder: (BuildContext context) => Padding(
                  padding: EdgeInsets.all(16),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 26),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: TabBarView(
                            children: intros.map((f) {
                              count++;
                              if (count == intros.length) {
                                return Stack(
                                  children: <Widget>[
                                    _image(f),
                                    Positioned(
                                      bottom: 0,
                                      left: 50,
                                      right: 50,
                                      child: RaisedButton(
                                        child: Text("Next"),
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          saveLocalData('isNew', "true");
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          LoginPage()));
                                        },
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return _image(f);
                              }
                            }).toList(),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 50,
                        right: 50,
                        child: Center(child: TabPageSelector()),
                      )
                    ],
                  ),
                )),
      ),
    );
  }
}
