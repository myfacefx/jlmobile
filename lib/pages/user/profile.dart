import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/auction/activate.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/pages/event_promotion/promo.dart';
import 'package:jlf_mobile/pages/product/edit.dart';
import 'package:jlf_mobile/pages/product_detail.dart';
import 'package:jlf_mobile/services/animal_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({Key key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState(userId);
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  FacebookLogin facebookLogin = FacebookLogin();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;
  TextEditingController searchController = TextEditingController();

  bool isLoadingAnimals = true;
  bool isLoadingAuctions = true;
  bool isLoadingProducts = true;
  bool isLoading = true;

  List<Animal> animals = List<Animal>();
  List<Animal> auctions = List<Animal>();
  List<Animal> products = List<Animal>();

  int _userId;
  User user;

  _ProfilePageState(int userId) {
    _tabController = TabController(length: userId == null ? 3 : 2, vsync: this);
    if (userId == null || userId <= 0) {
      user = globals.user;
      _userId = globals.user.id;
      isLoading = false;
    } else {
      _userId = userId;
      getUserById(_userId, globals.user.tokenRedis).then((onValue) async {
        if (onValue == null) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
        user = onValue;
        isLoading = false;
      }).catchError((onError) {
        globals.debugPrint(onError.toString());
        globals.showDialogs(onError.toString(), context);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    refresh();
  }

  refresh() async {
    _getProdukKu();
    _getProdukLelang();
    _getProdukPasarHewan();
    globals.getNotificationCount().then((a) async {
      setState(() {});
    });
  }

  _getProdukKu() {
    getUserUnauctionedAnimals(
            globals.user.tokenRedis, _userId, searchController.text)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      animals = onValue;
      setState(() {
        isLoadingAnimals = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  _getProdukLelang() {
    getUserAuctionAnimals(
            globals.user.tokenRedis, _userId, searchController.text)
        .then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      auctions = onValue;
      setState(() {
        isLoadingAuctions = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  _getProdukPasarHewan() {
    getUserProductAnimals(
      globals.user.tokenRedis,
      _userId,
      searchController.text,
    ).then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      products = onValue;
      setState(() {
        isLoadingProducts = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError.toString(), context);
    });
  }

  // Card Animals
  Widget _buildAnimals(List<Animal> data, String type) {
    return data.length == 0
        ? Center(
            child: Text(
              "Data tidak ditemukan",
              style: Theme.of(context).textTheme.title,
            ),
          )
        : Container(
            child: GridView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            physics: ScrollPhysics(),
            semanticChildCount: 2,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio:
                    (type == "produkku" || type == "pasarhewan") ? 0.6 : 0.5,
                crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return _buildCard(data[index], type);
            },
          ));
  }

  Widget _buildTime(String expiryTime) {
    List<String> splitText = expiryTime.split(" ");
    String date = splitText[0];

    final exptDate = DateTime.parse(expiryTime);
    final dateNow = DateTime.now();
    final differenceMinutes = (dateNow.difference(exptDate).inMinutes).abs();
    String def = "";
    def = "${(dateNow.difference(exptDate).inSeconds).abs()} Sec";

    //1 year
    if (differenceMinutes > 525600) {
      def = "${differenceMinutes ~/ 525600} Year";
    }
    //1 month
    else if (differenceMinutes > 43200) {
      def = "${differenceMinutes ~/ 43200} Month";
    }
    //1 day
    else if (differenceMinutes > 1440) {
      def = "${differenceMinutes ~/ 1440} Day";
    }

    //1 hour
    else if (differenceMinutes > 60) {
      def = "${differenceMinutes ~/ 60} Hour";
    } else if (differenceMinutes > 1) {
      def = "$differenceMinutes Min";
    }

    return Container(
      width: globals.mw(context) * 0.5,
      child: Text(
        "$def Remaining - ${globals.convertFormatDate(date)}",
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
      String name, String userPost, String gender, DateTime birthDate) {
    // String ageNow = globals.convertToAge(birthDate);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // "$name $gender - $ageNow",
            "$name",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 12),
          ),
          Text(userPost, style: Theme.of(context).textTheme.display1),
        ],
      ),
    );
  }

  Widget _buildEditAuction(Animal animal) {
    return Positioned(
      bottom: 4,
      right: 10,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      EditProductPage(animal: animal)));
          this.refresh();
        },
        splashColor: globals.myColor("primary"),
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
            child: Center(child: Icon(Icons.settings))),
      ),
    );
  }

  Widget _buildEditAnimal(int animalId) {
    return user.id == globals.user.id
        ? Positioned(
            bottom: 4,
            right: 10,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ActivateAuctionPage(
                              animalId: animalId,
                            )));
              },
              splashColor: globals.myColor("primary"),
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
                  child: Center(
                      child:
                          Icon(Icons.edit, color: globals.myColor("primary")))),
            ),
          )
        : Container();
  }

  Widget _buildProdukKu(Animal animal) {
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
    }

    return Stack(
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: GestureDetector(
              onTap: () {
                user.id == globals.user.id
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ActivateAuctionPage(
                                  animalId: animal.id,
                                )))
                    : null;
              },
              child: Card(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      isNotError
                          ? _buildImage(animal.animalImages[0].image)
                          : globals.failLoadImage(),
                      _buildDetail(animal.name, animal.owner.username,
                          animal.gender, animal.dateOfBirth),
                    ],
                  ),
                ),
              ),
            )),
        _buildEditAnimal(animal.id),
      ],
    );
  }

  Widget _buildProdukLelang(Animal animal) {
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
                            from: "LELANG",
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
                    animal.auction.active == 1
                        ? _buildTime(animal.auction.expiryDate)
                        : Container(),
                    isNotError
                        ? _buildImage(animal.animalImages[0].image)
                        : globals.failLoadImage(),
                    _buildDetail(animal.name, animal.owner.username,
                        animal.gender, animal.dateOfBirth),
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
        // _buildEditAuction(animal.id),
        animal.auction.active == 0
            ? Positioned(
                bottom: 20,
                left: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: globals.mw(context) * 0.25,
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: globals.myColor("danger"),
                          borderRadius: BorderRadius.circular(5)),
                      child: globals.myText(
                          align: TextAlign.center,
                          text: "BERAKHIR",
                          color: "light",
                          size: 10),
                    )
                  ],
                ))
            : Container(),
      ],
    );
  }

  Widget _buildPasarHewan(Animal animal) {
    var isNotError = false;
    if (animal.animalImages.length > 0 &&
        animal.animalImages[0].image != null) {
      isNotError = true;
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
                              from: "PASAR HEWAN",
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
                      isNotError
                          ? _buildImage(animal.animalImages[0].image)
                          : globals.failLoadImage(),
                      _buildDetail(animal.name, animal.owner.username,
                          animal.gender, animal.dateOfBirth),
                      SizedBox(
                        height: 5,
                      ),
                      _buildChips(
                          "Harga Jual",
                          globals
                              .convertToMoney(animal.product.price.toDouble())),
                      _buildChips(
                          "Jenis",
                          animal.product.type == "animal"
                              ? "Hewan"
                              : "Aksesoris"),
                    ],
                  ),
                ),
              ),
            )),
        animal.product.status != "sold out"
            ? animal.ownerUserId == globals.user.id
                ? _buildEditAuction(animal)
                : Container()
            : Container(),
        animal.product.status == "sold out"
            ? Positioned(
                bottom: 20,
                left: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: globals.mw(context) * 0.25,
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: globals.myColor("danger"),
                          borderRadius: BorderRadius.circular(5)),
                      child: globals.myText(
                          align: TextAlign.center,
                          text: "Terjual",
                          color: "light",
                          size: 10),
                    )
                  ],
                ))
            : Container(),
      ],
    );
  }

  Widget _buildCard(Animal animal, String type) {
    var widget;
    switch (type) {
      case "produkku":
        widget = _buildProdukKu(animal);
        break;
      case "produklelang":
        widget = _buildProdukLelang(animal);
        break;
      case "pasarhewan":
        widget = _buildPasarHewan(animal);
        break;
      default:
    }
    return widget;
  }

  _syncFacebook() async {
    setState(() {
      isLoading = true;
    });

    if (globals.user.facebookUserId != null) {
      globals.showDialogs("Akun Anda sudah terhubung dengan Facebook", context);
      setState(() {
        isLoading = false;
      });
      return false;
    }

    FacebookLoginResult result = await facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        globals.debugPrint("####FACEBOOK OUTPUT#####");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,address,gender,location,picture.type(large).redirect(false)&access_token=${result.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        globals.debugPrint(profile.toString());

        if (profile['id'] != null) {
          User user = User();
          user.facebookUserId = profile['id'];

          Map<String, dynamic> response = await updateUserFacebookUserId(user.toJson(), globals.user.id, globals.user.tokenRedis);

          if (response != null) {
            if (response['status'] == 'success') {
              await globals.showDialogs(response['message'], context);

              setState(() {
                globals.user.facebookUserId = profile['id'];
              });
            } else {
              await globals.showDialogs(response['message'], context);
              setState(() {});
              globals.debugPrint("ERR: " + response.toString());
            }
          }

          setState(() {
            isLoading = false;
          });
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        // globals.showDialog("Login dengan Facebook dibatalkan", context);
        setState(() {
          isLoading = false;
        });
        throw new StateError("Cancelled by user");
        break;
      case FacebookLoginStatus.error:
        // LoginManager
        globals.showDialogs("Error: ${result.errorMessage}", context);
        facebookLogin.logOut();

        setState(() {
          isLoading = false;
        });
        // throw new StateError(FacebookLoginStatus.error.toString());
        break;
    }
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
                      ? Color.fromRGBO(239, 192, 80, 1)
                      : globals.myColor("primary"),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  width: (globals.mw(context) * 0.15),
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

  _navigateTo(String path) {
    Navigator.pushNamed(context, path);
  }

  // card animals
  Widget _profile() {
    var registeredDate = DateTime.parse(user.createdAt.toString());

    String userPoint = globals.user.point > 999
        ? (globals.user.point / 1000).toStringAsFixed(1)
        : globals.user.point.toString();

    String userCoupon = globals.user.coupon > 999
        ? (globals.user.coupon / 1000).toStringAsFixed(1)
        : globals.user.coupon.toString();

    return Container(
      padding: EdgeInsets.all(5),
      width: globals.mw(context),
      child: Card(
          child: Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Stack(
                children: <Widget>[
                  user.id == globals.user.id
                      ? Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      width: 87,
                                      child: ButtonTheme(
                                        height: 25,
                                        child: FlatButton(
                                            onPressed: () {
                                              var text = RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            'Saat ini anda telah mendapatkan $userPoint Point JLF, Point JLF dapat ditukarkan dengan hadiah menarik silahkan cek halaman promo untuk lebih lanjut'),
                                                  ],
                                                ),
                                              );
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Promo Point JLF'),
                                                    content: text,
                                                    actions: <Widget>[
                                                      FlatButton(
                                                          child: Text(
                                                              'Cek Hadiah'),
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        PromoPage()));
                                                          }),
                                                      FlatButton(
                                                        child: Text('Tutup'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                globals.myText(
                                                    text: "$userPoint POIN",
                                                    color: "light",
                                                    size: 11.5,
                                                    weight: "B")
                                              ],
                                            ),
                                            color: isLoading
                                                ? Colors.grey
                                                : globals.myColor("warning"),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        var text = RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      'Halo sobat JLF, Point bisa anda dapatkan setiap transaksi di JLF dengan syarat khusus. Point bisa ditukarkan dengan hadiah menarik sedangkan kupon anda bisa mengikuti tantangan JLF setiap minggunya. Silahkan cek halaman promo untuk lebih detail.'),
                                            ],
                                          ),
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Informasi'),
                                              content: text,
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Cek Promo'),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                PromoPage()));
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text('Tutup'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Icon(Icons.info_outline,
                                            color: globals.myColor("warning")),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            // Text Kupon
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      width: 80,
                                      child: ButtonTheme(
                                        height: 25,
                                        child: FlatButton(
                                            onPressed: () {
                                              var text = RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            'Saat ini anda telah mendapatkan $userCoupon Kupon JLF, Kupon JLF dapat ditukarkan dengan hadiah menarik silahkan cek halaman promo untuk lebih lanjut'),
                                                  ],
                                                ),
                                              );
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Promo Kupon JLF'),
                                                    content: text,
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child:
                                                            Text('Cek Hadiah'),
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      PromoPage()));
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text('Tutup'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    globals.myText(
                                                        text: "$userCoupon",
                                                        color: "light",
                                                        size: 12,
                                                        weight: "B"),
                                                    Container(
                                                      width: 20,
                                                      height: 30,
                                                      child: Image.asset(
                                                          'assets/images/coupon.png'),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            color: isLoading
                                                ? Colors.grey
                                                : globals.myColor("light-blue"),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(),
                  user.id == globals.user.id
                      ? Container(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton(
                            onSelected: (val) => _navigateTo(val),
                            icon: Icon(Icons.edit,
                                color: globals.myColor("primary")),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                    value: '/edit-profile',
                                    child: globals.myText(text: "Ubah Profil")),
                                PopupMenuItem(
                                    value: "/edit-password",
                                    child:
                                        globals.myText(text: "Ubah Password")),
                              ];
                            },
                          ))
                      : Container(),
                  Column(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          height: 100,
                          child: CircleAvatar(
                              radius: 100,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: user.photo != null
                                          ? FadeInImage.assetNetwork(
                                              image: user.photo,
                                              placeholder:
                                                  'assets/images/loading.gif',
                                              fit: BoxFit.cover)
                                          : Image.asset(
                                              'assets/images/account.png'))))),
                      globals.user.facebookUserId == null ? Container(
                        alignment: Alignment.topLeft,
                        width: globals.mw(context) * 0.5,
                        child: ButtonTheme(
                          height: 30,
                          child: FlatButton(
                              onPressed: () {
                                _syncFacebook();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  globals.myText(
                                    text: " HUBUNGKAN DENGAN",
                                    color: "light",
                                    size: 11.5,
                                    weight: "B"),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Container(
                                      height: 18,
                                      decoration: BoxDecoration(
                                          color: Colors.white, borderRadius: BorderRadius.circular(25)),
                                      child: Image.asset(
                                        "assets/images/Facebook.png",
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              color: isLoading
                                  ? Colors.grey
                                  : globals.myColor("primary"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ) : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          globals.myText(
                              text: user.name != null ? user.name : '',
                              textOverflow: TextOverflow.ellipsis,
                              color: "dark",
                              weight: "B",
                              size: 18),
                          globals.user.verificationStatus == 'verified'
                              ? Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: GestureDetector(
                                      onTap: () => globals.showDialogs(
                                          "Selamat, akun anda telah terverifikasi",
                                          context),
                                      child: Icon(Icons.verified_user,
                                          size: 18,
                                          color: globals.myColor("primary"))))
                              : Container(),
                          // globals.myText(
                          //     text: '4.5',
                          //     textOverflow: TextOverflow.ellipsis,
                          //     color: "dark",
                          //     weight: "B",
                          //     size: 18),
                        ],
                      ),
                      SizedBox(height: 3),
                      globals.myText(
                          text: user.username != null ? user.username : '',
                          textOverflow: TextOverflow.ellipsis,
                          color: "dark",
                          weight: ":",
                          size: 12),
                      SizedBox(height: 3),
                      globals.myText(
                          text: "Bergabung sejak " +
                              "${registeredDate.day} ${globals.convertMonthFromDigit(registeredDate.month)} ${registeredDate.year}",
                          textOverflow: TextOverflow.ellipsis,
                          color: "dark",
                          size: 12),
                      SizedBox(height: 3),
                      globals.myText(
                          text:
                              user.phoneNumber != null ? user.phoneNumber : "",
                          textOverflow: TextOverflow.ellipsis,
                          color: "dark",
                          size: 12),
                      SizedBox(height: 3),
                      Wrap(
                        children: <Widget>[
                          Icon(Icons.location_on,
                              size: 12, color: globals.myColor("primary")),
                          globals.myText(
                              text: user.regency.name != null
                                  ? user.regency.name
                                  : "",
                              textOverflow: TextOverflow.ellipsis,
                              color: "dark",
                              size: 12),
                          globals.myText(
                              text: user.province.name != null
                                  ? ", " + user.province.name
                                  : "",
                              textOverflow: TextOverflow.ellipsis,
                              color: "dark",
                              size: 12),
                        ],
                      ),
                      user.description != null && user.description.isNotEmpty
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: globals.myText(
                                  text: user.description != null
                                      ? user.description
                                      : '',
                                  color: 'grey',
                                  align: TextAlign.center),
                            )
                          : Container(),
                      Container(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/point-history");
                            },
                            child: Text('Lihat Riwayat Poin',
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    decoration: TextDecoration.underline)),
                          ),
                        ),
                      ),
                      user.id == globals.user.id
                          ? FlatButton(
                              // shape: CircleBorder(),
                              color: globals.myColor("primary"),
                              onPressed: () {
                                Navigator.pushNamed(context, "/auction/create");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Buat Produk",
                                      style: TextStyle(color: Colors.white)),
                                  Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                ],
                              ))
                          : Container(),
                    ],
                  ),
                ],
              ))),
    );
  }

  Widget _tabBarListVisitor() {
    return Container(
        padding: EdgeInsets.all(5),
        width: globals.mw(context),
        child: Card(
            child: Container(
                child: TabBar(
          labelColor: globals.myColor("primary"),
          indicatorColor: globals.myColor("primary"),
          unselectedLabelColor: globals.myColor("primary"),
          controller: _tabController,
          tabs: <Widget>[
            Tab(
                child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Produk Lelang ", size: 11),
                  auctions.length > 0
                      ? Container(
                          constraints:
                              BoxConstraints(minWidth: 10, minHeight: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: globals.myText(
                              text: "${auctions.length}",
                              weight: "B",
                              color: 'light',
                              size: 10))
                      : Container()
                ],
              ),
            )),
            Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                globals.myText(text: "Produk Pasar Hewan ", size: 11),
                products.length > 0
                    ? Container(
                        constraints:
                            BoxConstraints(minWidth: 10, minHeight: 10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(100)),
                        child: globals.myText(
                            text: "${products.length}",
                            weight: "B",
                            color: 'light',
                            size: 10))
                    : Container()
              ],
            )),
          ],
        ))));
  }

  Widget _tabBarListMe() {
    return Container(
        padding: EdgeInsets.all(5),
        width: globals.mw(context),
        child: Card(
            child: Container(
                child: TabBar(
          labelColor: globals.myColor("primary"),
          indicatorColor: globals.myColor("primary"),
          unselectedLabelColor: globals.myColor("primary"),
          controller: _tabController,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
                child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: globals.mw(context) * 0.25,
              constraints: BoxConstraints(minWidth: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Produk Lelang ", size: 11),
                  auctions.length > 0
                      ? Container(
                          constraints:
                              BoxConstraints(minWidth: 10, minHeight: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: globals.myText(
                              text: "${auctions.length}",
                              weight: "B",
                              color: 'light',
                              size: 10))
                      : Container()
                ],
              ),
            )),
            Tab(
                child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: globals.mw(context) * 0.25,
              constraints: BoxConstraints(minWidth: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Produk Jual Beli ", size: 11),
                  products.length > 0
                      ? Container(
                          constraints:
                              BoxConstraints(minWidth: 10, minHeight: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: globals.myText(
                              text: "${products.length}",
                              weight: "B",
                              color: 'light',
                              size: 10))
                      : Container()
                ],
              ),
            )),
            Tab(
                child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: globals.mw(context) * 0.2,
              constraints: BoxConstraints(minWidth: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Draft ", size: 11),
                  animals.length > 0
                      ? Container(
                          constraints:
                              BoxConstraints(minWidth: 10, minHeight: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: globals.myText(
                              text: "${animals.length}",
                              weight: "B",
                              color: 'light',
                              size: 10))
                      : Container()
                ],
              ),
            )),
          ],
        ))));
  }

  Widget _buildTextSearch() {
    return Container(
      width: globals.mw(context) * 0.75,
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
          refresh();
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Nama Binatang',
            hintStyle: TextStyle(fontSize: 9)),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      color: globals.myColor("primary"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTextSearch(),
          ButtonTheme(
            minWidth: 40,
            child: OutlineButton(
              borderSide: BorderSide(color: Colors.white),
              onPressed: () {
                refresh();
              },
              child: globals.myText(text: "Cari", color: "light", size: 10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: isLoading
                ? globals.isLoading()
                : SafeArea(
                    child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: <Widget>[
                      _profile(),
                      widget.userId == null
                          ? _tabBarListMe()
                          : _tabBarListVisitor(),
                      _buildSearch(),
                      widget.userId == null ? buildMe() : buildVisitor(),
                    ],
                  ))));
  }

  Container buildMe() {
    return Container(
      height: 400,
      padding: EdgeInsets.all(5),
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Container(
              child: isLoadingAuctions
                  ? globals.isLoading()
                  : _buildAnimals(auctions, "produklelang")),
          Container(
              child: isLoadingProducts
                  ? globals.isLoading()
                  : _buildAnimals(products, "pasarhewan")),
          Container(
              child: isLoadingAnimals
                  ? globals.isLoading()
                  : _buildAnimals(animals, "produkku")),
        ],
      ),
    );
  }

  Container buildVisitor() {
    return Container(
      height: 400,
      padding: EdgeInsets.all(5),
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Container(
              child: isLoadingAuctions
                  ? globals.isLoading()
                  : _buildAnimals(auctions, "produklelang")),
          Container(
              child: isLoadingProducts
                  ? globals.isLoading()
                  : _buildAnimals(products, "pasarhewan")),
        ],
      ),
    );
  }
}
