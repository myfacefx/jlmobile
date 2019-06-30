import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/province_services.dart';

class CategoryDetailPage extends StatefulWidget {
  final AnimalCategory animalCategory;

  CategoryDetailPage({Key key, @required this.animalCategory})
      : super(key: key);

  @override
  _CategoryDetailPage createState() => _CategoryDetailPage(animalCategory);
}

class _CategoryDetailPage extends State<CategoryDetailPage> {
  AnimalCategory animalCategory;
  bool isLoading = true;
  bool isLoadingProvince = true;
  String currentSubCategory = "ALL";
  int currentIdSubCategory;

  int allAuctionCounts = 0;
  int allPlayerCounts = 0;

  String selectedProvince = "All";
  String selectedSortBy = "Terbaru";

  List<Province> provinces = List<Province>();
  List<String> itemProvince = <String>['All'];

  List<Animal> animals = List<Animal>();

  TextEditingController searchController = TextEditingController();

  _CategoryDetailPage(AnimalCategory animalCategory) {
    this.animalCategory = animalCategory;

    getAnimalByCategory(
            "Token", animalCategory.id, selectedSortBy, searchController.text)
        .then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
      print(onError);
    });

    getProvinces("token").then((onValue) {
      provinces = onValue;
      provinces.forEach((province) {
        itemProvince.add(province.name);
      });
      setState(() {
        isLoadingProvince = false;
      });
    });
    
    globals.getNotificationCount();
  }

  void _refresh(int subCategoryId, String subCategoryName) {
    setState(() {
      isLoading = true;
    });

    if (subCategoryId != null) {
      currentSubCategory = subCategoryName;
      getAnimalBySubCategory(
              "Token", subCategoryId, selectedSortBy, searchController.text)
          .then((onValue) {
        animals = onValue;
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        globals.showDialogs(onError, context);
      });
    } else {
      currentSubCategory = "ALL";
      currentIdSubCategory = null;
      getAnimalByCategory("Token", widget.animalCategory.id, selectedSortBy,
              searchController.text)
          .then((onValue) {
        animals = onValue;
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        globals.showDialogs(onError, context);
      });
    }
  }

  //top container
  Widget _buildcontSub(String name, String count, int subCategory) {
    return GestureDetector(
      onTap: () {
        _refresh(subCategory, name);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
        decoration: BoxDecoration(
            color: name.contains(currentSubCategory)
                ? Color.fromRGBO(186, 39, 75, 1)
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "$name ($count)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          )
        ]),
      ),
    );
  }

  Widget _buildCategory() {
    List<Widget> listMyWidgets() {
      List<Widget> list = List();
      List<AnimalSubCategory> animalSubCategories =
          widget.animalCategory.animalSubCategories;
      int countAll = 0;

      for (var i = 0; i < animalSubCategories.length; i++) {
        list.add(_buildcontSub(
            animalSubCategories[i].name,
            animalSubCategories[i].animalsCount.toString(),
            animalSubCategories[i].id));
        countAll += animalSubCategories[i].animalsCount;
      }

      setState(() {
        this.allAuctionCounts = countAll;
      });

      list.add(_buildcontSub("ALL", countAll.toString(), null));

      return list.reversed.toList();
    }

    return Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: GridView.count(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 2.3,
            crossAxisCount: 3,
            children: listMyWidgets()));
  }

  Widget _buildTopCont() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: FadeInImage.assetNetwork(
                fit: BoxFit.cover,
                placeholder: 'assets/images/loading.gif',
                image: animalCategory.image,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          allAuctionCounts > 0
              ? Text(
                  "$allAuctionCounts Hewan",
                  style: Theme.of(context)
                      .textTheme
                      .title
                      .copyWith(fontWeight: FontWeight.w300),
                )
              : Container(),
          SizedBox(
            height: 8,
          ),
          allPlayerCounts > 0
              ? Text(
                  "$allPlayerCounts Pemain",
                  style: Theme.of(context).textTheme.subtitle,
                )
              : Container(),
          SizedBox(
            height: 8,
          ),
          _buildCategory(),
        ],
      ),
    );
  }
  //top container

  //title add post bid

  Widget _buildTitle() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "${widget.animalCategory.name} - $currentSubCategory",
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(fontWeight: FontWeight.w500),
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/auction/create");
              },
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    height: 20,
                    child: Image.asset("assets/images/icon_add.png"),
                  ),
                  Text(
                    "Buat Lelang",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  //title add post bid

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
            selectedSortBy = value;
            _refresh(currentIdSubCategory, currentSubCategory);
          });
        });
  }

  Widget dropdownSearchType() {
    return Container(
      child: isLoadingProvince
          ? Center(
              child: CircularProgressIndicator(),
            )
          : DropdownButton<String>(
              value: selectedProvince,
              items: itemProvince.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                });
              }),
    );
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
          _refresh(currentIdSubCategory, currentSubCategory);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
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
          // dropdownSearchType()
        ],
      ),
    );
  }
  // sort and search

  // card animals

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
                childAspectRatio: 0.5,
                crossAxisCount: 2,
                children: listMyWidgets()));
  }

  Widget _buildTime(String expiryTime) {
    List<String> splitText = expiryTime.split(" ");
    String date = splitText[0];

    return Container(
      width: globals.mw(context) * 0.5,
      child: Text(
        "${globals.convertTimer(expiryTime)} Remaining - ${globals.convertFormatDate(date)}",
        style: Theme.of(context).textTheme.display1.copyWith(
              fontSize: 10,
            ),
        textAlign: TextAlign.left,
      ),
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

  Widget _buildDetail(String name, String username, String regency,
      String gender, DateTime birthDate) {
    String ageNow = globals.convertToAge(birthDate);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$name $gender - $ageNow",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 12),
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 3),
              child:
                  globals.myText(text: username, color: "unprime", size: 10)),
          Text(
            regency,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 10),
          ),
          // Container(
          //   width: double.infinity,
          //   child: Row(
          //     children: <Widget>[
          //       Icon(Icons.location_on,
          //           size: 15, color: Theme.of(context).primaryColor),
          //       // globals.myText(text: regency, color: 'black', size: 10),
          //     ],
          //   ),
          // ),
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
            child: Stack(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    child: Center(
                        child: Image.asset('assets/images/comment.png',
                            height: 80, width: 80))),
                Center(
                  child: Text(
                    countComments,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 10),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildCard(Animal animal) {
    bool myProduct = animal.ownerUserId == globals.user.id;
    // print("${animal.ownerUserId} == ${globals.user.id}");
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
    }

    double currentBid = 0.0;
    if (animal.auction != null) {
      currentBid = animal.auction.currentBid.toDouble();
    }
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ProductDetailPage(
                            animalId: animal.id,
                          )));
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    _buildTime(animal.auction.expiryDate),
                    isNotError
                        ? _buildImage(animal.animalImages[0].image)
                        : globals.failLoadImage(),
                    _buildDetail(
                        animal.name,
                        animal.owner.username,
                        animal.owner.regency.name,
                        animal.gender,
                        animal.dateOfBirth),
                    _buildChips(
                        "Harga Awal",
                        globals
                            .convertToMoney(animal.auction.openBid.toDouble())),
                    _buildChips(
                        "Kelipatan",
                        globals.convertToMoney(
                            animal.auction.multiply.toDouble())),
                    _buildChips(
                        "Beli Sekarang",
                        globals.convertToMoney(
                            animal.auction.buyItNow.toDouble())),
                    _buildChips("Saat Ini", globals.convertToMoney(currentBid)),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildChat(animal.auction.countComments.toString(), animal.id),
        myProduct
            ? Positioned(
                bottom: 20,
                left: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: globals.mw(context) * 0.3,
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: globals.myText(
                          align: TextAlign.center,
                          text: "PRODUK ANDA",
                          color: "light",
                          size: 10),
                    )
                  ],
                ))
            : Container(),
      ],
    );
  }

  // Widget _buildcontChips(String text) {
  //   return
  // }

  Widget _buildChips(String text, String value) {
    return Container(
      width: (globals.mw(context) * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(right: 10),
              // width: ((globals.mw(context) * 0.5) - 40) * 0.3,
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
  // card animals

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: drawer(context),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _buildTopCont(),
              SizedBox(
                height: 8,
              ),
              _buildTitle(),
              SizedBox(
                height: 16,
              ),
              _buildSearch(),
              SizedBox(
                height: 16,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildAnimals()
            ],
          ),
        ),
      ),
    );
  }
}
