import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/models/promo.dart';
import 'package:jlf_mobile/services/promo_services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromoPage extends StatefulWidget {
  @override
  _PromoState createState() => _PromoState();
}

class _PromoState extends State<PromoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool isLoadingPromoB = true;
  List<Promo> listPromoB = [];

  _PromoState() {
    _loadPromoB();
  }

  _loadPromoB() {
    getAllPromos(globals.user.tokenRedis, "iklan", "B").then((onValue) async {
      if (onValue == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      if (onValue.length != 0) {
        listPromoB = onValue;
      }

      setState(() {
        isLoadingPromoB = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoadingPromoB = false;
      });
    });
  }

  Widget _buildPromotionB() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: globals.myText(text: "PROMO JLF BULAN INI", weight: "B", size: 20),
        ),
        Flexible(
          child: ListView.builder(
                  padding: const EdgeInsets.all(15.0),
                  itemCount: listPromoB.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        String url = listPromoB[index].name;
                        globals.openPdf(context, url, listPromoB[index].fileName);
                      },
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: CachedNetworkImage(
                                imageUrl: listPromoB[index].link,
                                placeholder: (context, url) =>
                                    Image.asset('assets/images/loading.gif', height: 175),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/error.jpeg',
                                  height: 75,
                                ),
                              ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    );
                  }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
          key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: _buildPromotionB()
            ),
        ),
      ));
  }
}