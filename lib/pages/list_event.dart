import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/promo.dart';
import 'package:jlf_mobile/services/promo_services.dart';
import 'package:jlf_mobile/pages/zoom_banner_image.dart';

class ListEventPage extends StatefulWidget {
  @override
  _ListEventPageState createState() => _ListEventPageState();
}

class _ListEventPageState extends State<ListEventPage> {
  bool isLoadingPromoC = true;
  List<Promo> listPromoC = [];
  int _current = 0;

  _ListEventPageState() {
    _loadPromosC();
  }

  _loadPromosC() {
    getAllPromos(globals.user.tokenRedis, "iklan", "C").then((onValue) {
      if (onValue.length != 0) {
        listPromoC = onValue;
      }

      setState(() {
        isLoadingPromoC = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPromoC = false;
      });
    });
  }

  Widget _buildPromotionC() {
    final slider = CarouselSlider(
      aspectRatio: 3,
      viewportFraction: 3.0,
      height: 220,
      enableInfiniteScroll: true,
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
      items: listPromoC.map((f) {
        return Container(
          width: globals.mw(context),
          margin: EdgeInsets.fromLTRB(5, 10, 5, 16),
          child: CachedNetworkImage(
            width: globals.mw(context) * 0.23,
            height: isLoadingPromoC ? 20 : null,
            imageUrl: f.link,
            placeholder: (context, url) =>
                Image.asset('assets/images/loading.gif'),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/error.jpeg'),
          ),
        );
      }).toList(),
    );
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            globals.debugPrint('tapped');
            globals.debugPrint(slider.items);
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => 
                        ZoomBannerImagePage(image: listPromoC[_current].link, imageName: listPromoC[_current].name)
                    )
                  );
          },
          child: Container(
            child: slider,
          ),
        ),
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.nextPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              slider.previousPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.black.withOpacity(0.7),
              child: Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: globals.appBar(null, context, isSubMenu: true),
      body: isLoadingPromoC
          ? globals.isLoading()
          : ListView(
              children: <Widget>[
                _buildPromotionC(),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(
                        Icons.save,
                        color: globals.myColor("light"),
                      ),
                      color: globals.myColor("primary"),
                      label: globals.myText(
                          text: "Download Gambar", color: "light"),
                      onPressed: () async {
                        try {
                          // Saved with this method.
                          globals.loadingModel(context);
                          var imageId = await ImageDownloader.downloadImage(
                              listPromoC[_current].link);
                          Navigator.pop(context);
                          if (imageId == null) {
                            return;
                          }
                          var path = await ImageDownloader.findPath(imageId);
                          await ImageDownloader.open(path).catchError((error) {
                            if (error is PlatformException) {
                              if (error.code == "preview_error") {
                                globals.debugPrint(error.message);
                              }
                            }
                          });
                        } on PlatformException catch (error) {
                          if (error is PlatformException) {
                            if (error.code == "404") {
                              globals.debugPrint("Not Found Error.");
                              globals.showDialogs(
                                  "File Not Found 404", context);
                              globals.mailError("Download image event",
                                  "image not found 404");
                            } else if (error.code == "unsupported_file") {
                              globals.debugPrint("UnSupported FIle Error.");
                              globals.showDialogs(
                                  "UnSupported FIle Error.", context);
                              globals.mailError("Download image event",
                                  error.details["unsupported_file_path"]);
                            }
                          }

                          globals.debugPrint(error);
                        }
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      globals.myText(
                          text:
                              "Tanggal Mulai : ${globals.convertFormatDateTime(listPromoC[_current].startDate)}"),
                      SizedBox(
                        height: 10,
                      ),
                      globals.myText(
                          text:
                              "Tanggal Selesai : ${globals.convertFormatDateTime(listPromoC[_current].endDate)}")
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(12, 20, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      globals.myText(text: listPromoC[_current].description)
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
