import 'package:flutter/material.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/services/user_services.dart';

import 'package:meta/meta.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.appName,
    @required this.flavorName,
    @required this.baseUrl,
    @required this.apiUrl,
    @required Widget child,
  }) : super(child: child);

  final String appName;
  final String flavorName;
  final String baseUrl;
  final String apiUrl;

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  Future<Null> checkLocalData() async {
    globals.baseUrl = baseUrl;
    globals.flavor = flavorName;
    try {
      String userData = await readLocalData("user");
      if (userData != null) {
        User newUser = userFromJson(userData);
        globals.user = newUser;
        globals.state = "home";
      } else {
        globals.state = "login";
      }
    } catch (e) {
      globals.state = "login";
      print("readLocalData(userData) : ${e.toString()}");
    }
  }
}
