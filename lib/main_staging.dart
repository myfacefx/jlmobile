import 'package:flutter/material.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'Build flavors Staging',
    flavorName: 'staging',
    baseUrl: 'https://jlfbackend.xyz/jlf-backend-api/public',
    apiUrl: '/api',
    child: MyApp(),
  );
  //SystemChrome.setEnabledSystemUIOverlays([]);
  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
