import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/top_seller.dart';
import 'package:jlf_mobile/models/top_seller_point.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/top_seller_services.dart';

import 'auction/create.dart';

class SubCategoryDetailPage extends StatefulWidget {
  final AnimalCategory animalCategory;
  final int animalSubCategoryId;
  final String from;

  SubCategoryDetailPage(
      {Key key,
      @required this.animalCategory,
      @required this.animalSubCategoryId,
      @required this.from})
      : super(key: key);
  @override
  _SubCategoryDetailPageState createState() =>
      _SubCategoryDetailPageState(animalCategory, animalSubCategoryId, from);
}

class _SubCategoryDetailPageState extends State<SubCategoryDetailPage> {
  AnimalCategory animalCategory;
  int selectedAnimalSubCategoryId;
  String selectedSortBy = "Populer";
  bool isLoading = true;
  bool isLoadingTopSellerPoin = true;
  bool isLoadingLoadMore = false;
  bool isLast = false;
  int _type = 0;
  String nextUrl;
  TextEditingController searchController = TextEditingController();
  List<Animal> animals = List<Animal>();
  List<TopSeller> topSellers = List<TopSeller>();
  List<Widget> _sponsoredSellerPages = List<Widget>();
  List<TopSellerPoint> topSellersPoint = List<TopSellerPoint>();

  bool isLoadingTopSellers = true;

  @override
  void initState() {
    super.initState();
  }

