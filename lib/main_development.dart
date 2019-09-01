import 'package:flutter/material.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'flavors Dev',
    flavorName: 'development',
    baseUrl: 'http://45.32.99.93/~jlfbacke/jlf-backend-api/public',
    apiUrl: '/api',
    child: MyApp(),
  );

  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
