import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:jlf_mobile/pages/sub_category_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/promo_category_services.dart';
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
  bool isLoadingPromos = true;
  String currentSubCategory = "ALL";
  int currentIdSubCategory;

  int _current = 0;

  int allAuctionCounts = 0;
  int allPlayerCounts = 0;

  String selectedSortBy = "Populer";

  List<Animal> animals = List<Animal>();
  List<TopSeller> topSellers = List<TopSeller>();

  TextEditingController searchController = TextEditingController();

  int _activeTopSellerPage = 0;
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
              imageUrl: f.link,
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
                    imageUrl: animalSubCategory.thumbnail,
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
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: listMyWidgets()));
  }

  Widget _buildTopCont() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 16,
          ),
          globals.myText(
              text: animalCategory.name.toUpperCase(), weight: "B", size: 16),
          SizedBox(
            height: 16,
          ),
          globals.myText(text: "Our Categories", weight: "B"),
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
                text: "Sponsored Seller", size: 18, weight: "XB"),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
            height: _topSellerPages.length != 0 ? 190 : 50,
            child: _topSellerPages.length != 0
                ? CarouselSlider(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                    viewportFraction: 1.0,
                    height: 190,
                    enableInfiniteScroll: true,
                    onPageChanged: (index) {
                      setState(() {
                        _activeTopSellerPage = index;
                      });
                    },
                    items: _topSellerPages,
                  )
                : globals.myText(text: "Belum Tersedia Sponsored Seller"),
          )
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
          SizedBox(
            height: 10,
          ),
          globals.myText(
              text: "100 POIN",
              size: 10,
              align: TextAlign.center,
              color: "unprime",
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
    return Card(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15, bottom: 10, top: 10),
              alignment: Alignment.centerLeft,
              child: globals.myText(text: "TOP SELLERS", weight: "B"),
            ),
            Container(
                height: topSellers.length > 0 ? 100 : 40,
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
        // Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (BuildContext context) =>
        //                 ZoomBannerImagePage(image: listPromoC[_current].link, imageName: listPromoC[_current].name)
        //             )
        //           );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Image.asset('assets/images/bannerdokterhewanhd.jpg'),
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            // Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (BuildContext context) =>
            //             ZoomBannerImagePage(image: listPromoC[_current].link, imageName: listPromoC[_current].name)
            //         )
            //       );
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Image.asset('assets/images/ceritajlf.jpg',
                width: globals.mw(context) * 0.45),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (BuildContext context) =>
            //             ZoomBannerImagePage(image: listPromoC[_current].link, imageName: listPromoC[_current].name)
            //         )
            //       );
          },
          child: Container(
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
                    aspectRatio: 3,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 25),
                    viewportFraction: 3.0,
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
