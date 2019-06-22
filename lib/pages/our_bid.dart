import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/animal_services.dart';

class OurBidPage extends StatefulWidget {
  @override
  _OurBidPageState createState() => _OurBidPageState();
}

class _OurBidPageState extends State<OurBidPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();

  String selectedProvince = "All";
  String selectedSortBy = "Terbaru";

  List<Animal> animals = List<Animal>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getOurBid();
  }

  _getOurBid() {
    getUserBidsAnimals("Token", globals.user.id).then((onValue) {
      animals = onValue;
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
  }

  // sort and search
  Widget dropdownSortBy() {
    List<String> item = <String>['Terbaru', 'Populer'];
    return DropdownButton<String>(
        value: selectedSortBy,
        items: item.map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSortBy = value;
            //_refresh(currentIdSubCategory, currentSubCategory);
          });
        });
  }

  Widget _buildTextSearch() {
    return Container(
      width: globals.mw(context) * 0.6,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
          //_refresh(currentIdSubCategory, currentSubCategory);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(fontSize: 10)),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          dropdownSortBy(),
          _buildTextSearch(),
        ],
      ),
    );
  }
  // sort and search

  //build top name
  Widget _buildTopCont() {
    return Container(
      width: globals.mw(context),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: globals.myText(text: "OUR BID", size: 16, weight: "SB"),
    );
  }
  //build top name

// build listview
  Widget _buildListView() {
    return Container(
      child: animals.length == 0
          ? Center(
              child: Text(
                "Data tidak ditemukan",
                style: Theme.of(context).textTheme.title,
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: animals.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildCard(animals[index]);
              },
            ),
    );
  }

  Widget _buildStatus(String status) {
    var colorBox = Colors.black;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 8,
        ),
        Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorBox),
        ),
        SizedBox(
          width: 8,
        ),
        globals.myText(text: "on running", color: "unprime"),
      ],
    );
  }

  Widget _buildTimer(String status) {
    var colorBox = Theme.of(context).primaryColor;
    var colorText = "light";
    return Container(
      width: 85,
      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: colorBox, borderRadius: BorderRadius.circular(5)),
      child:
          globals.myText(text: "10 Minutes Left", color: colorText, size: 10),
    );
  }

  Widget _buildCard(Animal animal) {
    return Card(
      child: Column(
        children: <Widget>[
          //build status and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_buildStatus(""), _buildTimer("")],
          ),
          //detail
        ],
      ),
    );
  }
  // build listview

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: Container(
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 8,
                  ),
                  _buildTopCont(),
                  SizedBox(
                    height: 8,
                  ),
                  _buildSearch(),
                  SizedBox(
                    height: 16,
                  ),
                  isLoading ? globals.isLoading() : _buildListView()
                ]),
              ),
            )));
  }
}
