import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'Build flavors Prod',
    flavorName: 'production',
    baseUrl: 'http://api.juallelangfauna.com',
    apiUrl: '/api',
    child: MyApp(),
  );
  SystemChrome.setEnabledSystemUIOverlays([]);
  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
