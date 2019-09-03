import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/user_services.dart';

class BlacklistPage extends StatefulWidget {
  @override
  _BlacklistPageState createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool failedDataFetching = false;
  List<User> blacklistedUser = List<User>();
  List<Container> blacklistedUserCard = List();

  @override
  void initState() {
    super.initState();
    _getListBlacklistedUser();
    globals.getNotificationCount();
  }

  void _getListBlacklistedUser() {
    setState(() {
      failedDataFetching = false;
      isLoading = true;
    });
    getBlacklistedUser(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      blacklistedUser = onValue;
      _generateBlacklistedUserCard();
    }).catchError((onError) {
      failedDataFetching = true;
    }).then((_) {
      isLoading = false;

      if (!mounted) return;
      setState(() {});
    });
  }

  _generateBlacklistedUserCard() {
    blacklistedUserCard = List();
    for (var i = 0; i < blacklistedUser.length; i++) {
      blacklistedUserCard.add(Container(
          height: 15,
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Expanded(
                      //   child:
                      Text(blacklistedUser[i].username.toUpperCase(),
                          style: TextStyle(color: Colors.black, fontSize: 11),
                          textAlign: TextAlign.left),
                      // ),
                      blacklistedUser[i].reportsCount > 0
                          ? Text("${blacklistedUser[i].reportsCount} Report",
                              style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.left)
                          : Text(""),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Flexible(
                          child: blacklistedUser[i].photo != null
                              ? FadeInImage.assetNetwork(
                                  fit: BoxFit.fill,
                                  placeholder: 'assets/images/loading.gif',
                                  image: blacklistedUser[i].photo)
                              : Container())
                      // image: 'https://thenypost.files.wordpress.com/2018/10/102318-dogs-color-determine-disesases-life.jpg?quality=90&strip=all&w=618&h=410&crop=1'),
                    ],
                  )))));
    }
  }

  // Widget _buildCard(int index, User user) {
  //   return Text(user.name, style: TextStyle(color: Colors.black));
  // }
  Widget _buildFailedLoadingData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
              shape: CircleBorder(),
              onPressed: () => _getListBlacklistedUser(),
              child: Icon(Icons.refresh,
                  color: Theme.of(context).accentColor, size: 50)),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Text("Gagal memuat data, klik untuk refresh",
              style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildGridBlacklistedUser() {
    return Flexible(
        child: failedDataFetching
            ? _buildFailedLoadingData()
            : isLoading
                ? Container(child: Center(child: CircularProgressIndicator()))
                : blacklistedUser.length > 0
                    ? Container(
                        child: GridView.count(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            children: blacklistedUserCard))
                    : Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Tidak ada pengguna yang memiliki status blacklist",
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        )));
  }

  Widget _buildPageTitle() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Text(
            "Blacklist member adalah daftar pengguna yang memiliki predikat buruk dalam bertransaksi. Masuknya ke blacklist biasanya dikarenakan adanya tindakan yang membahayakan atau penipuan.",
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.justify));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: Column(children: <Widget>[
                _buildPageTitle(),
                _buildGridBlacklistedUser(),
              ]),
            )));
  }
}
