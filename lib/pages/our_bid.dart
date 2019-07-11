import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/models/choice.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';

class OurBidTopPage extends StatefulWidget {
  @override
  _OurBidPageTopState createState() => _OurBidPageTopState();
}

class _OurBidPageTopState extends State<OurBidTopPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
          appBar: globals.appBar(_scaffoldKey, context),
          body: Scaffold(
              key: _scaffoldKey,
              appBar: tabBar(context),
              drawer: drawer(context),
              body: SafeArea(
                child: tabView(),
              ))),
    );
  }
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Tawaran Ku'),
  const Choice(title: 'Komentar Ku'),
];

Widget tabView() {
  List<Choice> tamp = choices;
  return TabBarView(
    children: tamp.map((Choice choice) {
      return Padding(
        padding: const EdgeInsets.all(0.0),
        child: OurBidPage(
          tab: choice.title,
        ),
      );
    }).toList(),
  );
}

Widget tabBar(context) {
  return TabBar(
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      labelColor: Theme.of(context).primaryColor,
      tabs: choices.map((Choice choice) {
        return Tab(
          text: choice.title,
        );
      }).toList());
}

class OurBidPage extends StatefulWidget {
  final String tab;
  const OurBidPage({Key key, this.tab}) : super(key: key);
  @override
  _OurBidPageState createState() => _OurBidPageState(tab);
}

class _OurBidPageState extends State<OurBidPage> {
  TextEditingController searchController = TextEditingController();

  String selectedSortBy = "Terbaru";
  String searchQuery;
  String selectedTab;

  List<Animal> animals = List<Animal>();
  bool isLoading = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
  }

  _OurBidPageState(String tab) {
    selectedTab = tab;
    if (tab == "Tawaran Ku") {
      _getOurBid();
    } else {
      _getOurComment();
    }
  }

  _getOurBid() {
    getUserBidsAnimals("Token", globals.user.id, selectedSortBy)
        .then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  _getOurComment() {
    getUserCommentAnimals("Token", globals.user.id, selectedSortBy)
        .then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  // sort and search
  Widget dropdownSortBy() {
    List<String> item = <String>['Terbaru', 'Selesai', 'Dimenangkan', 'Gagal'];
    return DropdownButton<String>(
        value: selectedSortBy,
        items: item.map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSortBy = value;
            isLoading = true;
            if (selectedTab == "Tawaran Ku") {
              _getOurBid();
            } else {
              _getOurComment();
            }
          });
        });
  }

  Widget _buildTextSearch() {
    return Container(
      width: globals.mw(context) * 0.6,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
        onSubmitted: (String text) {
          //_refresh(currentIdSubCategory, currentSubCategory);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Cari',
            hintStyle: TextStyle(fontSize: 10)),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          dropdownSortBy(),
          _buildTextSearch(),
        ],
      ),
    );
  }
  // sort and search

  //build top name
  // Widget _buildTopCont() {
  //   return Container(
  //     width: globals.mw(context),
  //     padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
  //     color: Colors.white,
  //     child: globals.myText(text: "Lelang Diikuti", size: 16, weight: "SB"),
  //   );
  // }
  //build top name

