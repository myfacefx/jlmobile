import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/bid.dart';
import 'package:jlf_mobile/models/choice.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';

class OurProducTopPage extends StatefulWidget {
  @override
  _OurProductTopState createState() => _OurProductTopState();
}

class _OurProductTopState extends State<OurProducTopPage> {
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
  const Choice(title: 'Belanjaanku'),
];

Widget tabView() {
  List<Choice> tamp = choices;
  return TabBarView(
    children: tamp.map((Choice choice) {
      return Padding(
        padding: const EdgeInsets.all(0.0),
        child: OurProductPage(
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

class OurProductPage extends StatefulWidget {
  final String tab;
  const OurProductPage({Key key, this.tab}) : super(key: key);
  @override
  _OurProductPageState createState() => _OurProductPageState(tab);
}

class _OurProductPageState extends State<OurProductPage> {
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

  _OurProductPageState(String tab) {
    selectedTab = tab;
    _getOurProduct();
  }

  _getOurProduct() {
    getUserCommentProductAnimals("Token", globals.user.id, selectedSortBy)
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
    List<String> item = <String>['Terbaru', 'Populer'];
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
            if (selectedSortBy != value) {
              selectedSortBy = value;
              isLoading = true;
              _getOurProduct();
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
      currentStatus = "Tidak Aktif";
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
      width: 120,
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

  Widget _buildChips(String text, String value) {
    return Container(
      width: (globals.mw(context) * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: globals.mw(context) * 0.2,
              child: Text(text, style: Theme.of(context).textTheme.display2)),
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

  Widget _buildCard(Animal animal) {
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
    }

    String status = "Selesai";

    if (animal.product.status == "active") {
      status = "Aktif";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage(
                      animalId: animal.id,
                      from: "LELANG",
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
                          "Harga Jual",
                          globals
                              .convertToMoney(animal.product.price.toDouble())),
                      SizedBox(
                        height: 5,
                      ),
                      globals.myText(
                          text: "Jumlah Tersedia : ${animal.product.quantity}",
                          size: 10),
                      SizedBox(
                        height: 5,
                      ),
                      animal.product.innerIslandShipping == 1
                          ? Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: globals.myColor("primary"))),
                              child: globals.myText(
                                  text: 'Pengiriman Dalam Pulau Saja',
                                  size: 10,
                                  weight: "B"),
                            )
                          : Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: globals.myColor("primary"))),
                              child: globals.myText(
                                  text: 'Nusantara', size: 10, weight: "B"),
                            )
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
