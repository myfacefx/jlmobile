import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomBannerImagePage extends StatelessWidget {
  final String image;
  final String imageName;

  ZoomBannerImagePage({Key key, @required this.image, @required this.imageName }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imageName),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(
          image,
        ),
      ),
    );
  }
}