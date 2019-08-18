import 'package:flutter/material.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'flavors Dev',
    flavorName: 'development',
    baseUrl: 'http://192.168.1.5:8000',
    apiUrl: '/api',
    child: MyApp(),
  );

  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
