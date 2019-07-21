import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/province_services.dart';

class CategoryDetailPage extends StatefulWidget {
  final AnimalCategory animalCategory;
  final String from;

  CategoryDetailPage(
      {Key key, @required this.animalCategory, @required this.from})
      : super(key: key);

  @override
  _CategoryDetailPage createState() =>
      _CategoryDetailPage(animalCategory, from);
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
  String selectedSortBy = "Populer";
  List<Province> provinces = List<Province>();
  List<String> itemProvince = <String>['All'];

  List<Animal> animals = List<Animal>();

  TextEditingController searchController = TextEditingController();

  _CategoryDetailPage(AnimalCategory animalCategory, String from) {
    // globals.autoClose();
    this.animalCategory = animalCategory;
    var function;
    if (from == "LELANG") {
      function = getAnimalAuctionByCategory("Token", animalCategory.id,
          selectedSortBy, searchController.text, globals.user.id);
    } else if (from == "PASAR HEWAN") {
      function = getAnimalProductByCategory("Token", animalCategory.id,
          selectedSortBy, searchController.text, globals.user.id);
    }

    function.then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
      print(onError.toString());
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

  void _refresh(int subCategoryId, String subCategoryName, String from) {
    setState(() {
      isLoading = true;
    });

    var functionCategory;
    var functionSubCategory;

    if (from == "LELANG") {
      functionCategory = getAnimalAuctionByCategory(
          "Token",
          widget.animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
      functionSubCategory = getAnimalAuctionBySubCategory(
          "Token",
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    if (from == "PASAR HEWAN") {
      functionCategory = getAnimalProductByCategory(
          "Token",
          widget.animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
      functionSubCategory = getAnimalProductBySubCategory(
          "Token",
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    if (subCategoryId != null) {
      currentSubCategory = subCategoryName;
      functionSubCategory.then((onValue) {
        animals = onValue;
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        print(onError.toString());
        globals.showDialogs(onError.toString(), context);
      });
    } else {
      currentSubCategory = "ALL";
      currentIdSubCategory = null;
      functionCategory.then((onValue) {
        animals = onValue;
        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        print(onError.toString());
        globals.showDialogs(onError.toString(), context);
      });
    }
  }

  //top container
  Widget _buildcontSub(String name, String count, int subCategory) {
    return GestureDetector(
      onTap: () {
        if (currentIdSubCategory != subCategory) {
          currentIdSubCategory = subCategory;
          currentSubCategory = name;
          _refresh(subCategory, name, widget.from);
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
        decoration: BoxDecoration(
            color: name.contains(currentSubCategory)
                ? Colors.blueGrey
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
          Container(
            width: globals.mw(context) * 0.5,
            child: Text(
              "${widget.animalCategory.name} - $currentSubCategory",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/auction/create");
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueGrey),
                  ),
                  globals.myText(
                      text: widget.from == "LELANG"
                          ? "Buat Lelang"
                          : "Jual Hewan",
                      color: "primary",
                      weight: "XB"),
                ],
              ))
        ],
      ),
    );
  }

  //title add post bid

  // sort and search
  Widget dropdownSortBy() {
    List<String> item = <String>['Populer', 'Terbaru'];
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
              currentIdSubCategory = currentIdSubCategory;
              currentSubCategory = currentSubCategory;
              _refresh(currentIdSubCategory, currentSubCategory, widget.from);
            }
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
          currentIdSubCategory = currentIdSubCategory;
          currentSubCategory = currentSubCategory;
          _refresh(currentIdSubCategory, currentSubCategory, widget.from);
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
                childAspectRatio: widget.from == "LELANG" ? 0.5 : 0.75,
                crossAxisCount: 2,
                children: listMyWidgets()));
  }

  Widget _buildTime(String expiryTime, String username, String photo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: <Widget>[
          Container(
              height: 15,
              child: CircleAvatar(
                  radius: 10,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: photo != null && photo.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              image: photo,
                              placeholder: 'assets/images/loading.gif',
                              fit: BoxFit.cover)
                          : Image.asset('assets/images/account.png')))),
          Container(
              child: globals.myText(
                  text: "$username",
                  size: 10,
                  textOverflow: TextOverflow.ellipsis))
        ]),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: globals.myColor("primary")),
          padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
          child: globals.myText(
              text: "${globals.convertTimer(expiryTime)}",
              size: 10,
              color: "light"),
        ),
        // Text(
        //   "Sisa ${globals.convertTimer(expiryTime)}",
        //   style: Theme.of(context).textTheme.display1.copyWith(
        //         fontSize: 10,
        //       ),
        //   textAlign: TextAlign.left,
        // ),
      ],
    );
  }

  Widget _buildImage(String image) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
      height: 128,
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

  Widget _buildDetail(
      String name,
      String username,
      String regency,
      String province,
      String gender,
      DateTime birthDate,
      int duration,
      int innerIslandShipping,
      bool isAuction) {
    //String ageNow = globals.convertToAge(birthDate);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            children: <Widget>[
              isAuction
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: globals.myColor("primary")),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      child: globals.myText(
                          text: "1x$duration jam",
                          size: 10,
                          color: "light",
                          letterSpacing: 1.2),
                    )
                  : Container(),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: innerIslandShipping == 1
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: globals.myColor("primary")),
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                        child: globals.myText(
                            text: "Dalam Pulau",
                            size: 10,
                            color: "light",
                            letterSpacing: 1.2),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: globals.myColor("primary")),
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                        child: globals.myText(
                            text: "Nusantara",
                            size: 10,
                            color: "light",
                            letterSpacing: 1.2),
                      ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            // "$name $gender - $ageNow",
            "${name.toUpperCase()}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 12),
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Icon(Icons.location_on, size: 10),
              Flexible(
                child: globals.myText(
                    text: regency + ", " + province,
                    textOverflow: TextOverflow.ellipsis,
                    size: 10,
                    color: "unprime",
                    weight: "L"),
              )
            ],
          ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildChat(String countComments, int animalId) {
    return Positioned(
      bottom: 0,
      right: 10,
      child: InkWell(
        onTap: () {},
        splashColor: Theme.of(context).primaryColor,
        child: Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              globals.myText(text: countComments, color: 'primary', size: 10),
              Container(
                  padding: EdgeInsets.only(left: 2),
                  alignment: Alignment.center,
                  child: Center(
                      child: Image.asset('assets/images/comment.png',
                          height: 10, width: 10))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Animal animal) {
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage(
                      animalId: animal.id,
                      from: widget.from,
                    )));
        _refresh(currentIdSubCategory, currentSubCategory, widget.from);
      },
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Card(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    widget.from == "LELANG"
                        ? _buildTime(animal.auction.expiryDate,
                            animal.owner.username, animal.owner.photo)
                        : Container(),
                    isNotError
                        ? _buildImage(animal.animalImages[0].image)
                        : globals.failLoadImage(),
                    _buildDetail(
                        animal.name,
                        animal.owner.username,
                        animal.owner.regency.name,
                        animal.owner.province.name,
                        animal.gender,
                        animal.dateOfBirth,
                        animal.auction?.duration,
                        widget.from == "LELANG"
                            ? animal.auction.innerIslandShipping
                            : animal.product.innerIslandShipping,
                        widget.from == "LELANG"),
                    widget.from == "LELANG"
                        ? Column(
                            children: <Widget>[
                              _buildChips(
                                  "Harga Awal",
                                  globals.convertToMoney(
                                      animal.auction.openBid.toDouble())),
                              _buildChips(
                                  "Kelipatan",
                                  globals.convertToMoney(
                                      animal.auction.multiply.toDouble())),
                              _buildChips(
                                  "Beli Sekarang",
                                  globals.convertToMoney(
                                      animal.auction.buyItNow.toDouble())),
                              _buildChips(
                                  "Saat Ini",
                                  globals.convertToMoney(
                                      animal.auction.currentBid.toDouble())),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              _buildChips(
                                  "Harga Jual", globals.convertToMoney(10000.0)),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
          widget.from == "LELANG"
              ? _buildChat(animal.auction.countComments.toString(), animal.id)
              : Container(),
        ],
      ),
    );
  }

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
                Container(
                  width: (globals.mw(context) * 0.19),
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
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
      appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
      body: Scaffold(
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
