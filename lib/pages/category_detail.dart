import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/top_seller.dart';
import 'package:jlf_mobile/pages/auction/create.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/province_services.dart';
import 'package:jlf_mobile/services/top_seller_services.dart';

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
  bool isLoadingLoadMore = false;
  bool isLoadingProvince = true;
  bool isLoadingTopSellers = true;
  String currentSubCategory = "ALL";
  int currentIdSubCategory;

  int allAuctionCounts = 0;
  int allPlayerCounts = 0;

  String selectedProvince = "All";
  String selectedSortBy = "Populer";
  List<Province> provinces = List<Province>();
  List<String> itemProvince = <String>['All'];

  List<Animal> animals = List<Animal>();
  List<TopSeller> topSellers = List<TopSeller>();

  TextEditingController searchController = TextEditingController();

  int _activeTopSellerPage = 0;
  List<Widget> _topSellerPages = List<Widget>();

  String nextUrl;
  bool isLast = false;

  _CategoryDetailPage(AnimalCategory animalCategory, String from) {
    if (from == "LELANG") {
      globals.autoClose();
    }

    this.animalCategory = animalCategory;
    var function;
    if (from == "LELANG") {
      function = getAnimalAuctionByCategory(
          globals.user.tokenRedis,
          animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    } else if (from == "PASAR HEWAN" || from == "ACCESSORY") {
      function = getAnimalProductByCategory(
          globals.user.tokenRedis,
          animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    function.then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      animals.addAll(onValue.data);
      this.nextUrl = onValue.nextPageUrl;
      if (onValue.currentPage == onValue.lastPage) {
        isLast = true;
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
      print(onError.toString());
    });

    getProvinces().then((onValue) {
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

  @override
  void initState() {
    super.initState();
    refreshTopSellerByCategoryId(animalCategory.id);
  }

  void refreshTopSellerBySubCategoryId(animalSubCategoryId) {
    setState(() {
      isLoadingTopSellers = true;
    });
    getTopSellersBySubCategoryId(globals.user.tokenRedis, animalSubCategoryId)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      setState(() {
        _registerTopSellerCarousel(onValue);
        topSellers = onValue;
        isLoadingTopSellers = false;
      });
    });
  }

  void refreshTopSellerByCategoryId(animalCategoryId) {
    setState(() {
      isLoadingTopSellers = true;
    });
    getTopSellersByCategoryId(globals.user.tokenRedis, animalCategoryId)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      setState(() {
        topSellers = onValue;
        _registerTopSellerCarousel(onValue);
        isLoadingTopSellers = false;
      });
    });
  }

  _registerTopSellerCarousel(List<TopSeller> topSellers) {
    setState(() {
      _topSellerPages = List<Widget>();
      if (topSellers.length > 0) {
        // yxy

        List<Widget> firstRowWidget = List<Widget>();
        List<Widget> secondRowWidget = List<Widget>();

        for (var topSeller in topSellers) {
          if (firstRowWidget.length < 3)
            firstRowWidget
                .add(_templateHeaderTopSellerProfile(topSeller, height: 62));
          else if (secondRowWidget.length < 3)
            secondRowWidget
                .add(_templateHeaderTopSellerProfile(topSeller, height: 62));
          else {
            _topSellerPages.add(Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Row(children: firstRowWidget),
                  SizedBox(height: 10),
                  Row(children: secondRowWidget)
                ])));
            firstRowWidget = List<Widget>();
            secondRowWidget = List<Widget>();
          }
        }

        if (secondRowWidget.length > 0)
          _topSellerPages.add(Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Row(children: firstRowWidget),
                SizedBox(height: 10),
                Row(children: secondRowWidget)
              ])));
        else if (firstRowWidget.length > 0)
          _topSellerPages.add(Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Row(children: firstRowWidget)])));

        // 1x4
        // int i = 0;

        // List<Widget> rowWidget = List<Widget>();

        // for (var topSeller in topSellers) {
        //   rowWidget.add(_templateHeaderTopSellerProfile(topSeller));

        //   i++;
        //   if (i == 4) {
        //     _topSellerPages.add(Row(children: rowWidget));
        //     rowWidget = List<Widget>();
        //   }
        // }

        // if (rowWidget.length > 0) _topSellerPages.add(Row(children: rowWidget));
      }
    });
  }

  Future<bool> _loadmore() async {
    if (nextUrl == null) {
      return false;
    }

    setState(() {
      isLoadingLoadMore = true;
    });
    final onValue = await getLoadMore(globals.user.tokenRedis, nextUrl);
    if (onValue == null) {
      await globals.showDialogs(
          "Session anda telah berakhir, Silakan melakukan login ulang", context,
          isLogout: true);
    }
    animals.addAll(onValue.data);

    if (onValue.currentPage == onValue.lastPage) {
      isLast = true;
    }

    this.nextUrl = onValue.nextPageUrl;

    setState(() {
      isLoadingLoadMore = false;
    });
    return true;
  }

  void _refresh(int subCategoryId, String subCategoryName, String from) {
    setState(() {
      isLoading = true;
    });

    nextUrl = null;
    isLast = false;
    var functionCategory;
    var functionSubCategory;

    if (from == "LELANG") {
      functionCategory = getAnimalAuctionByCategory(
          globals.user.tokenRedis,
          widget.animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
      functionSubCategory = getAnimalAuctionBySubCategory(
          globals.user.tokenRedis,
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    if (from == "PASAR HEWAN" || from == "ACCESSORY") {
      functionCategory = getAnimalProductByCategory(
          globals.user.tokenRedis,
          widget.animalCategory.id,
          selectedSortBy,
          searchController.text,
          globals.user.id);
      functionSubCategory = getAnimalProductBySubCategory(
          globals.user.tokenRedis,
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    if (subCategoryId != null) {
      currentSubCategory = subCategoryName;
      functionSubCategory.then((onValue) async {
        if (onValue == null) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
        animals = (onValue.data);

        this.nextUrl = onValue.nextPageUrl;

        if (onValue.currentPage == onValue.lastPage) {
          isLast = true;
        }

        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        print(onError.toString());
        globals.showDialogs(onError.toString(), context);
      });

      refreshTopSellerBySubCategoryId(subCategoryId);
    } else {
      currentSubCategory = "ALL";
      currentIdSubCategory = null;
      functionCategory.then((onValue) async {
        if (onValue == null) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
        animals = (onValue.data);
        this.nextUrl = onValue.nextPageUrl;

        if (onValue.currentPage == onValue.lastPage) {
          isLast = true;
        }

        setState(() {
          isLoading = false;
        });
      }).catchError((onError) {
        print(onError.toString());
        if (!mounted) return;
        globals.showDialogs(onError.toString(), context);
      });

      refreshTopSellerByCategoryId(animalCategory.id);
    }

    // refreshTopSellers();
  }

  //top container
  Widget _buildcontSub(String name, String count, int subCategory) {
    return Container(
        // padding: EdgeInsets.fromLTRB(, 5, 10, 5),
        margin: EdgeInsets.fromLTRB(5, 5, 0, 5),
        child: ButtonTheme(
            height: 25,
            child: FlatButton(
                onPressed: () {
                  if (currentIdSubCategory != subCategory) {
                    currentIdSubCategory = subCategory;
                    currentSubCategory = name;
                    _refresh(subCategory, name, widget.from);
                  }
                },
                color: name.contains(currentSubCategory)
                    ? Colors.blueGrey
                    : globals.myColor("primary"),
                child: globals.myText(
                    text: "${name.toUpperCase()} ($count)",
                    align: TextAlign.center,
                    size: 10,
                    color: "light"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))))
        // padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        // margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
        // decoration: BoxDecoration(
        //     color: name.contains(currentSubCategory)
        //         ? Colors.blueGrey
        //         : Theme.of(context).primaryColor,
        //     borderRadius: BorderRadius.circular(25)),
        // child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //   Text(
        //     "$name ($count)",
        //     textAlign: TextAlign.center,
        //     style: TextStyle(fontSize: 10),
        //   )
        // ]),
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
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: GridView.count(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 2.3,
            crossAxisCount: 3,
            children: listMyWidgets()));
  }

  Widget _buildTopCont() {
    int _type = 0;
    String name = "Buat Lelang";
    if (widget.from == "LELANG") {
      _type = 1;
      name = "Buat\nLelang";
    } else if (widget.from == "PASAR HEWAN") {
      _type = 2;
      name = "Jual\nHewan";
    } else if (widget.from == "ACCESSORY") {
      _type = 3;
      name = "Jual\nProduk";
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                  height: 90,
                  width: 90,
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
                globals.myText(
                    text: animalCategory.name.toUpperCase(),
                    size: 14,
                    weight: "B",
                    align: TextAlign.center),
                // ButtonTheme(
                //   // minWidth: double.infinity,
                //   height: 25,
                //   child: RaisedButton(
                //       color: Color.fromRGBO(222, 188, 123, 1),
                //       onPressed: () {},
                //       child: Row(
                //         children: <Widget>[
                //           Icon(Icons.bookmark, color: globals.myColor("dark"), size: 17),
                //           globals.myText(text: " Artikel ", color: "dark"),
                //         ],
                //       )),
                // ),
                ButtonTheme(
                  // minWidth: double.infinity,
                  height: 38,
                  child: RaisedButton(
                      color: Color.fromRGBO(227, 136, 133, 1),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CreateAuctionPage(
                                        type: _type,
                                        categoryId: widget.animalCategory.id,
                                        subCategoryId: currentIdSubCategory)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(Icons.add_circle, size: 17),
                          ),
                          globals.myText(
                              text: " $name", align: TextAlign.center),
                        ],
                      )),
                ),
              ],
            ),
            Flexible(child: _buildCarousel())
          ]),
          // SizedBox(
          //   height: 8,
          // ),
          // allAuctionCounts > 0
          //     ? Text(
          //         "$allAuctionCounts Hewan",
          //         style: Theme.of(context)
          //             .textTheme
          //             .title
          //             .copyWith(fontWeight: FontWeight.w300),
          //       )
          //     : Container(),
          // SizedBox(
          //   height: 8,
          // ),
          // allPlayerCounts > 0
          //     ? Text(
          //         "$allPlayerCounts Pemain",
          //         style: Theme.of(context).textTheme.subtitle,
          //       )
          //     : Container(),
          // SizedBox(
          //   height: 8,
          // ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return _topSellerPages.length > 0
        ? Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                height: 190,
                child: CarouselSlider(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  viewportFraction: 1.0,
                  height: 190,
                  enableInfiniteScroll: true,
                  onPageChanged: (index) {
                    setState(() {
                      _activeTopSellerPage = index;
                    });
                  },
                  items: _topSellerPages,
                ),
              ),
            ],
          )
        : Container();
  }

  Widget _buildHeaderTopSeller() {
    // return
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: topSellers.length > 0
          ? Card(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: isLoadingTopSellers
                            ? globals.isLoading()
                            : topSellers.length > 0
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: false,
                                    itemBuilder: (context, index) {
                                      return _templateHeaderTopSellerProfile(
                                          topSellers[index]);
                                    },
                                    itemCount: topSellers.length,
                                  )
                                : globals.myText(
                                    text:
                                        "Belum ada star seller pada kategori ini")),
                  ],
                ),
              ),
            )
          : Center(
              child: globals.myText(
                  text: "Belum ada star seller di kategori ini",
                  align: TextAlign.center)),
    );
  }

  //title add post bid
  Widget _buildTitle() {
    int _type = 0;
    String name = "Buat Lelang";
    if (widget.from == "LELANG") {
      _type = 1;
      name = "Buat Lelang";
    } else if (widget.from == "PASAR HEWAN") {
      _type = 2;
      name = "Jual Hewan";
    } else if (widget.from == "ACCESSORY") {
      _type = 3;
      name = "Jual Aksesoris";
    }
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CreateAuctionPage(
                              type: _type,
                              categoryId: widget.animalCategory.id,
                              subCategoryId: currentIdSubCategory,
                            )));
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
                  globals.myText(text: name, color: "primary", weight: "XB"),
                ],
              ))
        ],
      ),
    );
  }

  Widget _templateTopSellerProfile(TopSeller topSeller) {
    return GestureDetector(
      onTap: () {
        topSeller.userId != null
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProfilePage(userId: topSeller.userId)))
            : null;
      },
      child: Column(
        children: <Widget>[
          Container(
              child: Container(
                  width: 80,
                  child: Container(
                      height: 65,
                      child: CircleAvatar(
                          radius: 75,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: topSeller.thumbnail != null ||
                                      topSeller.user.photo != null
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      placeholder: 'assets/images/loading.gif',
                                      image: topSeller.thumbnail != null
                                          ? topSeller.thumbnail
                                          : topSeller.user.photo)
                                  : Image.asset(
                                      'assets/images/account.png')))))),
          globals.myText(
              text: topSeller.user != null ? topSeller.user.username : ' ',
              weight: "B",
              textOverflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  Widget _templateHeaderTopSellerProfile(TopSeller topSeller,
      {double height: 42}) {
    return GestureDetector(
      onTap: () {
        topSeller.userId != null
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProfilePage(userId: topSeller.userId)))
            : null;
      },
      child: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                  alignment: Alignment.center,
                  width: height,
                  child: Container(
                      height: height,
                      child: CircleAvatar(
                          radius: 85,
                          child: topSeller.thumbnail != null ||
                                  topSeller.user.photo != null
                              ? FadeInImage.assetNetwork(
                                  fit: BoxFit.cover,
                                  placeholder: 'assets/images/loading.gif',
                                  image: topSeller.thumbnail != null
                                      ? topSeller.thumbnail
                                      : topSeller.user.photo)
                              : Image.asset('assets/images/account.png'))))),
          globals.myText(
              text: topSeller.user != null ? topSeller.user.username : ' ',
              weight: "B",
              textOverflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  Widget _buildTopSeller() {
    return topSellers.length > 0
        ? Card(
            child: Container(
              color: Colors.white,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 15, bottom: 5, top: 5),
                    alignment: Alignment.centerLeft,
                    child: globals.myText(text: "STAR SELLERS", weight: "B"),
                  ),
                  Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: isLoadingTopSellers
                          ? globals.isLoading()
                          : topSellers.length > 0
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: false,
                                  itemBuilder: (context, index) {
                                    return _templateTopSellerProfile(
                                        topSellers[index]);
                                  },
                                  itemCount: topSellers.length,
                                )
                              : globals.myText(
                                  text:
                                      "Belum ada top seller pada kategori ini")),
                ],
              ),
            ),
          )
        : Container();
  }

  //title add post bid

  // sort and search
  Widget dropdownSortBy() {
    List<String> item = widget.from == "LELANG"
        ? <String>['Populer', 'Terbaru', 'Expiry Date']
        : <String>['Populer', 'Terbaru', 'Termurah'];
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
            hintText: 'Cari Lokasi / Nama Seller / Nama Hewan',
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
    return animals.length == 0
        ? Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Center(
              child: Text(
                "Belum ada data",
                style: Theme.of(context).textTheme.title,
              ),
            ),
          )
        : Container(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: animals.length,
              physics: ScrollPhysics(),
              semanticChildCount: 2,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: widget.from == "LELANG" ? 0.5 : 0.65,
                  crossAxisCount: 2),
              itemBuilder: (BuildContext context, int index) {
                return _buildCard(animals[index]);
              },
            ),
          );
  }

  Widget _buildTime(String username, String photo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                height: 25,
                width: 30,
                padding: EdgeInsets.only(right: 5),
                child: CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: photo != null && photo.isNotEmpty
                            ? FadeInImage.assetNetwork(
                                image: photo,
                                placeholder: 'assets/images/loading.gif',
                                fit: BoxFit.cover)
                            : Image.asset('assets/images/account.png')))),
            Container(
                width: globals.mw(context) * 0.3,
                child: globals.myText(
                    text: "$username",
                    size: 12,
                    textOverflow: TextOverflow.ellipsis)),
          ],
        ),
        globals.user.verificationStatus == 'verified'
            ? Icon(Icons.verified_user,
                size: 18, color: globals.myColor("primary"))
            : Container(),
      ],
    );
  }

  Widget _buildDetailDate(
      String expiryTime, bool isAuction, String createdDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        globals.myText(
            text:
                globals.convertFormatDate(createdDate),
            size: 10),
        isAuction
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: getColorExpirationTime(
                        globals.convertDateToHour(expiryTime))),
                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: globals.myText(
                    text: "tersisa ${globals.convertTimer(expiryTime)}",
                    size: 10,
                    color: "light"),
              )
            : Container(),
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
          fit: BoxFit.fitWidth,
          placeholder: 'assets/images/loading.gif',
          image: image,
          width: 200,
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
      bool isAuction,
      String createdDate) {
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
        animal.animalImages[0].thumbnail != null) {
      isNotError = true;
    }

    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage(
                      animalId: animal.id,
                      from: widget.from,
                    )));
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
                    _buildTime(animal.owner.username, animal.owner.photo),
                    Divider(color: Color.fromRGBO(210, 208, 208, 1)),
                    _buildDetailDate(
                        widget.from == "LELANG"
                            ? animal.auction.expiryDate
                            : null,
                        widget.from == "LELANG",
                        animal.createdAt.toString()),
                    isNotError
                        ? _buildImage(animal.animalImages[0].thumbnail)
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
                        widget.from == "LELANG",
                        animal.createdAt.toString()),
                    widget.from == "LELANG"
                        ? Column(
                            children: <Widget>[
                              SizedBox(height: 10),
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
                                  "Harga Jual",
                                  globals.convertToMoney(
                                      animal.product.price.toDouble())),
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

  /*
   * Get Color by Expiration Time
   *
   * @param int $expirationTime
   * @return Color
   */
  Color getColorExpirationTime($expirationTime) {
    Color color;

    if ($expirationTime <= 2) {
      color = Colors.red;
    } else if ($expirationTime > 2 && $expirationTime < 5) {
      color = Colors.yellow;
    } else {
      color = Colors.green;
    }

    return color;
  }

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
                height: 16,
              ),
              _buildCategory(),
              SizedBox(height: 16),
              // _buildTitle(),
              // SizedBox(
              //   height: 16,
              // ),
              // _buildTopSeller(),
              // SizedBox(
              //   height: 16,
              // ),
              _buildSearch(),
              SizedBox(
                height: 16,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildAnimals(),
              isLoadingLoadMore
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : isLoading
                      ? Container()
                      : isLast
                          ? Container()
                          : Center(
                              child: FloatingActionButton.extended(
                                label: globals.myText(
                                    text: "MUAT LAINNYA", color: "light"),
                                backgroundColor: globals.myColor("primary"),
                                onPressed: () {
                                  _loadmore();
                                },
                              ),
                            ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
