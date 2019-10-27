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
    @required this.isProduction,
    @required Widget child,
  }) : super(child: child);

  final String appName;
  final String flavorName;
  final String baseUrl;
  final String apiUrl;
  final bool isProduction;

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  Future<Null> checkLocalData() async {
    globals.debugPrint("Checking local storage");
    globals.baseUrl = baseUrl;
    globals.flavor = flavorName;
    globals.isProduction = isProduction;

    String firstInstall = await readLocalData("isNew");
    if (firstInstall != null) {
      String userData = await readLocalData("user");
      if (userData != null) {
        User newUser = userFromJson(userData);
        globals.debugPrint("User Found = ${newUser.username}");

        globals.debugPrint("verify token");
        try {
          final resVerify = await verifyToken(newUser.tokenRedis);
          if (resVerify != null) {
            globals.debugPrint("verifed token");
            globals.debugPrint(resVerify.tokenRedis);
            globals.user = resVerify;

            globals.state = 'home';

            if (globals.user != null) {
              if (globals.user.verificationStatus == null)
                globals.state = 'verification';
              if (globals.user.verificationStatus == 'denied')
                globals.state = 'verification';
            }
          } else {
            globals.debugPrint("token not found");
            deleteLocalData("user");
            globals.state = "login";
          }
        } catch (e) {
          globals.state = 'home';
        }
      } else {
        globals.state = "login";
      }
    } else {
      globals.state = "intro";
    }
  }
}
