import 'package:flutter/material.dart';

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
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/loading.gif',
                image: image,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
