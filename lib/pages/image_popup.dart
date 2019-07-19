import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePopupPage extends StatelessWidget {
  final String image;
  final String tagCount;
  final String animalName;
  ImagePopupPage(
      {Key key,
      @required this.image,
      @required this.tagCount,
      @required this.animalName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animalName),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            Hero(
                tag: tagCount,
                child: PhotoView(
                  imageProvider: NetworkImage(image),
                )),
          ],
        ),
      ),
    );
  }
}
