import 'package:flutter/material.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'flavors Dev',
    flavorName: 'development',
    baseUrl: 'http://192.168.1.8:8000',
    apiUrl: '/api',
    child: MyApp(),
  );

  //SystemChrome.setEnabledSystemUIOverlays([]);
  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
