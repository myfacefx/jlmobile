import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/product_detail.dart';

class CategoryDetailPage extends StatefulWidget {
  @override
  _CategoryDetailPage createState() => _CategoryDetailPage();
}

class _CategoryDetailPage extends State<CategoryDetailPage> {
  ImageProvider defaultPic = const AssetImage("assets/images/dog2.jpg");

  //top container
  Widget _buildcontSub(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
      decoration: BoxDecoration(
          color: text.contains("ALL")
              ? Color.fromRGBO(186, 39, 75, 1)
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          text,
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  Widget _buildCategory(
    String text1,
    String text2,
    String text3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildcontSub(text1),
        _buildcontSub(text2),
        _buildcontSub(text3),
      ],
    );
  }

  Widget _buildTopCont() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        children: <Widget>[
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: defaultPic,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "164 ITEMS",
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "100 Player",
            style: Theme.of(context).textTheme.subtitle,
          ),
          SizedBox(
            height: 8,
          ),
          _buildCategory("ALL (300)", "BELGIAN. M (91)", "POM MINI (35)"),
          _buildCategory("TERRIER (34)", "BULDOG (30)", "MALTESEE (13)"),
        ],
      ),
    );
  }
  //top container

  //title add post bid

  Widget _buildTitle() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "ANJING - ALL",
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 16),
                height: 24,
                child: Image.asset("assets/images/icon_add.png"),
              ),
              Text(
                "POST BID",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w900),
              ),
            ],
          )
        ],
      ),
    );
  }

  //title add post bid

  // sort and search
  // sort and search

  // card animals
  Widget _buildcontCard() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildCard(),
              _buildCard(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTime() {
    return Row(
      children: <Widget>[
        Text("10 Min Remaining",
            style: Theme.of(context).textTheme.display1.copyWith(
                  fontSize: 12,
                )),
        SizedBox(
          width: 6,
        ),
        Text(
          "13/04/2019",
          style: Theme.of(context).textTheme.display1,
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      height: 128,
      color: Colors.black,
      width: 165,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: FadeInImage.assetNetwork(
          fit: BoxFit.fitHeight,
          placeholder: 'assets/images/loading.gif',
          image:
              'https://thenypost.files.wordpress.com/2018/10/102318-dogs-color-determine-disesases-life.jpg?quality=90&strip=all&w=618&h=410&crop=1',
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return Container(
      width: (globals.mw(context) * 0.5) - 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "POMERIAN BETINA - SEHAT 14 THN 09",
            style: Theme.of(context).textTheme.title.copyWith(fontSize: 12),
          ),
          Text("Mr Agustianto", style: Theme.of(context).textTheme.display1),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return Positioned(
      bottom: 4,
      right: 10,
      child: InkWell(
        onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProductDetailPage()));
        },
        splashColor: Theme.of(context).primaryColor,
        child: Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
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
              child: Text(
                "100",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 10),
              ),
            )),
      ),
    );
  }

  Widget _buildCard() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Card(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: Column(
                children: <Widget>[
                  _buildTime(),
                  _buildImage(),
                  _buildDetail(),
                  _buildChips("start", "130.000,-"),
                  _buildChips("multiplier", "10.000,-"),
                  _buildChips("bin", "190.000,-"),
                  _buildChips("current", "150.000,-"),
                ],
              ),
            ),
          ),
        ),
        _buildChat()
      ],
    );
  }

  Widget _buildcontChips(String text) {
    return Container(
      width: ((globals.mw(context) * 0.5) - 40) * 0.46,
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          text,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        )
      ]),
    );
  }

  Widget _buildChips(String text, String value) {
    return Container(
      width: (globals.mw(context) * 0.5) - 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              width: ((globals.mw(context) * 0.5) - 40) * 0.3,
              child: Text(text, style: Theme.of(context).textTheme.display2)),
          _buildcontChips(value)
        ],
      ),
    );
  }
  // card animals

  

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey, context),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: globals.drawer(context),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _buildTopCont(),
              SizedBox(
                height: 8,
              ),
              _buildTitle(),
              SizedBox(
                height: 16,
              ),
              _buildcontCard(),
              _buildcontCard(),
              _buildcontCard()
            ],
          ),
        ),
      ),
    );
  }
}
