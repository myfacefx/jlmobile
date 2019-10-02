import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/auction.dart';
import 'package:jlf_mobile/models/top_seller.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/category_detail.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/component/pdf_viewer.dart';
import 'package:jlf_mobile/pages/not_found.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/pages/user/profile.dart';
import 'package:jlf_mobile/pages/how_to_join_hot_auction.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/auction_event_services.dart';
import 'package:jlf_mobile/services/promo_services.dart';
import 'package:jlf_mobile/services/static_services.dart';
import 'package:jlf_mobile/services/top_seller_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:jlf_mobile/services/version_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _sub;

  int _current = 0;

  bool isLoadingCategories = true;
  bool isLoadingPromoA = true;
  bool isLoadingPromotedTopSellers = true;
  bool isLoadingSponsoredProducts = true;
  bool isLoadingAuctionEvents = true;

  bool failedDataCategories = false;
  bool alreadyUpToDate = false;

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  List<TopSeller> promotedTopSellers = List<TopSeller>();
  List<Auction> hotAuctions = List<Auction>();
  List<Animal> sponsoredProducts = List<Animal>();
  int membersCount = 0;
  int animalCount = 0;
  int promosCountC = 0;
  List<Widget> listPromoA = [];

  String selectedType = "PASAR HEWAN";

  @override
  void initState() {
    super.initState();

    _checkVersion();

    if (globals.user != null) {
      _verificationCheck();
      _refresh();
      _getListCategoriesProduct();
      _getHotAuctions();
      _getSponsoredProducts();
      _getPromotedTopSeller();

      _loadPromosA();

      globals.getNotificationCount();
      globals.generateToken();
      globals.notificationListener(context);
    }

    initUniLinks();
    initUniLinksStream();

    handleAppLifecycleState();

    subscribeFCM();

    _verificationBonusPoint();
  }

  _verificationBonusPoint() async {
    if (globals.user != null) {
      globals.debugPrint(
          "${globals.user.point} & ${globals.user.verificationStatus}");
      if (globals.user.point == 0 &&
          globals.user.verificationStatus == 'verified') {
        Map<String, dynamic> response = await verificationBonusPoint(
            globals.user.id, globals.user.tokenRedis);

        if (response['status'] == 'succes') {
          SchedulerBinding.instance
              .addPostFrameCallback((_) => globals.loadRewardPoint(context));

          // Pop Up Success
          setState(() {
            globals.user.point = 20;
          });
        }
      } else {
        globals.debugPrint("Yahhh");
      }
    }
  }

  subscribeFCM() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.subscribeToTopic('announcement');
  }

  _getHotAuctions() {
    setState(() {
      isLoadingAuctionEvents = true;
    });

    getAuctionEventParticipants(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }

      setState(() {
        hotAuctions = onValue;
        isLoadingAuctionEvents = false;
      });
    });
  }

  _getSponsoredProducts() {
    setState(() {
      isLoadingSponsoredProducts = true;
    });

    getSponsoredProducts(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }

      setState(() {
        sponsoredProducts = onValue;
        isLoadingSponsoredProducts = false;
      });
    });
  }

  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {
      globals.debugPrint('SystemChannels> $msg');

      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          break;
        case "AppLifecycleState.suspending":
          _lastLifecyleState = AppLifecycleState.suspending;
          break;
        default:
      }
    });
  }

  _verificationCheck() async {
    if (globals.user != null) {
      User userResponse =
          await getUserById(globals.user.id, globals.user.tokenRedis);
      if (userResponse == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }

      setState(() {
        globals.user.verificationStatus = userResponse.verificationStatus;
        globals.user.identityNumber = userResponse.identityNumber;
      });

      // if (globals.user.verificationStatus == null ||
      //     globals.user.verificationStatus == 'denied') {
      //   Timer.run(() {
      //     Navigator.of(context).pop();
      //     Navigator.of(context).pushNamed("/verification");
      //   });
      // }
    }
  }

  @override
  dispose() {
    super.dispose();
    if (_sub != null) _sub.cancel();
  }

  void _getPromotedTopSeller() {
    setState(() {
      isLoadingPromotedTopSellers = true;
    });
    getPromotedTopSeller(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      setState(() {
        promotedTopSellers = onValue;
        isLoadingPromotedTopSellers = false;
      });
    });
  }

  void _checkVersion() {
    globals.debugPrint("Checking Version");
    verifyVersion(globals.version).then((onValue) async {
      if (!onValue.isUpToDate) {
        final result = await globals.showUpdate(
            onValue.url, onValue.isForceUpdate, onValue.message, context);
        globals.debugPrint(result);
        if (!result) {
          _checkVersion();
        }
      } else {
        globals.debugPrint("Already Up To Date Version");
        setState(() {
          alreadyUpToDate = true;
        });
      }
    }).catchError((onError) async {
      await globals.showDialogs(
          "Maaf, Server Sedang Dalam Maintenance,\nSilakan Coba Beberapa Saat Lagi",
          context);
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }

  Future<Null> initUniLinks() async {
    try {
      Uri initialLink = await getInitialUri();
      if (initialLink != null) {
        checkAppLink(initialLink);
      }
    } on PlatformException {}
  }

  Future<Null> initUniLinksStream() async {
    _sub = getUriLinksStream().listen((Uri link) {
      if (!mounted) return;

      if (link != null) {
        checkAppLink(link);
      } else {
        pushToPage(null, null);
      }
    }, onError: (err) {
      pushToPage(null, null);
    });
  }

  void checkAppLink(Uri link) {
    try {
      int animalId = int.parse(link.queryParameters["animal"]);
      String from;

      if (link.queryParameters["type"] == "LL") {
        from = "LELANG";
      } else if (link.queryParameters["type"] == "PS") {
        from = "PASAR HEWAN";
      }

      pushToPage(animalId, from);
    } catch (e) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => NotFoundPage()));
    }
  }

  void pushToPage(animalId, from) {
    if (animalId != null && from != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ProductDetailPage(
                    animalId: animalId,
                    from: from,
                  )));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => NotFoundPage()));
    }
  }

  _loadPromosA() {
    getAllPromos(globals.user.tokenRedis, "iklan", "A").then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      if (onValue.length != 0) {
        listPromoA = [];
        onValue.forEach((slider) {
          listPromoA.add(GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WebviewScaffold(
                      // displayZoomControls: true,
                      scrollBar: true,
                      withZoom: true,
                      url: slider.name,
                      appBar: globals.appBar(_scaffoldKey, context,
                          isSubMenu: true, showNotification: false))));
            },
            child: CachedNetworkImage(
              imageUrl: slider.link,
              placeholder: (context, url) =>
                  Image.asset('assets/images/loading.gif'),
              errorWidget: (context, url, error) =>
                  Image.asset('assets/images/error.jpeg'),
            ),
          ));
        });
      } else {
        listPromoA = getTemplateSlider();
      }

      setState(() {
        isLoadingPromoA = false;
      });
    }).catchError((onError) {
      listPromoA = getTemplateSlider();
      setState(() {
        isLoadingPromoA = false;
      });
    });
  }

  _refresh() {
    getUsersCount().then((onValue) {
      membersCount = onValue;
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });

    getAnimalsCount().then((onValue) {
      animalCount = onValue;
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });

    getCountPromos("iklan", "c").then((onValue) {
      promosCountC = onValue;
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
        image: 'https://placeimg.com/520/200/animals?5',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image: 'https://placeimg.com/520/200/animals?6',
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

  void _getListCategoriesAuction() {
    setState(() {
      failedDataCategories = false;
      isLoadingCategories = true;
    });

    getAnimalCategory(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
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

  void _getListCategoriesProduct() {
    setState(() {
      failedDataCategories = false;
      isLoadingCategories = true;
    });

    getProductAnimalCategory(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
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

  void _getListCategoriesPetShop() {
    setState(() {});
  }

  void _getListCategoriesVeterinarian() {
    setState(() {});
  }

  void _getAccessoryAnimalCategory() {
    setState(() {
      failedDataCategories = false;
      isLoadingCategories = true;
    });

    getAccessoryAnimalCategory(globals.user.tokenRedis).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
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
            autoPlayInterval: Duration(seconds: 25),
            viewportFraction: 3.0,
            height: 218,
            enableInfiniteScroll: true,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: listPromoA,
          ),
        ),
        Positioned(
            bottom: 10,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_buildDoted(_current + 1, listPromoA.length)],
            ))
      ],
    );
  }

  // Widget _buildAsk() {
  //   return GestureDetector(
  //     onTap: () =>
  //         launch("https://www.youtube.com/channel/UCW-Y3yIisBSOIJhV3ToA5oA"),
  //     child: Container(
  //       margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
  //       padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
  //       height: 64,
  //       decoration: BoxDecoration(
  //           color: Theme.of(context).primaryColor,
  //           borderRadius: BorderRadius.circular(4)),
  //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //         globals.myText(
  //             text: "TONTON PANDUAN DAN TIPS TRIK LENGKAP JLF DI SINI",
  //             color: "light",
  //             size: 16,
  //             align: TextAlign.center),
  //       ]),
  //     ),
  //   );
  // }

  Widget _buildNumberMember() {
    String numberUser = (membersCount / 1000).toStringAsFixed(1);
    String numberAnimal = (animalCount / 1000).toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            height: 45,
            width: globals.mw(context) * 0.45,
            decoration: BoxDecoration(
                color: Color.fromRGBO(241, 171, 27, 1),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image.asset("assets/images/peoplecount.png"),
                globals.myText(text: numberUser + "K Users", color: "light")
              ],
            )),
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 16),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            height: 45,
            width: globals.mw(context) * 0.45,
            decoration: BoxDecoration(
                color: Color.fromRGBO(209, 43, 65, 1),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image.asset("assets/images/animalcount.png"),
                globals.myText(text: numberAnimal + "K Animals", color: "light")
              ],
            ))
      ],
    );
  }

  Widget _buildVerificationStatus() {
    String display = 'Verifikasi Tanda Pengenal Pending';
    String color = 'warning';

    if (globals.user != null) {
      var _verificationStatus = globals.user.verificationStatus;

      if (_verificationStatus == null) {
        display = 'Konfirmasi Nomor WA mu dapatkan 5 Poin JLF Gratis';
        color = 'danger';
      } else {
        if (_verificationStatus == 'verified') {
          display = "Verifikasi Tanda Pengenal Sukses";
          color = 'success';
        } else if (_verificationStatus == 'denied') {
          color = 'danger';
          display = "Verifikasi Tanda Pengenal Ditolak, silahkan ulangi";
        }
      }

      return _verificationStatus != 'verified'
          ? GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/verification"),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                height: 35,
                decoration: BoxDecoration(
                    color: globals.myColor(color),
                    borderRadius: BorderRadius.circular(4)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      globals.myText(
                          text: display,
                          color: "light",
                          size: 12,
                          weight: "N",
                          align: TextAlign.center,
                          textOverflow: TextOverflow.ellipsis)
                    ]),
              ),
            )
          : Container();
    } else {
      return Container();
    }
  }

  Widget _buildEventHewan() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/list-event");
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 16, 10, 8),
          padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
          height: 60,
          width: globals.mw(context) * 0.45,
          decoration: BoxDecoration(
              color: Color.fromRGBO(49, 122, 229, 1),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/calendar.png",
                height: 33,
              ),
              Expanded(
                flex: 3,
                child: Text(""),
              ),
              globals.myText(
                  text: "$promosCountC EVENT HEWAN BARU, SUDAH LIHAT ?",
                  color: "light",
                  weight: "B",
                  size: 14),
              Expanded(
                flex: 2,
                child: Text(""),
              ),
            ],
          )),
    );
  }

  Widget _templateHotAuction(Auction auction) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage(
                      animalId: auction.animalId,
                      from: "LELANG",
                    )));
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 13),
          child: Stack(
            children: <Widget>[
              Container(
                  width: 80,
                  child: Container(
                      height: 70,
                      child: CircleAvatar(
                          radius: 75,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: auction.animal.animalImages[0].thumbnail !=
                                      null
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      placeholder: 'assets/images/loading.gif',
                                      image: auction
                                          .animal.animalImages[0].thumbnail)
                                  : Image.asset(
                                      'assets/images/account.png'))))),
              Positioned(
                bottom: 5,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                      color: globals.myColor("hot-auction"),
                      borderRadius: BorderRadius.circular(5)),
                  child: globals.myText(
                      text:
                          "+ ${auction.auctionEventParticipant.auctionEvent.extraPoint} POIN",
                      weight: "B",
                      color: 'light',
                      textOverflow: TextOverflow.ellipsis,
                      align: TextAlign.center),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                      color: globals.myColor("hot-auction"),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.timer, color: Colors.white, size: 14),
                      globals.myText(
                          text:
                              " ${globals.convertTimer(auction.auctionEventParticipant.auctionEvent.endDate)}",
                          weight: "B",
                          color: 'light',
                          textOverflow: TextOverflow.ellipsis,
                          align: TextAlign.center),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionEvents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
            height: 25,
            // width: 20,
            width: 145,
            decoration: BoxDecoration(
                color: globals.myColor("hot-auction"),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "assets/images/hot_auction.png",
                  height: 14,
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HowToJoinHotAuctionPage()));
                  },
                  child: globals.myText(
                      text: " LELANG PANAS ",
                      color: "light",
                      weight: "B",
                      size: 14),
                ),
                Image.asset(
                  "assets/images/hot_auction.png",
                  height: 14,
                ),
              ],
            )),
        Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(5)),
            child: isLoadingAuctionEvents
                ? globals.isLoading()
                : hotAuctions.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: false,
                        itemBuilder: (context, index) {
                          return _templateHotAuction(hotAuctions[index]);
                        },
                        itemCount: hotAuctions.length,
                      )
                    : globals.myText(text: "Belum ada lelang panas saat ini"))
      ],
    );
  }

  Widget _buildSponsoredProduct() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
              height: 25,
              width: globals.mw(context) * 0.55,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(34, 34, 34, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/sponsored_product.png",
                    height: 11,
                  ),
                  globals.myText(
                      text: " SPONSORED PRODUCTS",
                      color: "light",
                      weight: "B",
                      size: 14),
                  Expanded(
                    flex: 2,
                    child: Text(""),
                  ),
                ],
              )),
          Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 90,
              // width: globals.mw(context) * 0.45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: isLoadingSponsoredProducts
                  ? globals.isLoading()
                  : sponsoredProducts.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            return _templateSponsoredProducts(
                                sponsoredProducts[index]);
                          },
                          itemCount: sponsoredProducts.length,
                        )
                      : globals.myText(
                          text: "Belum ada sponsored product saat ini"))
        ]);
  }

  Widget _buildPromotedSeller() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
              height: 25,
              width: globals.mw(context) * 0.55,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(34, 34, 34, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/promoted_seller.png",
                    height: 11,
                  ),
                  globals.myText(
                      text: " PROMOTED SELLERS",
                      color: "light",
                      weight: "B",
                      size: 14),
                  Expanded(
                    flex: 2,
                    child: Text(""),
                  ),
                ],
              )),
          Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              height: 90,
              // width: globals.mw(context) * 0.45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: isLoadingPromotedTopSellers
                  ? globals.isLoading()
                  : promotedTopSellers.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            return _templateTopSellerProfile(
                                promotedTopSellers[index]);
                          },
                          itemCount: promotedTopSellers.length,
                        )
                      : globals.myText(
                          text: "Belum ada promoted seller pada kategori ini"))
        ]);
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

  Widget _templateSponsoredProducts(Animal animal) {
    return GestureDetector(
      onTap: () async {
        animal.id != null
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ProductDetailPage(
                          animalId: animal.id,
                          from: "PASAR HEWAN",
                        )))
            : null;
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 13),
          child: Stack(
            children: <Widget>[
              Container(
                  width: 80,
                  child: Container(
                      height: 70,
                      child: CircleAvatar(
                          radius: 75,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: animal.animalImages[0].thumbnail != null
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      placeholder: 'assets/images/loading.gif',
                                      image: animal.animalImages[0].thumbnail)
                                  : Image.asset(
                                      'assets/images/account.png'))))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      height: 15,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (selectedType != "PASAR HEWAN") {
                selectedType = "PASAR HEWAN";
                _getListCategoriesProduct();
              }
            },
            child: globals.myText(
                text: "JUAL BELI",
                size: 16,
                color: selectedType == "PASAR HEWAN" ? null : "disabled"),
          ),
          Text("  |  ", style: Theme.of(context).textTheme.headline),
          GestureDetector(
            onTap: () async {
              bool res = false;
              try {
                globals.loadingModel(context);
                res = await checkAvailable(globals.user.tokenRedis, "LELANG");
                if (res == null) {
                  await globals.showDialogs(
                      "Session anda telah berakhir, Silakan melakukan login ulang",
                      context,
                      isLogout: true);
                  return;
                }
                Navigator.pop(context);
              } catch (e) {
                globals.debugPrint(e.toString());
                Navigator.pop(context);
              }

              if (res) {
                if (selectedType != "LELANG") {
                  selectedType = "LELANG";
                  _getListCategoriesAuction();
                }
              } else {
                globals.showDialogs("Under Maintenance", context);
              }
            },
            child: globals.myText(
                text: "LELANG",
                size: 16,
                color: selectedType == "LELANG" ? null : "disabled"),
          ),
          Text("  |  ", style: Theme.of(context).textTheme.headline),
          GestureDetector(
            onTap: () {
              if (selectedType != "PET SHOP") {
                selectedType = "PET SHOP";
                _getListCategoriesPetShop();
              }
            },
            child: globals.myText(
                text: "PET SHOP",
                size: 16,
                color: selectedType == "PET SHOP" ? null : "disabled"),
          ),
          Text("  |  ", style: Theme.of(context).textTheme.headline),
          GestureDetector(
            onTap: () {
              if (selectedType != "DOKTER HEWAN") {
                selectedType = "DOKTER HEWAN";
                _getListCategoriesVeterinarian();
              }
            },
            child: globals.myText(
                text: "DOKTER HEWAN",
                size: 16,
                color: selectedType == "DOKTER HEWAN" ? null : "disabled"),
          ),
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
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: url,
          placeholder: (context, url) =>
              Image.asset('assets/images/loading.gif'),
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/error.jpeg'),
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
                        from: selectedType,
                      )));
        },
        child: Card(
          child: Stack(
            children: <Widget>[
              Container(
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
              // category.animalsCount == 0
              //     ? Positioned.fill(
              //         child: Align(
              //           alignment: Alignment.center,
              //           child: Container(
              //             decoration: BoxDecoration(
              //               color: Colors.black.withOpacity(0.6),
              //               borderRadius: BorderRadius.circular(4),
              //             ),
              //             width: double.infinity,
              //             height: double.infinity,
              //           ),
              //         ),
              //       )
              //     : Container(),
              // category.animalsCount == 0
              //     ? Positioned.fill(
              //         child: Align(
              //             alignment: Alignment.center,
              //             child: Container(
              //               width: double.infinity,
              //               height: double.infinity,
              //               child: Padding(
              //                 padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              //                 child: Column(
              //                   mainAxisAlignment: MainAxisAlignment.end,
              //                   crossAxisAlignment: CrossAxisAlignment.end,
              //                   children: <Widget>[
              //                     globals.myText(
              //                         text: "Segera Hadir",
              //                         color: "light",
              //                         size: 14,
              //                         weight: "SB"),
              //                   ],
              //                 ),
              //               ),
              //             )),
              //       )
              //     : Container(),
            ],
          ),
        ));
  }

  Widget _buildLaranganBinatang() {
    return GestureDetector(
        onTap: () async {
          String url = getBaseUrl() + "/download/restricted-animals";
          globals.openPdf(context, url, "Hewan Dilindungi");
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Image.asset("assets/images/daftar_binatang_dilarang.jpg"),
        ));
  }

  Widget _buildGridCategory(List<AnimalCategory> animals, String selectedType) {
    if (selectedType == 'PET SHOP') {
      return _buildPetShop();
    } else if (selectedType == 'DOKTER HEWAN') {
      return _buildVeterinarian();
    } else {
      List<Widget> listMyWidgets() {
        List<Widget> list = List();
        if (!isLoadingCategories) {
          var currentAnimal;
          for (var i = 0; i < animals.length; i++) {
            currentAnimal = animals[i];

            if (selectedType == 'LELANG') {
              if (currentAnimal.name.toUpperCase() != 'ANJING' &&
                  currentAnimal.name.toUpperCase() != 'KUCING') {
                list.add(cardAnimal(currentAnimal));
              }
            } else {
              list.add(cardAnimal(currentAnimal));
            }
          }
        }

        return list;
      }

      return failedDataCategories
          ? globals.buildFailedLoadingData(context, _getListCategoriesAuction)
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
  }

  Widget _buildPetShop() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 150,
            height: 150,
            child: Image.asset('assets/images/map.png'),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Saat Ini Kami Masih Berkeliling Mengumpulkan Partner',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: GestureDetector(
              onTap: () {
                globals.openInterestLink();
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Tertarik bergabung ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeterinarian() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 150,
            height: 150,
            child: Image.asset('assets/images/veterinarian.png'),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Saat Ini Kami Masih Berkeliling Mengumpulkan Partner',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: GestureDetector(
              onTap: () {
                globals.openInterestLink();
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Tertarik bergabung ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _exitDialog() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Widget _buildDonation() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/donasi"),
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Image.asset('assets/images/donation_banner.png'),
      ),
    );
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
              child: !alreadyUpToDate
                  ? globals.isLoading()
                  : ListView(
                      children: <Widget>[
                        _buildVerificationStatus(),
                        isLoadingPromoA
                            ? globals.isLoading()
                            : _buildCarousel(),
                        _buildLaranganBinatang(),
                        _buildNumberMember(),
                        _buildTitle(),
                        _buildGridCategory(animalCategories, selectedType),
                        _buildEventHewan(),
                        _buildAuctionEvents(),
                        _buildSponsoredProduct(),
                        // _buildPromotedSellerItems(),
                        _buildPromotedSeller(),
                        // _buildPromotedSellerItems(),
                        _buildDonation(),
                      ],
                    ),
            ),
          ),
          floatingActionButton: Container(
            height: 120,
            width: 120,
            color: Color.fromRGBO(0, 0, 0, 0),
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () {
                  globals.sendOTP(globals.user.phoneNumber);
                },
                child: Image.asset("assets/images/floatingbutton.png"),
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                elevation: 0,
              ),
            ),
          )),
    );
  }
}

class ImageOverlay extends StatefulWidget {
  final String image;
  ImageOverlay({this.image});
  @override
  _ImageOverlayState createState() => _ImageOverlayState();
}

class _ImageOverlayState extends State<ImageOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(height: 200, color: Color.fromRGBO(0, 0, 0, 0.6)),
      height: 200,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: new NetworkImage(this.widget.image), fit: BoxFit.contain)),
    );
  }
}
