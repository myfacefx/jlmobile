import 'package:flutter/material.dart';
import 'package:jlf_mobile/app_config.dart';
import 'package:jlf_mobile/main.dart';

void main() async {
  var configuredApp = AppConfig(
    appName: 'Jual Lelang Fauna',
    flavorName: 'production',
    baseUrl: 'https://www.tutor.my.id/apilelang/public',
    apiUrl: '/api',
    isProduction: true,
    child: MyApp(),
  );
  // SystemChrome.setEnabledSystemUIOverlays([]);
  await configuredApp.checkLocalData();
  runApp(configuredApp);
}
