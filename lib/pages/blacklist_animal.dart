import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/blacklist_animal.dart';
import 'package:jlf_mobile/services/blacklist_animal_services.dart';

class BlacklistAnimalPage extends StatefulWidget {
  @override
  _BlacklistAnimalPageState createState() => _BlacklistAnimalPageState();
}

class _BlacklistAnimalPageState extends State<BlacklistAnimalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool failedDataFetching = false;
  List<BlacklistAnimal> blacklistedAnimal = List<BlacklistAnimal>();
  List<Container> blacklistedAnimalCard = List();

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
    getAllBlacklistAnimal("").then((onValue) {
      blacklistedAnimal = onValue;
      _generateBlacklistedUserCard();
    }).catchError((onError) {
      failedDataFetching = true;
      print(onError.toString());
    }).then((_) {
      isLoading = false;

      if (!mounted) return;
      setState(() {});
    });
  }

  _generateBlacklistedUserCard() {
    blacklistedAnimalCard = List();
    for (var i = 0; i < blacklistedAnimal.length; i++) {
      blacklistedAnimalCard.add(Container(
          height: 15,
          child: Card(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Text(blacklistedAnimal[i].title.toUpperCase(),
                          style: TextStyle(color: Colors.black, fontSize: 11),
                          textAlign: TextAlign.left),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Flexible(
                          child: blacklistedAnimal[i].thumbnail != null
                              ? FadeInImage.assetNetwork(
                                  fit: BoxFit.fill,
                                  placeholder: 'assets/images/loading.gif',
                                  image: blacklistedAnimal[i].thumbnail)
                              : Container())
                    ],
                  )))));
    }
  }

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
                : blacklistedAnimal.length > 0
                    ? Container(
                        child: GridView.count(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            children: blacklistedAnimalCard))
                    : Center(
                        child: Text(
                        "Tidak ada blacklist Animal",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      )));
  }

  Widget _buildPageTitle() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Text("Daftar Hewan yang tidak boleh dijual",
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.justify));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            key: _scaffoldKey,
            body: SafeArea(
              child: Column(children: <Widget>[
                _buildPageTitle(),
                _buildGridBlacklistedUser(),
              ]),
            )));
  }
}
