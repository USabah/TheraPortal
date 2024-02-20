import 'package:flutter/material.dart';
//https://www.htmlcsscolor.com/hex/7C4DFF

class Styles {
  static const Color dark = Color(0xFF0d0036);
  static const Color white = Color(0xFFFCFDFD);
  static const Color grey = Color.fromARGB(255, 65, 67, 70);
  static const Color darkGrey = Color(0xFF333333);
  static const Color orangeYellowish = Color(0xFFFFA500);
  static const Color beige = Color.fromARGB(255, 253, 180, 121);
}

var themeStyle = ThemeData(
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: Styles.darkGrey,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bannerTheme:
        const MaterialBannerThemeData(backgroundColor: Styles.orangeYellowish),
    appBarTheme: const AppBarTheme(backgroundColor: Styles.orangeYellowish),
    fontFamily: 'Kanit',
    inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
      color: Styles.beige,
    )));

const outlineBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(
      50.0,
    ),
  ),
  borderSide: BorderSide.none,
);

const roundedBorder = OutlineInputBorder(
  borderRadius: round,
  borderSide: BorderSide.none,
);

const sent = LinearGradient(
  colors: [Colors.lightBlue, Colors.lightBlueAccent],
);

const received = LinearGradient(
  colors: [Colors.grey, Color.fromARGB(255, 183, 175, 175)],
);

const chatText = TextStyle(
    color: Colors.black87,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto');

const chatConstraints = BoxConstraints(
  maxWidth: 310.0,
);

const round = BorderRadius.all(
  Radius.circular(40),
);

const boxShadow = BoxShadow(
  spreadRadius: 0.0,
  blurRadius: 0.0,
  color: Styles.darkGrey,
  offset: Offset.zero,
);

const placeholder = TextStyle(
  color: Color(0xFF666666),
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

const inputText = TextStyle(
  color: Colors.lightBlue,
  fontSize: 20,
  fontWeight: FontWeight.w500,
  letterSpacing: 1,
);
