import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/animal_sub_category.dart';
import 'package:jlf_mobile/models/top_seller.dart';
import 'package:jlf_mobile/models/top_seller_point.dart';
import 'package:jlf_mobile/pages/sub_category_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/promo_category_services.dart';
import 'package:jlf_mobile/services/top_seller_services.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoadingTopSellersPoint = true;
  bool isLoadingPromos = true;
  String currentSubCategory = "ALL";
  int currentIdSubCategory;

  int _current = 0;

  int allAuctionCounts = 0;
  int allPlayerCounts = 0;

  String selectedSortBy = "Populer";

  List<Animal> animals = List<Animal>();
  List<TopSeller> topSellers = List<TopSeller>();
  List<TopSellerPoint> topSellersPoint = List<TopSellerPoint>();

  List<Widget> _topSellerPages = List<Widget>();
  List<Widget> _promoCategory = List<Widget>();

  String nextUrl;
  bool isLast = false;

  _CategoryDetailPage(AnimalCategory animalCategory, String from) {
    this.animalCategory = animalCategory;

    globals.getNotificationCount();

    getAllPromosCategory(globals.user.tokenRedis, this.animalCategory.id)
        .then((onValue) {
      if (onValue.length > 0) {
        onValue.forEach((f) {
          _promoCategory.add(
            CachedNetworkImage(
              height: 75,
              imageUrl: f.link ?? "-",
              placeholder: (context, url) => Image.asset(
                'assets/images/loading.gif',
                height: 65,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/error.jpeg',
                height: 65,
              ),
            ),
          );
        });
      }
      setState(() {
        isLoadingPromos = false;
      });
    });

    _getTopSellerPoin();
  }

  @override
  void initState() {
    super.initState();
    refreshTopSellerByCategoryId(animalCategory.id);
  }

  void _getTopSellerPoin() {
    getTopSellerPointCategory(globals.user.tokenRedis, animalCategory.id)
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
        isLoadingTopSellersPoint = false;
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
      }
    });
  }

  //top container
  Widget _buildcontSub(AnimalSubCategory animalSubCategory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SubCategoryDetailPage(
                      animalCategory: animalCategory,
                      animalSubCategoryId: animalSubCategory.id,
                      from: widget.from,
                    )));
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: CachedNetworkImage(
                    height: 75,
                    imageUrl: animalSubCategory.thumbnail ?? "-",
                    placeholder: (context, url) =>
                        Image.asset('assets/images/loading.gif', height: 75),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/error.jpeg',
                      height: 75,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                      width: 75,
                      child: globals.myText(
                          text:
                              "${animalSubCategory.name} ( ${animalSubCategory.animalsCount} )",
                          color: "light-blue",
                          size: 10,
                          align: TextAlign.center),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  Widget _buildCategory() {
    List<Widget> listMyWidgets() {
      List<Widget> list = List();
      List<AnimalSubCategory> animalSubCategories =
          widget.animalCategory.animalSubCategories;
      int countAll = 0;

      for (var i = 0; i < animalSubCategories.length; i++) {
        list.add(_buildcontSub(animalSubCategories[i]));
        countAll += animalSubCategories[i].animalsCount;
      }

      setState(() {
        this.allAuctionCounts = countAll;
      });

      return list.toList();
    }

    return Container(
        height: 150,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: listMyWidgets()));
  }

  Widget _buildTopCont() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: globals.mw(context),
            padding: EdgeInsets.fromLTRB(5, 10, 0, 10),
            color: Color.fromRGBO(242, 242, 242, 1),
            child: globals.myText(
                text: animalCategory.name.toUpperCase(), weight: "B", size: 16),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child:
                globals.myText(text: "Our Categories", size: 16, weight: "M"),
          ),
          isLoadingPromos ? globals.isLoading() : _buildCarouselTop()
        ],
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
                text: "Sponsored Sellers", size: 16, weight: "M"),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
            height: _topSellerPages.length != 0 ? 210 : 50,
            child: _topSellerPages.length != 0
                ? CarouselSlider(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 4),
                    viewportFraction: 1.0,
                    height: 210,
                    enableInfiniteScroll: true,
                    onPageChanged: (index) {
                      setState(() {});
                    },
                    items: _topSellerPages,
                  )
                : globals.myText(text: "Belum Tersedia Sponsored Seller"),
          )
        ],
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
                child: Container(
                    width: 100,
                    child: Container(
                        height: 65,
                        child: CircleAvatar(
                            radius: 75,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: topSeller.user.photo != null ||
                                        topSeller.user.photo != null
                                    ? FadeInImage.assetNetwork(
                                        fit: BoxFit.cover,
                                        placeholder:
                                            'assets/images/loading.gif',
                                        image: topSeller.user.photo != null
                                            ? topSeller.user.photo
                                            : topSeller.user.photo)
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

  Widget _templateHeaderTopSellerProfile(TopSeller topSeller,
      {double height: 45}) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double containerWidth = (deviceWidth - 125) / 4;

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
              margin: EdgeInsets.fromLTRB(10, 0, 10, 1),
              width: containerWidth,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300], width: 1),
                  borderRadius: BorderRadius.circular(5.0)),
              child: Container(
                  alignment: Alignment.center,
                  width: height,
                  child: Container(
                      height: height,
                      child: CircleAvatar(
                          radius: 85,
                          child: topSeller.thumbnail != null ||
                                  topSeller.user.photo != null
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: topSeller.thumbnail != null
                                      ? topSeller.thumbnail
                                      : topSeller.user.photo,
                                  placeholder: (context, url) =>
                                      Image.asset('assets/images/loading.gif'),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/error.jpeg'),
                                )
                              : Image.asset('assets/images/account.png'))))),
          globals.myText(
              text: topSeller.user != null ? topSeller.user.username : ' ',
              size: 10,
              textOverflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  Widget _buildTopSeller() {
    return Card(
      elevation: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 15),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
              alignment: Alignment.centerLeft,
              child: globals.myText(text: "TOP SELLERS", size: 16, weight: "M"),
            ),
            Container(
                height: topSellersPoint.length > 0 ? 100 : 40,
                alignment: Alignment.center,
                child: isLoadingTopSellersPoint
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

  //title add post bid

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildDokterHewan() {
    return GestureDetector(
      onTap: () {
        globals.openInterestLink();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Image.asset('assets/images/bannerdokterhewanhd.jpg'),
      ),
    );
  }

  Widget _buildBottomBanner() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double containerWidth = (deviceWidth - 40) / 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            launch("https://forms.gle/2BB8FTiPy1yAGpz78");
          },
          child: Container(
            width: containerWidth,
            padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Image.asset('assets/images/ceritajlf.jpg',
                width: globals.mw(context) * 0.45),
          ),
        ),
        GestureDetector(
          onTap: () async {
            String url = getBaseUrlAsset() + "/download/sponsored_seller";
            globals.openPdf(context, url, "Sponsored Seller");
          },
          child: Container(
            width: containerWidth,
            padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Image.asset(
              'assets/images/sponsorseller.jpg',
              width: globals.mw(context) * 0.45,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCarouselTop() {
    return _promoCategory.length > 0
        ? Stack(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: CarouselSlider(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 25),
                    viewportFraction: 5.0,
                    height: 218,
                    enableInfiniteScroll: true,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                      });
                    },
                    items: _promoCategory,
                  )),
              Positioned(
                  bottom: 10,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildDoted(_current + 1, _promoCategory.length)
                    ],
                  ))
            ],
          )
        : Container();
  }

  Widget _buildDoted(int index, int total) {
    return Container(
      child:
          globals.myText(text: "$index / $total", color: "light", weight: "XB"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
      body: Scaffold(
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _buildTopCont(),
              _buildCategory(),
              SizedBox(height: 16),
              isLoadingTopSellers
                  ? globals.isLoading()
                  : _buildSponsoredSeller(),
              SizedBox(height: 16),
              _buildDokterHewan(),
              SizedBox(height: 16),
              _buildTopSeller(),
              SizedBox(height: 16),
              _buildBottomBanner(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