  void _getTopSellerPointSubCategoy() {
    getTopSellerPointSubCategory(
            globals.user.tokenRedis, selectedAnimalSubCategoryId)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      topSellersPoint = onValue;

      setState(() {
        isLoadingTopSellerPoin = false;
      });
    });
  }

  void refreshTopSellerBySubCategoryId(animalSubCategoryId) {
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
        topSellers = onValue;
        _registerTopSellerCarousel(onValue);
        isLoadingTopSellers = false;
      });
    });
  }

  _SubCategoryDetailPageState(
      AnimalCategory animalCategory, int animalSubCategoryId, String from) {
    this.animalCategory = animalCategory;
    selectedAnimalSubCategoryId = animalSubCategoryId;

    if (from == "LELANG") {
      globals.autoClose();
    }

    refreshTopSellerBySubCategoryId(selectedAnimalSubCategoryId);
    _getTopSellerPointSubCategoy();
    globals.getNotificationCount();

    var function;
    if (from == "LELANG") {
      function = getAnimalAuctionBySubCategory(
          globals.user.tokenRedis,
          selectedAnimalSubCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    } else if (from == "PASAR HEWAN" || from == "ACCESSORY") {
      function = getAnimalProductBySubCategory(
          globals.user.tokenRedis,
          selectedAnimalSubCategoryId,
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
      globals.debugPrint(onError.toString());
    });
  }

  _registerTopSellerCarousel(List<TopSeller> topSellers) {
    setState(() {
      _sponsoredSellerPages = List<Widget>();
      if (topSellers.length > 0) {
        List<Widget> firstRowWidget = List<Widget>();
        List<Widget> secondRowWidget = List<Widget>();

        for (var topSeller in topSellers) {
          if (firstRowWidget.length < 4)
            firstRowWidget
                .add(_templateHeaderTopSellerProfile(topSeller, height: 62));
          else if (secondRowWidget.length < 4)
            secondRowWidget
                .add(_templateHeaderTopSellerProfile(topSeller, height: 62));
          else {
            _sponsoredSellerPages.add(Center(
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
          _sponsoredSellerPages.add(Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Row(children: firstRowWidget),
                SizedBox(height: 10),
                Row(children: secondRowWidget)
              ])));
        else if (firstRowWidget.length > 0)
          _sponsoredSellerPages.add(Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Row(children: firstRowWidget)])));
      }
    });
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
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300], width: 1),
                  borderRadius: BorderRadius.circular(5.0)),
              margin: EdgeInsets.symmetric(horizontal: 10),
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

  Widget _templateCategory(AnimalSubCategory animalSubCategory) {
    return GestureDetector(
      onTap: () {
        selectedAnimalSubCategoryId = animalSubCategory.id;
        _refresh(selectedAnimalSubCategoryId);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: selectedAnimalSubCategoryId == animalSubCategory.id
                ? globals.myColor("primary")
                : globals.myColor("unprime")),
        child: globals.myText(
            text: animalSubCategory.name,
            size: 12,
            color: "light",
            align: TextAlign.center),
      ),
    );
  }

  Widget _buildSubCategory() {
    return Container(
        height: 25,
        color: Colors.white,
        alignment: Alignment.center,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _templateCategory(animalCategory.animalSubCategories[index]);
          },
          itemCount: animalCategory.animalSubCategories.length,
        ));
  }

  void _refresh(int subCategoryId) {
    setState(() {
      isLoading = true;
      isLoadingTopSellerPoin = true;
      isLoadingTopSellers = true;
    });

    _getTopSellerPointSubCategoy();
    refreshTopSellerBySubCategoryId(selectedAnimalSubCategoryId);

    nextUrl = null;
    isLast = false;

    var functionSubCategory;

    if (widget.from == "LELANG") {
      functionSubCategory = getAnimalAuctionBySubCategory(
          globals.user.tokenRedis,
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

    if (widget.from == "PASAR HEWAN" || widget.from == "ACCESSORY") {
      functionSubCategory = getAnimalProductBySubCategory(
          globals.user.tokenRedis,
          subCategoryId,
          selectedSortBy,
          searchController.text,
          globals.user.id);
    }

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
      globals.debugPrint(onError.toString());
      globals.showDialogs(onError.toString(), context);
    });
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      color: globals.myColor("light-blue"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTextSearch(),
          dropdownSortBy(),
          ButtonTheme(
            minWidth: 40,
            child: OutlineButton(
              borderSide: BorderSide(color: Colors.white),
              onPressed: () {
                _refresh(selectedAnimalSubCategoryId);
              },
              child: globals.myText(text: "Cari", color: "light", size: 10),
            ),
          ),
        ],
      ),
    );
  }

  // sort and search
  Widget dropdownSortBy() {
    List<String> item = widget.from == "LELANG"
        ? <String>['Populer', 'Terbaru', 'Expiry Date']
        : <String>['Populer', 'Terbaru', 'Termurah'];
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
          value: selectedSortBy,
          iconEnabledColor: Colors.white,
          items: item.map((String value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (selectedSortBy != value) {
                selectedSortBy = value;

                _refresh(selectedAnimalSubCategoryId);
              }
            });
          }),
    );
  }

  Widget _buildTextSearch() {
    return Container(
      width: globals.mw(context) * 0.5,
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
          _refresh(selectedAnimalSubCategoryId);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Nama / Seller / Kota',
            hintStyle: TextStyle(fontSize: 9)),
      ),
    );
  }

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
                  childAspectRatio: widget.from == "LELANG" ? 0.45 : 0.65,
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
                width: globals.mw(context) * 0.28,
                child: globals.myText(
                    text: "$username",
                    size: 12,
                    textOverflow: TextOverflow.ellipsis)),
          ],
        ),
        globals.user.verificationStatus == 'verified'
            ? Container(
                child: Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(Icons.verified_user,
                      size: 18, color: globals.myColor("primary")),
                ),
              )
            : Container(),
      ],
    );
  }

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

  Widget _buildDetailDate(
      String expiryTime, bool isAuction, String createdDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        globals.myText(text: globals.convertFormatDate(createdDate), size: 10),
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
      String createdDate,
      String closingType) {
    //String ageNow = globals.convertToAge(birthDate);

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 18,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: <Widget>[
                isAuction && closingType == "durasi"
                    ? Container(
                      margin: EdgeInsets.only(right: 5),
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
                isAuction ? _buildClosingType(closingType) : Container(),
              ],
            ),
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

  Widget _buildClosingType(String closingType) {
    String cosing = "";
    if (closingType != null) {
      cosing = closingType == "durasi" ? "Bid Terakhir" : "Waktu Ditentukan";
    }

    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: globals.myColor("light-blue")),
      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
      child: globals.myText(
          text: cosing, size: 10, color: "light", letterSpacing: 1.2),
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
                      animal.createdAt.toString(),
                      widget.from == "LELANG"
                          ? animal.auction.closingType
                          : null,
                    ),
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

  Widget _buildTopSeller() {
    return Card(
      elevation: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 15),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
              alignment: Alignment.centerLeft,
              child: globals.myText(text: "TOP SELLERS", weight: "B"),
            ),
            Container(
                color: Colors.white,
                height: topSellersPoint.length > 0 ? 100 : 40,
                alignment: Alignment.center,
                child: isLoadingTopSellerPoin
                    ? globals.isLoading()
                    : topSellersPoint.length > 0
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: false,
                            itemBuilder: (context, index) {
                              return _templateTopSellerProfile(
                                  topSellersPoint[index]);
                            },
                            itemCount: topSellersPoint.length,
                          )
                        : globals.myText(
                            text: "Belum ada top seller pada kategori ini")),
          ],
        ),
      ),
    );
  }

  Widget _templateTopSellerProfile(TopSellerPoint topSeller) {
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
      child: Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300], width: 1),
            borderRadius: BorderRadius.circular(5.0)),
        child: Column(
          children: <Widget>[
            Container(
                color: Colors.white,
                child: Container(
                    width: 100,
                    child: Container(
                        color: Colors.white,
                        height: 65,
                        child: CircleAvatar(
                            radius: 75,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: topSeller.user.photo != null
                                    ? FadeInImage.assetNetwork(
                                        fit: BoxFit.cover,
                                        placeholder:
                                            'assets/images/loading.gif',
                                        image: topSeller.user.photo)
                                    : Image.asset(
                                        'assets/images/account.png')))))),
            SizedBox(
              height: 10,
            ),
            globals.myText(
                text: "${topSeller.point} POIN",
                size: 10,
                align: TextAlign.center,
                color: "unprime",
                textOverflow: TextOverflow.ellipsis)
          ],
        ),
      ),
    );
  }

  Widget _buildSponsoredSeller() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: globals.myText(
                text: "Sponsored Seller", size: 18, weight: "XB"),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
            height: _sponsoredSellerPages.length != 0 ? 210 : 50,
            child: _sponsoredSellerPages.length != 0
                ? CarouselSlider(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 4),
                    viewportFraction: 1.0,
                    height: 210,
                    enableInfiniteScroll: true,
                    onPageChanged: (index) {
                      setState(() {});
                    },
                    items: _sponsoredSellerPages,
                  )
                : globals.myText(text: "Belum Tersedia Sponsored Seller"),
          )
        ],
      ),
    );
  }

  Widget _buildPost() {
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CreateAuctionPage(
                      type: _type,
                      categoryId: widget.animalCategory.id,
                      subCategoryId: selectedAnimalSubCategoryId,
                    )));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.add_circle,
            color: globals.myColor("primary"),
            size: 30,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 20, 0),
            child: globals.myText(
                text: name, size: 16, color: "primary", weight: "B"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(null, context, isSubMenu: true),
      body: Scaffold(
        body: SafeArea(
            child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                color: Colors.white,
                child: _buildSubCategory()),
            SizedBox(
              height: 10,
            ),
            _buildSearch(),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _buildSponsoredSeller(),
                  _buildTopSeller(),
                  _buildPost(),
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
          ],
        )),
      ),
    );
  }
}
