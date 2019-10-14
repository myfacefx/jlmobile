import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/animal_image.dart';
import 'package:photo_view/photo_view.dart';

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
        child: Hero(tag: widget.tagCount, child: _buildCarousel()),
      ),
    );
  }

  Widget _buildCarousel() {
    final slider = Carousel(
      images: listImage,
      dotBgColor: Colors.black,
      autoplay: false,
    );

    return Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            height: globals.mh(context) * 0.9,
            child: slider),
      ],
    );
  }
}
