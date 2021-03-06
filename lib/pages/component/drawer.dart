import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:jlf_mobile/globals.dart';
import 'package:jlf_mobile/pages/component/pdf_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:jlf_mobile/globals.dart' as globals;

Widget _buildDrawerNavigationButtonBig(
    String title, String route, int bidCount, context) {
  return Container(
    padding: EdgeInsets.fromLTRB(0, 3, 20, 5),
    child: FlatButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.all(0),
      onPressed: () {
        if (route == '/share') {
          globals.share(null, null);
        } else if (route == 'verification') {
          globals.verificationOptionDialog(context);
        } else {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        }
      },
      child: SizedBox(
          width: double.infinity,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: Text(title,
                                style: TextStyle(color: Colors.white))),
                        bidCount != null && bidCount > 0
                            ? Container(
                                constraints:
                                    BoxConstraints(minWidth: 10, minHeight: 10),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text("$bidCount",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10)))
                            : Container(),
                      ]),
                  Divider(color: Colors.white)
                ],
              ))),
    ),
  );
}

Widget _buildDrawerNavigationButtonSmall(String title, String route, context) {
  return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 60, 0),
      height: 25,
      child: FlatButton(
        padding: EdgeInsets.only(left: 8),
        onPressed: () async {
          if (route == "/logout") {
            final result = await globals.confirmDialog(
                "Apakah anda yakin untuk keluar ?", context);
            if (result) {
              deleteLocalData("user");
              globals.state = "login";
              try {
                logout(globals.user.tokenRedis);
              } catch (e) {
                globals.debugPrint(e.toString());
              }

              Navigator.of(context).pop();
              Navigator.pushNamed(context, "/login");
            }
          }
          if (route == "contact") {
            const url = 'https://forms.gle/zKsUgngPEXGgjdXa8';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          }
          if (route == "terms") {
            String url = getBaseUrlAsset() + "/download/terms-policy";
            globals.openPdf(context, url, "Kebijakan Privasi");
          } else {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          }
        },
        child: SizedBox(
            width: double.infinity,
            child: Text(title,
                style: TextStyle(color: Colors.white, fontSize: 12))),
      ));
}

Widget drawer(context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.55,
    child: Drawer(
        child: Container(
            color: Theme.of(context).primaryColor,
            child: ListView(
              children: <Widget>[
                // Avatar
                Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    height: 150,
                    child: CircleAvatar(
                        radius: 100,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: globals.user != null &&
                                    globals.user.photo != null
                                ? FadeInImage.assetNetwork(
                                    image: globals.user.photo,
                                    placeholder: 'assets/images/loading.gif',
                                    fit: BoxFit.cover)
                                : Image.asset('assets/images/account.png')))),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    height: 20,
                    child: FlatButton(
                      onPressed: () {},
                      child: Text(
                        '${globals.user?.point??0} Poin JLF',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                ),
                Center(
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed("/profile");
                          },
                          color: Colors.transparent,
                          highlightColor: Colors.white10,
                          highlightedBorderColor: Colors.white,
                          borderSide: BorderSide(color: Colors.white),
                          child: Text("Edit Profile",
                              style: Theme.of(context).textTheme.display4),
                        ))),
                globals.spacePadding(),
                // _buildDrawerNavigationButtonBig(
                //     "Obrolan", '/chat-list', null, context),
                globals.user != null
                    ? globals.user.verificationStatus != 'verified'
                        ? _buildDrawerNavigationButtonBig(
                            "Verifikasi WhatsApp",
                            'verification',
                            null,
                            context)
                        : Container()
                    : Container(),
                _buildDrawerNavigationButtonBig("Beranda", '/', null, context),
                  _buildDrawerNavigationButtonBig("Wallet", '/balance-user',
                    globals.user != null ? 0 : 0, context),
                _buildDrawerNavigationButtonBig(
                    "Produkku", '/profile', null, context),
                _buildDrawerNavigationButtonBig("Lelang Diikuti", '/our-bid',
                    globals.user != null ? globals.user.bidsCount : 0, context),
                _buildDrawerNavigationButtonBig("Belanjaanku", '/our-product',
                    globals.user != null ? 0 : 0, context),
                _buildDrawerNavigationButtonBig(
                    "Donasi", '/donasi', null, context),
                _buildDrawerNavigationButtonBig(
                    "Promo JLF", '/promo', null, context),
                // buildDrawerNavigationButtonBig(
                //     "Bagikan JLF", '/share', null, context),
                globals.spacePadding(),
                _buildDrawerNavigationButtonSmall("Rekber", "/rekber", context),
                _buildDrawerNavigationButtonSmall(
                    "Hubungi Kami", "contact", context),
                _buildDrawerNavigationButtonSmall(
                    "Tentang JLF", "/about", context),
                _buildDrawerNavigationButtonSmall("Team JLF", "/team", context),
                _buildDrawerNavigationButtonSmall(
                    "Kebijakan Privasi", "terms", context),
                // _buildDrawerNavigationButtonSmall(
                //     "Pengaturan", "/setting", context),
                _buildDrawerNavigationButtonSmall("Keluar", "/logout", context),
                globals.spacePadding(),
                Center(
                    child: globals.myText(
                        text: "${globals.version}", size: 11, color: "light")),
                globals.spacePadding()
                // Container()
              ],
            ))
        // child: Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Container(
        //     child: ListView(padding: EdgeInsets.all(10.0), children: []),
        //   ),
        // ),
        ),
  );
}
