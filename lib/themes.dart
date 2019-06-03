import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';

const kPrimaryColor = const Color.fromRGBO(255, 77, 77, 1); //red pink
const kPrimaryLight = const Color.fromRGBO(255, 98, 98, 1);
const kPrimaryDark = const Color.fromRGBO(186, 39, 75, 1);

ThemeData buildThemeData() {
  final baseTheme = ThemeData.light();
  return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        color: kPrimaryColor,
      ),
      accentColor: kPrimaryColor,
      primaryColor: kPrimaryColor,
      primaryColorDark: kPrimaryDark,
      primaryColorLight: kPrimaryLight,
      scaffoldBackgroundColor: Color.fromRGBO(244, 244, 244, 1),
      splashColor: kPrimaryLight,
      buttonColor: kPrimaryColor,
      //dividerColor: Color.fromRGBO(242, 242, 242, 1),
      textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
          ),
          headline: TextStyle(color: Colors.black, fontSize: 16),
          subtitle: TextStyle(
              color: Colors.black, fontWeight: prefix0.FontWeight.w400),
          display1:
              TextStyle(color: Color.fromRGBO(178, 178, 178, 1), fontSize: 10),
          display2: TextStyle(
              color: Color.fromRGBO(136, 136, 136, 1), fontSize: 10)));
}
