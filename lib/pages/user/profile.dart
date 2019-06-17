import 'package:flutter/material.dart';

import 'package:jlf_mobile/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin{
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;

  String _username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: globals.drawer(context),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                width: globals.mw(context),
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/edit-profile");
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.edit)
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              height: 100,
                              child: CircleAvatar(
                                  radius: 100,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FadeInImage.assetNetwork(
                                          image:
                                              'https://66.media.tumblr.com/d3a12893ef0dfec39cf7335008f16c7f/tumblr_pcve4yqyEO1uaogmwo8_400.png',
                                          placeholder: 'assets/images/loading.gif',
                                          fit: BoxFit.cover)))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.star, size: 15),
                                Text("4.5", style: TextStyle(color: Colors.grey))
                              ],
                            ),
                            Text(globals.user.username, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.location_on, size: 18, color: Theme.of(context).primaryColor),
                                Text("Kota Tangerang Selatan", style: TextStyle(color: Colors.grey))
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text("First hand importir anjing, silahkan lihat-lihat", style: TextStyle(color: Colors.grey))
                            )
                          ],
                        ),
                      ],
                    )
                  )
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: globals.mw(context),
                child: Card(
                  child: Container(
                    child: TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      controller: _tabController,
                      tabs: <Widget>[
                        Tab(
                          child: Text("Produk-ku", style: TextStyle(color: Colors.black, fontSize: 11)),
                        ),
                        Tab(
                          child: Text("Produk Lelang", style: TextStyle(color: Colors.black, fontSize: 11)),
                        ),
                        Tab(
                          child: Text("Produk Jual", style: TextStyle(color: Colors.black, fontSize: 11)),
                        ),
                        Tab(
                          child: Text("Tambahkan", style: TextStyle(color: Colors.black, fontSize: 11)),
                        )
                      ],
                    )
                  )
                )
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Card(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text("-", style: TextStyle(color: Colors.black, fontSize: 11))
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text("-", style: TextStyle(color: Colors.black, fontSize: 11))
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text("-", style: TextStyle(color: Colors.black, fontSize: 11))
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text("-", style: TextStyle(color: Colors.black, fontSize: 11))
                        )
                      ],
                    ),
                  ),
                )
              )
            ],
          )
        )
      )
    );
  }
}