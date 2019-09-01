import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class ImagePopupPage extends StatefulWidget {
  final List<AnimalImage> image;
  final String tagCount;
  final String animalName;
  final int index;
  ImagePopupPage(
      {Key key,
      @required this.image,
      @required this.tagCount,
      @required this.animalName,
      @required this.index})
      : super(key: key);

  @override
  _ImagePopupPageState createState() => _ImagePopupPageState(image, index);
}

class _ImagePopupPageState extends State<ImagePopupPage> {
  int _current = 0;
  List<Widget> listImage = [];

  _ImagePopupPageState(List<AnimalImage> animalImages, int index) {
    animalImages.forEach((image) {
      listImage.add(PhotoView(
        enableRotation: true,
        imageProvider: NetworkImage(
          image.image,
        ),
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animalName),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            Hero(tag: widget.tagCount, child: _buildCarousel()),
          ],
        ),
      ),
    );
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
          height: globals.mh(context) * 0.9,
          child: CarouselSlider(
            enableInfiniteScroll: true,
            viewportFraction: 1.0,
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
              children: <Widget>[_buildDoted(_current + 1, listImage.length)],
            ))
      ],
    );
  }
}