// build listview
  Widget _buildListView() {
    return animals.length == 0
        ? Center(
            child: Text(
              "Data tidak ditemukan",
              style: Theme.of(context).textTheme.title,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: animals.length,
            itemBuilder: (BuildContext context, int index) {
              String textSearch =
                  "${animals[index].name} ${animals[index].description} ${animals[index].gender}";
              return (searchQuery == null || searchQuery == "")
                  ? _buildCard(animals[index])
                  : (textSearch)
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())
                      ? _buildCard(animals[index])
                      : Container();
            },
          );
  }

  Widget _buildStatus(String status) {
    String currentStatus = "Berjalan";
    Color colorBox = Colors.green;
    if (status != "Aktif") {
      currentStatus = "Selesai";
      colorBox = Colors.black;
    }

    return Row(
      children: <Widget>[
        SizedBox(
          width: 8,
        ),
        Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorBox),
        ),
        SizedBox(
          width: 8,
        ),
        globals.myText(text: currentStatus, color: "unprime"),
      ],
    );
  }

  Widget _buildTimer(String status, String expiryTime) {
    Color colorBox = Color.fromRGBO(255, 77, 77, 1);
    var colorText = "light";
    String text = globals.convertTimer(expiryTime) + " left";

    if (status == "Gagal") {
      colorBox = Colors.red;
      colorText = "light";
      text = "Gagal";
    } else if (status == "Menang" || status == "Terkonfirmasi") {
      colorBox = Colors.green;
      text = "Anda Menang";
    }

    return Container(
      width: 85,
      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: colorBox, borderRadius: BorderRadius.circular(5)),
      child: globals.myText(
          text: text, color: colorText, size: 10, align: TextAlign.center),
    );
  }
  //

  //detail
  Widget _buildImage(String image) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      height: 100,
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: FadeInImage.assetNetwork(
          fit: BoxFit.cover,
          placeholder: 'assets/images/loading.gif',
          image: image,
        ),
      ),
    );
  }
  //detail

  // Widget _buildcontChips(String text) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
  //     margin: EdgeInsets.fromLTRB(5, 2, 0, 2),
  //     decoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor,
  //         borderRadius: BorderRadius.circular(5)),
  //     child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
  //       Text(
  //         text,
  //         style: TextStyle(fontSize: 10),
  //         textAlign: TextAlign.center,
  //       )
  //     ]),
  //   );
  // }

  Widget _buildChips(String text, String value) {
    return Container(
      width: (globals.mw(context) * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              // width: ((globals.mw(context) * 0.5) - 40) * 0.3,
              width: globals.mw(context) * 0.2,
              child: Text(text, style: Theme.of(context).textTheme.display2)),
          // _buildcontChips(value)
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 2, 0, 2),
              margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
              decoration: BoxDecoration(
                  color: text == 'Saat Ini'
                      ? globals.myColor("mimosa")
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusAuction(Animal animal, String status) {
    Widget widget = globals.myText(
        text: "Penawaran terakhir oleh ${animal.auction.lastBid}",
        color: "unprime",
        size: 10);
    if (status == "Gagal") {
      widget = globals.myText(
          text: "Dimenangkan oleh ${animal.auction.lastBid}",
          color: "unprime",
          size: 10);
    } else if (status == "Menang") {
      widget = globals.myText(
          text: 'Dimenangkan oleh Anda', color: "unprime", size: 10);
    } else if (status == "Terkonfirmasi") {
      widget = Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: globals.myColor("primary"))),
        child: globals.myText(
            text: 'PROSES PERMINTAAN PENGIRIMAN', size: 10, weight: "B"),
      );
    }
    return widget;
  }

  Widget _buildCard(Animal animal) {
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
    }

    //String ageNow = globals.convertToAge(animal.dateOfBirth);

    // Bid lastBid;

    int winnerUserId = 0;

    if (animal.auction.winnerBid != null) {
      winnerUserId = animal.auction.winnerBid.userId;
    }

    // if (animal.auction.bids.length > 0) {
    //   lastBid = animal.auction.bids[animal.auction.bids.length - 1];
    // }

    String status = "Aktif";

    if (animal.auction.active == 0) {
      if (winnerUserId == globals.user.id) {
        if (animal.auction.winnerConfirmation != null) {
          status = "Terkonfirmasi";
        } else {
          status = "Menang";
        }
      } else if (winnerUserId != globals.user.id) {
        status = "Gagal";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage(
                      animalId: animal.id,
                    )));
      },
      child: Card(
        child: Column(
          children: <Widget>[
            //build status and timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildStatus(status),
                _buildTimer(status, animal.auction.expiryDate)
              ],
            ),
            //detail
            Row(
              children: <Widget>[
                isNotError
                    ? _buildImage(animal.animalImages[0].image)
                    : globals.failLoadImage(),
                Container(
                  height: 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      globals.myText(
                          text: animal.owner.name, color: "unprime", size: 10),
                      Text(
                        // "${animal.name} ${animal.gender} - $ageNow",
                        "${animal.name}",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .title
                            .copyWith(fontSize: 12),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      _buildChips(
                          "Saat Ini",
                          globals.convertToMoney(
                              animal.auction.currentBid.toDouble())),
                      _buildChips(
                          "Beli Sekarang",
                          globals.convertToMoney(
                              animal.auction.buyItNow.toDouble())),
                      SizedBox(
                        height: 5,
                      ),
                      _buildStatusAuction(animal, status),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // build listview

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: <Widget>[
        _buildSearch(),
        SizedBox(
          height: 8,
        ),
        isLoading ? globals.isLoading() : _buildListView()
      ],
    ));
  }
}
