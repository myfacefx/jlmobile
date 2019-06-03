import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jlf_mobile/models/animal_category.dart';
import 'package:jlf_mobile/pages/category_detail.dart';
import 'package:jlf_mobile/services/animal_category_services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  int _current = 0;
  bool isLoadingCategories = true;
  List<AnimalCategory> animalCategories = List<AnimalCategory>();

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

  Widget _buildDoted(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _current == index ? Colors.black : Colors.grey),
    );
  }

  Widget _buildCarousel() {
    List<Widget> listImage = [
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            'https://media.mercola.com/imageserver/public/2011/May/two-cute-pet-puppies05.03.jpg',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            'https://www.disktrend.com/wp-content/uploads/2017/03/Jack-Russell-Terrier-running.jpg',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            'https://dbw4iivs1kce3.cloudfront.net/680x390/2014/05/Lactation-pregnant-dog.jpg',
      ),
      FadeInImage.assetNetwork(
        placeholder: 'assets/images/loading.gif',
        image:
            'https://cdn.newsapi.com.au/image/v1/9ff9ff58d79063b90446a39560fdeaa2?width=650',
      )
    ];
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(20, 16, 20, 16),
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          child: CarouselSlider(
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            height: 153,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: listImage,
          ),
        ),
        Positioned(
            bottom: 9,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [0, 1, 2, 3].map((i) {
                return _buildDoted(i);
              }).toList(),
            ))
      ],
    );
  }

  Widget _buildAsk() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
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
      margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
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
        ],
      ),
    );
  }

  Widget detail(String name, String count) {
    return Container(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: Theme.of(context).textTheme.subtitle,
          ),
          Text("$count Items", style: Theme.of(context).textTheme.display1),
        ],
      ),
    );
  }

  Widget image(String slug) {
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
          image: slug,
        ),
      ),
    );
  }

  Widget gridList(AnimalCategory category1, AnimalCategory category2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        cardAnimal(category1),
        Opacity(
            opacity: category2 != null ? 1 : 0,
            child: cardAnimal(category2 != null ? category2 : category1)),
      ],
    );
  }

  Widget cardAnimal(AnimalCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CategoryDetailPage()));
      },
      child: Card(
        child: Container(
          width: 160,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              image(category.slug),
              SizedBox(
                width: 8,
              ),
              detail(category.name, category.count.toString())
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalCategories(List<AnimalCategory> animals) {
    List<Widget> listMyWidgets() {
      List<Widget> list = List();
      if (!isLoadingCategories) {
        for (var i = 0; i < animals.length; i += 2) {
          if ((i + 2) - animals.length == 1) {
            list.add(gridList(animals[i], null));
          } else {
            list.add(gridList(animals[i], animals[i + 1]));
          }
        }
      }

      return list;
    }

    return isLoadingCategories
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: listMyWidgets(),
            ),
          );
  }

  Widget _buildPromotion() {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: globals.mw(context) * 0.83,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif',
                image: 'http://hd.wallpaperswide.com/thumbs/animal_8-t2.jpg',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  width: globals.mw(context) * 0.4,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/loading.gif',
                    image:
                        'http://hd.wallpaperswide.com/thumbs/animal_8-t2.jpg',
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.white,
                  width: globals.mw(context) * 0.4,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(context),
      drawer: globals.drawer(),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _buildCarousel(),
            _buildAsk(),
            _buildTitle(),
            _buildAnimalCategories(animalCategories),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 5, 35, 5),
              child: Divider(color: Colors.black),
            ),
            _buildPromotion()
          ],
        ),
      ),
    );
  }
}
