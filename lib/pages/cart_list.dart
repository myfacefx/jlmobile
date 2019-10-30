import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/services/user_services.dart';

import 'component/drawer.dart';

class CartListPage extends StatefulWidget {
  @override
  _CartListPageState createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  List<Animal> _tempCart;

  @override
  void initState() {
    super.initState();
    loadTemporaryCart();
  }

  void loadTemporaryCart() async {
    String temporaryCart = await readLocalData("tempCart");
    if (temporaryCart != null) {
      setState(() {
        _tempCart = animalFromJson(temporaryCart);
        globals.debugPrint(_tempCart.toString());
        isLoading = false;
      });
    }
  }

  Widget _buildTime(
      String username, String photo, String regency, String province) {
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
                // width: globals.mw(context) * 0.30,
                padding: EdgeInsets.only(right: 5),
                child: globals.myText(
                    text: "$username",
                    size: 12,
                    textOverflow: TextOverflow.ellipsis)),
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
        ),
        Row(
          children: <Widget>[
            Icon(Icons.location_on, size: 10),
            SizedBox(
              width: 3,
            ),
            globals.myText(
                text: regency + ", " + province,
                textOverflow: TextOverflow.ellipsis,
                size: 10,
                color: "unprime",
                weight: "L"),
          ],
        )
      ],
    );
  }

  Widget _buildImage(String image) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      height: 85,
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: FadeInImage.assetNetwork(
          fit: BoxFit.fitHeight,
          placeholder: 'assets/images/loading.gif',
          image: image,
          width: 75,
        ),
      ),
    );
  }

  Widget _buildDetail(String name, int price) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${name.toUpperCase()}",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            "Rp " + globals.convertToMoney(price.toDouble()),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _templateAnimal(Animal animal, int index) {
    return Card(
      child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {},
          child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: <Widget>[
                  _buildTime(
                    animal.owner.username,
                    animal.owner.photo,
                    animal.owner.regency.name,
                    animal.owner.province.name,
                  ),
                  Divider(color: Color.fromRGBO(210, 208, 208, 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _buildImage(animal.animalImages[0].thumbnail),
                          SizedBox(
                            width: 10,
                          ),
                          _buildDetail(animal.name, animal.product.price),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                              icon: new Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              iconSize: 20,
                              onPressed: () {
                                isLoading = true;
                                _tempCart.removeAt(index);
                                setState(() {
                                  deleteLocalData('tempCart');
                                  saveLocalData(
                                      'tempCart', animalListToJson(_tempCart));
                                  globals.loadTemporaryCart();
                                  isLoading = false;
                                });
                                globals.showDialogs(
                                    "Berhasil Menghapus!", context);
                              }),
                        ],
                      )
                    ],
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Checkout", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {},
                  ),
                ],
              ))),
    );
  }

  Widget _buildSavedAnimals() {
    return Container(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _templateAnimal(_tempCart[index], index);
          },
          itemCount: _tempCart.length,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: isLoading
                ? globals.isLoading()
                : SafeArea(
                    child: Column(children: <Widget>[
                    Container(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Center(
                            child: globals.myText(
                                text: "Keranjang Belanja",
                                weight: "B",
                                color: "dark",
                                size: 22))),
                    Flexible(
                      child: _tempCart.length > 0
                          ? _buildSavedAnimals()
                          : Container(
                              child: globals.myText(
                                  text: "Tidak ada notifikasi", color: "dark")),
                    ),
                  ]))));
  }
}
