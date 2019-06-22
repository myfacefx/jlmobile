import 'package:flutter/material.dart';

import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;

  String _username;
  bool isLoading = true;

  List<Animal> animals = List<Animal>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getAnimals();
  }

  _getAnimals() {
    getAnimalByCategory("Token", 1, "", "").then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
  }

  Widget _buildAnimals() {
    List<Widget> listMyWidgets() {
      List<Widget> list = List();

      animals.forEach((animal) {
        list.add(_buildCard(animal));
      });

      return list;
    }

    return animals.length == 0
        ? Center(
            child: Text(
              "Data tidak ditemukan",
              style: Theme.of(context).textTheme.title,
            ),
          )
        : Container(
            child: GridView.count(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                childAspectRatio: 0.53,
                crossAxisCount: 2,
                children: listMyWidgets()));
  }

  Widget _buildTime(String expiryTime) {
    List<String> splitText = expiryTime.split(" ");
    String date = splitText[0];
    String timeRemaining = splitText[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("10 Min Remaining - ${globals.convertFormatDate(date)}",
            style: Theme.of(context).textTheme.display1.copyWith(
                  fontSize: 10,
                )),
      ],
    );
  }

  Widget _buildImage(String image) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 128,
      color: Colors.black,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: FadeInImage.assetNetwork(
          fit: BoxFit.fitHeight,
          placeholder: 'assets/images/loading.gif',
          image: image,
        ),
      ),
    );
  }

  Widget _buildDetail(
      String name, String userPost, String gender, DateTime birthDate) {
    String ageNow = globals.convertToAge(birthDate);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$name $gender - $ageNow",
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 12),
          ),
          Text(userPost, style: Theme.of(context).textTheme.display1),
        ],
      ),
    );
  }

  Widget _buildChat(String countComments, int animalId) {
    return Positioned(
      bottom: 4,
      right: 10,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ProductDetailPage(
                        animalId: animalId,
                      )));
        },
        splashColor: Theme.of(context).primaryColor,
        child: Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
            margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                  ),
                ]),
            child: Center(
              child: Text(
                countComments,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 10),
              ),
            )),
      ),
    );
  }

  Widget _buildCard(Animal animal) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Card(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _buildTime(animal.auction.expiryDate),
                  _buildImage(animal.animalImages[0].image),
                  _buildDetail(animal.name, animal.owner.username,
                      animal.gender, animal.dateOfBirth),
                  _buildChips(
                      "start",
                      globals
                          .convertToMoney(animal.auction.openBid.toDouble())),
                  _buildChips(
                      "multiplier",
                      globals
                          .convertToMoney(animal.auction.multiply.toDouble())),
                  _buildChips(
                      "bin",
                      globals
                          .convertToMoney(animal.auction.buyItNow.toDouble())),
                  _buildChips(
                      "current",
                      globals
                          .convertToMoney(animal.auction.sumBids.toDouble())),
                ],
              ),
            ),
          ),
        ),
        _buildChat(animal.auction.countComments.toString(), animal.id)
      ],
    );
  }

  Widget _buildcontChips(String text) {
    return Container(
      width: ((globals.mw(context) * 0.5) - 40) * 0.46,
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          text,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  Widget _buildChips(String text, String value) {
    return Container(
      width: (globals.mw(context) * 0.5) - 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: ((globals.mw(context) * 0.5) - 40) * 0.3,
              child: Text(text, style: Theme.of(context).textTheme.display2)),
          _buildcontChips(value)
        ],
      ),
    );
  }
  // card animals

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
                                    child: Icon(Icons.edit)),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 5),
                                      height: 100,
                                      child: CircleAvatar(
                                          radius: 100,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: FadeInImage.assetNetwork(
                                                  image:
                                                      'https://66.media.tumblr.com/d3a12893ef0dfec39cf7335008f16c7f/tumblr_pcve4yqyEO1uaogmwo8_400.png',
                                                  placeholder:
                                                      'assets/images/loading.gif',
                                                  fit: BoxFit.cover)))),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.star, size: 15),
                                      Text("4.5",
                                          style: TextStyle(color: Colors.grey))
                                    ],
                                  ),
                                  Text(globals.user.username,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.location_on,
                                          size: 18,
                                          color:
                                              Theme.of(context).primaryColor),
                                      Text("Kota Tangerang Selatan",
                                          style: TextStyle(color: Colors.grey))
                                    ],
                                  ),
                                  Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: Text(
                                          "First hand importir anjing, silahkan lihat-lihat",
                                          style: TextStyle(color: Colors.grey))),
                                  FlatButton(
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/auction/create");
                                    },
                                    child: Icon("Add Auction",
                                        color: Colors.black, size: 20)),
                                ],
                              ),
                            ],
                          ))),
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
                          child: Text("Produk-ku",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11)),
                        ),
                        Tab(
                          child: Text("Produk Lelang",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11)),
                        ),
                        // Tab(
                        //   child: Text("Produk Jual",
                        //       style:
                        //           TextStyle(color: Colors.black, fontSize: 9)),
                        // ),
                        // Tab(
                        //   child: Text("Tambahkan",
                        //       style:
                        //           TextStyle(color: Colors.black, fontSize: 9)),
                        // )
                      ],
                    )))),
                Flexible(
                    child: Container(
                  padding: EdgeInsets.all(5),
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        Container(
                            child: isLoading
                                ? globals.isLoading()
                                : _buildAnimals()),
                        Container(
                            child: isLoading
                                ? globals.isLoading()
                                : _buildAnimals()),
                        // Container(
                        //     child: isLoading
                        //         ? globals.isLoading()
                        //         : _buildAnimals()),
                        // Container(
                        //     child: isLoading
                        //         ? globals.isLoading()
                        //         : _buildAnimals()),
                      ],
                    ),
                ))
              ],
            ))));
  }
}
