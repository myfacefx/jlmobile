import 'package:flutter/material.dart';
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
      // shape: StadiumBorder(side: BorderSide),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
      color: Colors.white,
      onPressed: () {
        if (route == '/share') {
          globals.share();
        } else {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        }
      },
      child: SizedBox(
          width: double.infinity,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Text(title,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor))),
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
                        : Container()
                  ]))),
    ),
  );
}

Widget _buildDrawerNavigationButtonSmall(String title, String route, context) {
  return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 60, 0),
      height: 35,
      child: OutlineButton(
        padding: EdgeInsets.only(left: 8),
        borderSide: BorderSide(color: Colors.white),
        highlightColor: Colors.white10,
        highlightedBorderColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        onPressed: () {
          if (route == "/logout") {
            deleteLocalData("user");
            globals.state = "login";
            Navigator.of(context).pop();
            Navigator.pushNamed(context, "/login");
          } else {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          }
        },
        child: SizedBox(
            width: double.infinity,
            child: Text(title, style: TextStyle(color: Colors.white))),
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
                GestureDetector(
                  onTap: () => globals.share(),
                  child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: Icon(Icons.share, color: Colors.white)),
                ),
                // Avatar
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
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
                          child: Text("Profil",
                              style: Theme.of(context).textTheme.display4),
                        ))),
                globals.spacePadding(),
                _buildDrawerNavigationButtonBig(
                    "Daftar Lelang", '/', null, context),
                _buildDrawerNavigationButtonBig(
                    "Lelangku", '/profile', null, context),
                // _buildDrawerNavigationButtonBig("Our Shop Products", context),
                _buildDrawerNavigationButtonBig("Lelang Diikuti", '/our-bid',
                    globals.user != null ? globals.user.bidsCount : 0, context),
                _buildDrawerNavigationButtonBig(
                    "Bagikan JLF", '/share', null, context),
                // _buildDrawerNavigationButtonBig("Our Carts", context),
                // _buildDrawerNavigationButtonBig("Notification", '/notification', context),
                globals.spacePadding(),
                _buildDrawerNavigationButtonSmall("RekBer", "/rekber", context),
                _buildDrawerNavigationButtonSmall("Tentang JLF", "/about", context),
                _buildDrawerNavigationButtonSmall("Langkah - Langkah", "/how-to", context),
                _buildDrawerNavigationButtonSmall("Tanya Jawab", "/faq", context),
                _buildDrawerNavigationButtonSmall(
                    "Pengaturan", "/setting", context),
                _buildDrawerNavigationButtonSmall(
                    "Keluar", "/logout", context),
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
