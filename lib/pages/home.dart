import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jlf_mobile/pages/category_detail.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/promo_services.dart';
import 'package:jlf_mobile/services/slider_service.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _current = 0;

  bool isLoadingCategories = true;
  bool isLoadingSlider = true;
  bool isLoadingPromo = true;
  bool failedDataCategories = false;
  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  int membersCount = 0;
  List<Widget> listImage = [];
  List<Widget> listPromo = [];

  int _currentArticle = 0;

  List<Widget> _articlesImages = [
    FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            "https://cdn0-production-images-kly.akamaized.net/mlWguH_D--qaFOedNOreIKdpV8s=/640x360/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/1071039/original/041915500_1448872446-14824-Baby-Hermanns-Tortoise-white-background.jpg"),
    FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            "https://cdn2.tstatic.net/tribunnews/foto/bank/images/kura-kura-jonathan_20160324_053115.jpg"),
    FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            "https://cdn2.tstatic.net/tribunnews/foto/bank/images/kura-kura-saint-mary_20180412_122627.jpg")
  ];
  List<String> _articlesLinks = [
    "https://www.liputan6.com/health/read/3082433/punya-kura-kura-di-rumah-ini-bahaya-yang-bisa-mengintai-anak?utm_expid=.9Z4i5ypGQeGiS7w9arwTvQ.0&utm_referrer=https%3A%2F%2Fwww.google.com%2F",
    "https://www.tribunnews.com/travel/2016/03/24/bertahan-hidup-184-tahun-kura-kura-jonathan-ini-akhirnya-untuk-pertama-kali-mandi",
    "https://www.tribunnews.com/sains/2018/04/12/kura-kura-berambut-hijau-yang-bernapas-melalui-alat-kelaminnya-terancam-punah"
  ];
  List<String> _articlesTitle = [
    "Punya Kura-Kura di Rumah? Ini Bahaya yang Bisa Mengintai Anak",
    "Bertahan Hidup 184 Tahun, Kura-kura Jonathan Ini Akhirnya Untuk Pertama Kali Mandi",
    "Kura-kura Berambut Hijau yang Bernapas Melalui Alat Kelaminnya Terancam Punah"
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
    _getListCategories();
    _loadSliders();
    _loadPromos();
    globals.getNotificationCount();
    globals.generateToken();
    globals.notificationListener(context);
  }

  _loadSliders() {
    getAllSliders("token").then((onValue) {
      if (onValue.length != 0) {
        listImage = [];
        onValue.forEach((slider) {
          listImage.add(
            FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif', image: slider.link),
          );
        });
      } else {
        listImage = getTemplateSlider();
      }

      setState(() {
        isLoadingSlider = false;
      });
    }).catchError((onError) {
      listImage = getTemplateSlider();
      setState(() {
        isLoadingSlider = false;
      });
    });
  }

  _loadPromos() {
    getAllPromos("").then((onValue) {
      if (onValue.length != 0) {
        listPromo = [];
        onValue.forEach((promo) {
          listPromo.add(FadeInImage.assetNetwork(
            placeholder: 'assets/images/loading.gif',
            image: promo.link,
            // fit: BoxFit.cover,
          ));
        });
      } else {
        listPromo = getTemplatePromo();
      }

      setState(() {
        isLoadingPromo = false;
      });
    }).catchError((onError) {
      listPromo = getTemplatePromo();
      setState(() {
        isLoadingPromo = false;
      });
    });
  }

  _refresh() {
    getUsersCount().then((onValue) {
      membersCount = onValue;
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
  }

  List<Widget> getTemplatePromo() {
    return [
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image: 'https://placeimg.com/520/200/animals?4',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image: 'https://placeimg.com/520/200/animals?4',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image: 'https://placeimg.com/520/200/animals?4',
      ),
    ];
  }

  List<Widget> getTemplateSlider() {
    return [
      FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading.gif',
          image: 'https://placeimg.com/520/200/animals?4'),
      FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading.gif',
          image: 'https://placeimg.com/420/200/animals?1'),
      FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading.gif',
          image: 'https://placeimg.com/420/200/animals?2'),
      FadeInImage.assetNetwork(
          placeholder: 'assets/images/loading.gif',
          image: 'https://placeimg.com/420/200/animals?3')
    ];
  }

  _HomePage() {
    getAnimalCategory("token").then((onValue) {
      animalCategories = onValue;
      setState(() {
        isLoadingCategories = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
  }

  void _getListCategories() {
    setState(() {
      failedDataCategories = false;
      isLoadingCategories = true;
    });

    getNotUserAnimalCategory("token", globals.user.id).then((onValue) {
      animalCategories = onValue;
      setState(() {
        isLoadingCategories = false;
      });
    }).catchError((onError) {
      failedDataCategories = true;
    }).then((_) {
      isLoadingCategories = false;

      if (!mounted) return;
      setState(() {});
    });
  }

  Widget _buildDoted(int index, int total) {
    return Container(
      child:
          globals.myText(text: "$index / $total", color: "light", weight: "XB"),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: CarouselSlider(
            aspectRatio: 3,
            autoPlay: true,
            // enlargeCenterPage: true,
            viewportFraction: 3.0,
            height: 200,
            enableInfiniteScroll: true,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: listImage,
          ),
        ),
        Positioned(
            bottom: 10,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildDoted(_current + 1, listImage.length + 1)
              ],
            ))
      ],
    );
  }

  Widget _buildAsk() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 64,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        globals.myText(
            text: "BACA PANDUAN DAN TIPS TRIK LENGKAP JLF DI SINI",
            color: "light",
            size: 16,
            align: TextAlign.center),
      ]),
    );
  }

  Widget _buildNumberMember() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 35,
      decoration: BoxDecoration(
          color: Color.fromRGBO(73, 187, 255, 1),
          borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        globals.myText(
            text: "$membersCount orang telah bergabung bersama JLF saat ini",
            color: "light",
            size: 12,
            weight: "N",
            align: TextAlign.center),
      ]),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: Row(
        children: <Widget>[
          Text(
            "LELANG",
            style: Theme.of(context).textTheme.headline,
          ),
          Text("  |  ", style: Theme.of(context).textTheme.headline),
          Text(
            "PASAR HEWAN",
            style: Theme.of(context)
                .textTheme
                .headline
                .copyWith(color: Color.fromRGBO(178, 178, 178, 1)),
          ),
          Expanded(child: Text("")),
          // membersCount > 0
          //     ? globals.myText(text: "$membersCount MEMBER", color: 'dark')
          //     : Container()
        ],
      ),
    );
  }

  Widget detail(String name, String count) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: Theme.of(context).textTheme.subtitle,
          ),
          Text("$count Items",
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget image(String url) {
    return Container(
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
          image: url,
        ),
      ),
    );
  }

  Widget cardAnimal(AnimalCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CategoryDetailPage(
                      animalCategory: category,
                    )));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              image(category.image),
              SizedBox(
                width: 10,
              ),
              detail(category.name, category.animalsCount.toString())
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotion() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 16),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: globals.mw(context),
              child: listPromo[0],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  height: 125,
                  width: globals.mw(context) * 0.47,
                  child: listPromo[1],
                ),
                Container(
                    color: Colors.white,
                    height: 125,
                    width: globals.mw(context) * 0.47,
                    child: listPromo[2]),
              ],
            )
          ],
        ));
  }

  Widget _buildGridCategory(List<AnimalCategory> animals) {
    List<Widget> listMyWidgets() {
      List<Widget> list = List();
      if (!isLoadingCategories) {
        for (var i = 0; i < animals.length; i++) {
          list.add(cardAnimal(animals[i]));
        }
      }

      return list;
    }

    return failedDataCategories
        ? globals.buildFailedLoadingData(context, _getListCategories)
        : isLoadingCategories
            ? Container(child: Center(child: CircularProgressIndicator()))
            : Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: GridView.count(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    childAspectRatio: 2,
                    crossAxisCount: 2,
                    children: listMyWidgets()));
  }

  _exitDialog() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Widget _buildDonation() {
    return Container(
        margin: EdgeInsets.all(5),
        child: Card(
            color: globals.myColor('primary'),
            child: Container(
                padding: EdgeInsets.all(12),
                child: Row(children: <Widget>[
                  Image.asset('assets/images/donation.png', height: 55),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            globals.myText(
                                text: "DONASI ANDA SANGAT BERARTI BAGI KAMI",
                                color: "light",
                                weight: "B"),
                            SizedBox(height: 5),
                            globals.myText(
                                text:
                                    "JLF terus tumbuh dan berusahan menjadi tempat yang nyaman bagi pemain fauna, dengan donasi Anda akan sangat membantu kami bertumbuh lebih cepat",
                                color: "light",
                                size: 12),
                            SizedBox(height: 5),
                            OutlineButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () => null,
                              color: Colors.transparent,
                              highlightColor: Colors.white10,
                              highlightedBorderColor: Colors.white,
                              borderSide: BorderSide(color: Colors.white),
                              child: Text("DONASI",
                                  style: Theme.of(context).textTheme.display4),
                            )
                          ]),
                    ),
                  )
                ]))));
  }

  Widget _buildPartner() {
    return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5),
                child: globals.myText(
                    text: "PARTNER JLF", color: 'dark', size: 15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FadeInImage.assetNetwork(
                    width: globals.mw(context) * 0.23,
                    placeholder: 'assets/images/loading.gif',
                    image: 'https://via.placeholder.com/150/92c952'),
                FadeInImage.assetNetwork(
                    width: globals.mw(context) * 0.23,
                    placeholder: 'assets/images/loading.gif',
                    image: 'https://via.placeholder.com/150/92c952'),
                FadeInImage.assetNetwork(
                    width: globals.mw(context) * 0.23,
                    placeholder: 'assets/images/loading.gif',
                    image: 'https://via.placeholder.com/150/92c952'),
                FadeInImage.assetNetwork(
                    width: globals.mw(context) * 0.23,
                    placeholder: 'assets/images/loading.gif',
                    image: 'https://via.placeholder.com/150/92c952'),
              ],
            )
          ],
        ));
  }

  Widget _buildArticle() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(5),
              child: globals.myText(
                  text: "ARTIKEL PILIHAN JLF", color: 'dark', size: 15)),
          Stack(
            children: <Widget>[
              Container(
                child: CarouselSlider(
                  aspectRatio: 3,
                  autoPlay: true,
                  viewportFraction: 3.0,
                  height: 200,
                  enableInfiniteScroll: true,
                  onPageChanged: (index) {
                    setState(() {
                      _currentArticle = index;
                    });
                  },
                  items: _articlesImages,
                ),
              ),
              Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      globals.myText(
                          text: "JLF", color: 'light', weight: "XB", size: 25)
                    ],
                  )),
              Positioned(
                  bottom: 10,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildDoted(_currentArticle + 1, _articlesImages.length)
                    ],
                  )),
              Positioned(
                  bottom: 30,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(4),
                        color: Color.fromRGBO(0, 0, 0, 0.4),
                          width: globals.mw(context) * 0.6,
                          child: globals.myText(
                              text: _articlesTitle[_currentArticle],
                              color: "light")),
                      Container(
                          width: globals.mw(context) * 0.2,
                          // padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => WebviewScaffold(
                                        url: _articlesLinks[_currentArticle],
                                        appBar: globals.appBar(
                                            _scaffoldKey, context))));
                              },
                              child: globals.myText(text: "BACA"),
                              color: globals.myColor('light'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                                  ))),
                    ],
                  ))
            ],
          ),
        ],
      ),
    );

    return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5),
                child: globals.myText(
                    text: "ARTIKEL PILIHAN JLF", color: 'dark', size: 15)),
            Container(
              width: globals.mw(context),
              child: Card(
                  child: Stack(
                children: <Widget>[
                  FadeInImage.assetNetwork(
                      width: globals.mw(context) * 0.23,
                      placeholder: 'assets/images/loading.gif',
                      image: 'https://via.placeholder.com/150/92c952'),
                  // globals.myText(text: "AWKAWKAWK")
                ],
              )),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _exitDialog();
        return;
      },
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: globals.bottomNavigationBar(context),
          drawer: drawer(context),
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                isLoadingSlider ? globals.isLoading() : _buildCarousel(),
                _buildAsk(),
                _buildNumberMember(),
                _buildTitle(),
                _buildGridCategory(animalCategories),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Divider(color: Colors.black),
                ),
                isLoadingPromo ? globals.isLoading() : _buildPromotion(),
                _buildArticle(),
                _buildPartner(),
                Divider(),
                _buildDonation()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
