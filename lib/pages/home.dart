import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jlf_mobile/pages/category_detail.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool failedDataCategories = false;
  List<AnimalCategory> animalCategories = List<AnimalCategory>();
  int membersCount = 0;

  List<Widget> listImage = [
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refresh();
    _getListCategories();
    globals.getNotificationCount();
  }

  _refresh() {
    getUsersCount().then((onValue) {
      membersCount = onValue;
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
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

  Widget _buildDoted(int index, int total) {
    return Container(
      child: globals.myText(text: "$index / $total", color: "light", weight: "XB"),
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
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      height: 64,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "BINGUNG ? YUK SINI KAMI AJARIN",
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: Row(
        children: <Widget>[
          Text(
            "BID",
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
          globals.myText(text: "$membersCount MEMBER", color: 'dark')
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
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif',
                image: 'http://hd.wallpaperswide.com/thumbs/animal_8-t2.jpg',
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  width: globals.mw(context) * 0.47,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image:
                        'http://hd.wallpaperswide.com/thumbs/animal_8-t2.jpg',
                  ),
                ),
                // SizedBox(
                //   width: 10,
                // ),
                Container(
                  color: Colors.white,
                  width: globals.mw(context) * 0.47,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image:
                        'http://hd.wallpaperswide.com/thumbs/animal_8-t2.jpg',
                  ),
                ),
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
    // return;
    // return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text("Perhatian",
    //             style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
    //             textAlign: TextAlign.center),
    //         content: Text("Log out dari aplikasi?",
    //             style: TextStyle(color: Colors.black)),
    //         actions: <Widget>[
    //           FlatButton(
    //               child: Text("Batal",
    //                   style: TextStyle(color: Theme.of(context).primaryColor)),
    //               onPressed: () {
    //                 Navigator.of(context).pop(true);
    //               }),
    //           FlatButton(
    //               color: Theme.of(context).primaryColor,
    //               child: Text("Ya", style: TextStyle(color: Colors.white)),
    //               onPressed: () {
    //                 _logOut();
    //               })
    //         ],
    //       );
    //     });
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
                _buildCarousel(),
                _buildAsk(),
                _buildTitle(),
                _buildGridCategory(animalCategories),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Divider(color: Colors.black),
                ),
                _buildPromotion()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
