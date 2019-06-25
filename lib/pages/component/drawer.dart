import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:jlf_mobile/globals.dart' as globals;

Widget _buildDrawerNavigationButtonBig(String title, String route, int bidCount, context) {
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
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: SizedBox(
          width: double.infinity,
          child: Container(padding: EdgeInsets.symmetric(horizontal: 8), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            Container(child: Text(title, style: TextStyle(color: Theme.of(context).primaryColor))),
            bidCount != null && bidCount > 0 ? Container(
              constraints: BoxConstraints(
                minWidth: 10,
                minHeight: 10
              ),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(100)
              ),
              child: Text("$bidCount", style: TextStyle(color: Colors.white, fontSize: 10))
            ) : Container()
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
                // Avatar
                Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    height: 150,
                    child: CircleAvatar(
                        radius: 100,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: globals.user.photo != null ? FadeInImage.assetNetwork(
                                image: globals.user.photo,
                                placeholder: 'assets/images/loading.gif',
                                fit: BoxFit.cover) : Image.asset('assets/images/account.png')))),
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
                _buildDrawerNavigationButtonBig("Lelangku", '/profile', null, context),
                // _buildDrawerNavigationButtonBig("Our Shop Products", context),
                _buildDrawerNavigationButtonBig(
                    "Lelang di Ikuti", '/our-bid', globals.user.bidsCount, context),
                // _buildDrawerNavigationButtonBig("Our Carts", context),
                // _buildDrawerNavigationButtonBig("Notification", '/notification', context),
                globals.spacePadding(),
                _buildDrawerNavigationButtonSmall("About", "/about", context),
                _buildDrawerNavigationButtonSmall("How To", "/how-to", context),
                _buildDrawerNavigationButtonSmall("FAQ", "/faq", context),
                _buildDrawerNavigationButtonSmall(
                    "Setting", "/setting", context),
                _buildDrawerNavigationButtonSmall(
                    "Log Out", "/logout", context),
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