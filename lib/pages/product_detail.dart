import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPage createState() => _ProductDetailPage();
}

class _ProductDetailPage extends State<ProductDetailPage> {
  Widget _buildImage() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
              style:
                  Theme.of(context).textTheme.display1.copyWith(fontSize: 8)),
            ],
          ),
          
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(_scaffoldKey),
      body: Scaffold(
        key: _scaffoldKey,
        drawer: globals.drawer(),
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
            ],
          ),
        ),
      ),
    );
  }
}
