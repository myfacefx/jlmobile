import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPage createState() => _ProductDetailPage();
}

class _ProductDetailPage extends State<ProductDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildImage() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
      height: 180,
      color: Colors.black,
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

  Widget _buildDesc() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Siberian Husky - 2018 / White /CUTE",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Theme.of(context).primaryColor)),
          SizedBox(
            height: 8,
          ),
          Text(
            "Namanya Boni sitambun, dengan nama asli bunny dummy puppy. Kulit bersih, terbiasa hidup susah dan suka makan tulang",
            style: Theme.of(context).textTheme.display2,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("Posted by : Algoj ojo - 12/12/2019 15:43",
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .copyWith(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRule(String title, double nominal) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.display3,
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5)),
            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
            child: Text(
              globals.convertToMoney(nominal),
              style: Theme.of(context)
                  .textTheme
                  .display3
                  .copyWith(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  TableRow _buildTableRow(bool isFirst) {
    return TableRow(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "Budi",
            style: Theme.of(context)
                .textTheme
                .display4
                .copyWith(color: Color.fromRGBO(136, 136, 136, 1)),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "14/01 - 12:10",
            style: Theme.of(context).textTheme.display1,
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: isFirst ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(5)),
            width: 100,
            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text(
              globals.convertToMoney(820000),
              style: Theme.of(context).textTheme.display3.copyWith(
                  color: isFirst
                      ? Colors.white
                      : Color.fromRGBO(178, 178, 178, 1)),
            ),
          ),
          Spacer()
        ],
      ),
    ]);
  }

  TableRow _buildHeaderTable() {
    return TableRow(children: [
      Text("BIDER",
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Theme.of(context).primaryColor)),
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Text("STATUS",
            style: Theme.of(context)
                .textTheme
                .subtitle
                .copyWith(color: Theme.of(context).primaryColor)),
      ),
    ]);
  }

  Widget _buildBidStatus() {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Table(
          border: TableBorder(
              bottom: BorderSide(color: Colors.grey[300]),
              verticalInside: BorderSide(color: Colors.grey[300]),
              horizontalInside: BorderSide(color: Colors.grey[300])),
          children: [
            _buildHeaderTable(),
            _buildTableRow(true),
            _buildTableRow(false),
            _buildTableRow(false),
            _buildTableRow(false),
          ]),
    );
  }

  Widget _buildBidRule() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        children: <Widget>[
          Text(
            "-- BID STATUS --",
            style: Theme.of(context).textTheme.subtitle,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildRule("start", 130000.0),
              _buildRule("current", 140000.0),
              _buildRule("bin", 1000000.0),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _buildBidStatus(),
        ],
      ),
    );
  }

  Widget textField() {
    return Stack(
      children: <Widget>[
        Container(
          width: globals.mw(context) - 80,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(30)),
          child: TextField(
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Your Bid | Multiply 25.000',
                hintStyle: TextStyle(fontSize: 14)),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30)),
            child: FlatButton(
              onPressed: () {},
              child: Text(
                "B.I.N",
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPutBid() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: <Widget>[
          Text(
            "-- PASANG BID --",
            style: Theme.of(context).textTheme.subtitle,
          ),
          SizedBox(
            height: 20,
          ),
          textField(),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25)),
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    "DONE",
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
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
        drawer: globals.drawer(context),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _buildImage(),
              SizedBox(
                height: 8,
              ),
              _buildDesc(),
              SizedBox(
                height: 8,
              ),
              _buildBidRule(),
              SizedBox(
                height: 16,
              ),
              _buildPutBid()
            ],
          ),
        ),
      ),
    );
  }
}
