import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/models/article.dart';
import 'package:jlf_mobile/models/jlf_partner.dart';
import 'package:jlf_mobile/models/promo.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/category_detail.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/pages/not_found.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/article_services.dart';
import 'package:jlf_mobile/services/jlf_partner_services.dart';
import 'package:jlf_mobile/services/promo_services.dart';
import 'package:jlf_mobile/services/static_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:jlf_mobile/services/version_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  StreamSubscription _sub;

  int _current = 0;

  bool isLoadingCategories = true;
  bool isLoadingPromoA = true;
  bool isLoadingPromoB = true;
  bool isLoadingPromoC = true;
  bool isLoadingArticle = true;

  bool isLoadingPromoVideo = true;
  bool failedDataCategories = false;
  bool alreadyUpToDate = false;

  bool isLoadingPartner = true;

  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  int membersCount = 0;
  List<Widget> listPromoA = [];
  List<Promo> listPromoB = [];
  List<Promo> listPromoC = [];
  List<Promo> listVideo = [];
  List<Article> listArticle = [];
  List<JlfPartner> listParner = [];
  String selectedType = "PASAR HEWAN";

  int _currentArticle = 0;

  @override
  void initState() {
    super.initState();

    _checkVersion();

    if (globals.user != null) {
      _verificationCheck();
      _refresh();
      _getListCategoriesProduct();

      _loadPromosA();
      _loadPromosB();
      _loadPromosC();
      _loadPromosVideo();
      _loadArticle();
      _loadJlfPartner();

      globals.getNotificationCount();
      globals.generateToken();
      globals.notificationListener(context);
    }

    initUniLinks();
    initUniLinksStream();

    handleAppLifecycleState();
  }

  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');

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
      // if (globals.user == null) {
      //   Timer.run(() {
      //     Navigator.of(context).pop();
      //     Navigator.of(context).pushNamed("/verification");
      //   });
      // } else {
      User userResponse = await get(globals.user.id);

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

  void _checkVersion() {
    print("Checking Version");
    verifyVersion("token", globals.version).then((onValue) async {
      if (!onValue.isUpToDate) {
        final result = await globals.showUpdate(
            onValue.url, onValue.isForceUpdate, onValue.message, context);
        print(result);
        if (!result) {
          _checkVersion();
        }
      } else {
        print("Already Up To Date Version");
        setState(() {
          alreadyUpToDate = true;
        });
      }
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
    int animalId;
    String from;
    List<String> tamp = link.pathSegments[1].split("f")[1].split("-");

    if (tamp[0] == "1") {
      from = "LELANG";
    } else if (tamp[0] == "2") {
      from = "PASAR HEWAN";
    }
    animalId = int.parse(tamp[1]);
    pushToPage(animalId, from);
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

  _loadJlfPartner() {
    getAllJlfPartner("token").then((onValue) {
      if (onValue.length != 0) {
        listParner = onValue;
      }

      setState(() {
        isLoadingPartner = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPartner = false;
      });
    });
  }

  _loadPromosA() {
    getAllPromos("token", "iklan", "A").then((onValue) {
      if (onValue.length != 0) {
        listPromoA = [];
        onValue.forEach((slider) {
          listPromoA.add(GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WebviewScaffold(
                      url: slider.name,
                      appBar: globals.appBar(_scaffoldKey, context,
                          isSubMenu: true, showNotification: false))));
            },
            child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif', image: slider.link),
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

  _loadPromosB() {
    getAllPromos("token", "iklan", "B").then((onValue) {
      if (onValue.length != 0) {
        listPromoB = onValue;
      }

      setState(() {
        isLoadingPromoB = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPromoB = false;
      });
    });
  }

  _loadPromosC() {
    getAllPromos("token", "iklan", "C").then((onValue) {
      if (onValue.length != 0) {
        listPromoC = onValue;
      }

      setState(() {
        isLoadingPromoC = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPromoC = false;
      });
    });
  }

  _loadPromosVideo() {
    getAllPromos("token", "video", "A").then((onValue) {
      if (onValue.length != 0) {
        listVideo = onValue;
      }

      setState(() {
        isLoadingPromoVideo = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPromoVideo = false;
      });
    });
  }

  _loadArticle() {
    getAllArticle("token", "article").then((onValue) {
      if (onValue.length != 0) {
        listArticle = onValue;
      }

      setState(() {
        isLoadingArticle = false;
      });
    }).catchError((onError) {
      print(onError.toString());
      setState(() {
        isLoadingArticle = false;
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

    getAnimalCategory("token").then((onValue) {
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

    getProductAnimalCategory("token").then((onValue) {
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

  void _getAccessoryAnimalCategory() {
    setState(() {
      failedDataCategories = false;
      isLoadingCategories = true;
    });

    getAccessoryAnimalCategory("token").then((onValue) {
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
            height: 200,
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

  Widget _buildAsk() {
    return GestureDetector(
      onTap: () =>
          launch("https://www.youtube.com/channel/UCW-Y3yIisBSOIJhV3ToA5oA"),
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        height: 64,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          globals.myText(
              text: "TONTON PANDUAN DAN TIPS TRIK LENGKAP JLF DI SINI",
              color: "light",
              size: 16,
              align: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildNumberMember() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 35,
      decoration: BoxDecoration(
          color: Color.fromRGBO(73, 187, 255, 1),
          borderRadius: BorderRadius.circular(4)),
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

  Widget _buildVerificationStatus() {
    String display = 'Verifikasi Tanda Pengenal Pending';
    String color = 'warning';

    if (globals.user != null) {
      var _verificationStatus = globals.user.verificationStatus;

      if (_verificationStatus == null) {
        display = 'Belum mengajukan verifikasi Tanda Pengenal';
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
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                          align: TextAlign.center)
                    ]),
              ),
            )
          : Container();
    } else {
      return Container();
    }
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: Row(
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
            onTap: () {
              if (selectedType != "ACCESSORY") {
                selectedType = "ACCESSORY";
                _getAccessoryAnimalCategory();
              }
            },
            child: globals.myText(
                text: "AKSESORIS",
                size: 16,
                color: selectedType == "ACCESSORY" ? null : "disabled"),
          ),
          Text("  |  ", style: Theme.of(context).textTheme.headline),
          GestureDetector(
            onTap: () async {
              bool res = false;
              try {
                globals.loadingModel(context);
                res = await checkAvailable("token", "LELANG");
                Navigator.pop(context);
              } catch (e) {
                print(e.toString());
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
          Expanded(child: Text("")),
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

  Widget _buildPromotionB() {
    final slider = CarouselSlider(
      aspectRatio: 3,
      viewportFraction: 3.0,
      height: 200,
      enableInfiniteScroll: true,
      onPageChanged: (index) {
        setState(() {
          _currentArticle = index;
        });
      },
      items: listPromoB.map((f) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => WebviewScaffold(
                    url: f.name,
                    appBar: globals.appBar(_scaffoldKey, context,
                        isSubMenu: true, showNotification: false))));
          },
          child: Container(
            width: globals.mw(context),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 16),
            child: FadeInImage.assetNetwork(
                width: globals.mw(context) * 0.23,
                height: isLoadingPromoB ? 20 : null,
                placeholder: 'assets/images/loading.gif',
                image: f.link),
          ),
        );
      }).toList(),
    );
    return Stack(
      children: <Widget>[
        Container(
          child: slider,
        ),
        Positioned(
          right: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.nextPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          left: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.previousPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPromotionC() {
    final slider = CarouselSlider(
      aspectRatio: 3,
      viewportFraction: 3.0,
      height: 200,
      enableInfiniteScroll: true,
      onPageChanged: (index) {
        setState(() {
          _currentArticle = index;
        });
      },
      items: listPromoC.map((f) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => WebviewScaffold(
                    url: f.name,
                    appBar: globals.appBar(_scaffoldKey, context,
                        isSubMenu: true, showNotification: false))));
          },
          child: Container(
            width: globals.mw(context),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 16),
            child: FadeInImage.assetNetwork(
                width: globals.mw(context) * 0.23,
                height: isLoadingPromoB ? 20 : null,
                placeholder: 'assets/images/loading.gif',
                image: f.link),
          ),
        );
      }).toList(),
    );
    return Stack(
      children: <Widget>[
        Container(
          child: slider,
        ),
        Positioned(
          right: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.nextPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          left: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.previousPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildVideoA() {
    final slider = CarouselSlider(
      aspectRatio: 3,
      viewportFraction: 3.0,
      height: 200,
      enableInfiniteScroll: true,
      onPageChanged: (index) {
        setState(() {
          _currentArticle = index;
        });
      },
      items: listVideo.map((f) {
        String videoId;
        videoId = YoutubePlayer.convertUrlToId(f.link);
        return Container(
          width: globals.mw(context),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 16),
          child: YoutubePlayer(
            context: context,
            videoId: videoId,
            flags: YoutubePlayerFlags(
                showVideoProgressIndicator: true, autoPlay: false),
            videoProgressIndicatorColor: Colors.amber,
            progressColors: ProgressColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
          ),
        );
      }).toList(),
    );
    return Stack(
      children: <Widget>[
        Container(
          child: slider,
        ),
        Positioned(
          right: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
              onTap: () {
                slider.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.linear);
              },
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.7),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 23,
                  color: Colors.white,
                ),
              )),
        ),
        Positioned(
          left: 15,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.previousPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLaranganBinatang() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Color.fromRGBO(68, 182, 236, 1),
              ),
              width: globals.mw(context),
              height: 120,
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                children: <Widget>[
                  Container(
                    width: globals.mw(context) * 0.6,
                    child: globals.myText(
                        text: "Daftar binatang yang tidak boleh dijual di JLF",
                        color: "light",
                        size: 17,
                        weight: "B"),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: OutlineButton(
                padding: EdgeInsets.only(left: 12, right: 8),
                borderSide: BorderSide(color: Colors.white),
                highlightColor: Colors.white10,
                highlightedBorderColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100))),
                onPressed: () {
                  Navigator.pushNamed(context, "/blacklist-animal");
                },
                child: Row(
                  children: <Widget>[
                    Text("Lihat selengkapnya",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              bottom: 10,
              child: Container(
                height: 90,
                child: Image.asset("assets/images/larangan_binatang.png"),
              ),
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
                              onPressed: () {
                                Navigator.pushNamed(context, "/donasi");
                              },
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
        height: 115,
        margin: EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5),
                child: globals.myText(
                    text: "PARTNER JLF", color: 'dark', size: 15)),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: listParner.map((f) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: FadeInImage.assetNetwork(
                        width: globals.mw(context) * 0.23,
                        placeholder: 'assets/images/loading.gif',
                        image: f.thumbnail),
                  );
                }).toList(),
              ),
            ),
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
              padding: EdgeInsets.only(bottom: 5),
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
                  items: listArticle.map((f) {
                    return ImageOverlay(image: f.image);
                  }).toList(),
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
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          width: globals.mw(context) * 0.6,
                          child: globals.myText(
                              text: listArticle[_currentArticle].link,
                              color: "light")),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => WebviewScaffold(
                                  url: listArticle[_currentArticle].description,
                                  appBar: globals.appBar(_scaffoldKey, context,
                                      isSubMenu: true,
                                      showNotification: false))));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            width: globals.mw(context) * 0.2,
                            // Button
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                                child: globals.myText(
                                    text: "BACA",
                                    weight: "B",
                                    align: TextAlign.center))),
                      )
                    ],
                  ))
            ],
          ),
        ],
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
                      isLoadingPromoA ? globals.isLoading() : _buildCarousel(),
                      _buildAsk(),
                      _buildNumberMember(),
                      _buildTitle(),
                      _buildGridCategory(animalCategories),
                      _buildLaranganBinatang(),
                      _buildPartner(),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: globals.myText(
                              text: "EVENT JLF", color: 'dark', size: 15)),
                      isLoadingPromoB
                          ? globals.isLoading()
                          : _buildPromotionB(),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                          child: globals.myText(
                              text: "SPONSORED SELLER JLF",
                              color: 'dark',
                              size: 15)),
                      isLoadingPromoC
                          ? globals.isLoading()
                          : _buildPromotionC(),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: globals.myText(
                              text: "VIDEO TUTORIAL JLF",
                              color: 'dark',
                              size: 15)),
                      isLoadingPromoVideo
                          ? globals.isLoading()
                          : _buildVideoA(),
                      isLoadingArticle ? globals.isLoading() : _buildArticle(),
                      Divider(),
                      _buildDonation(),
                    ],
                  ),
          ),
        ),
      ),
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
