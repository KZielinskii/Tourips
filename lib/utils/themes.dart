import 'package:flutter/material.dart';

enum MyThemeKeys { LIGHT, DARK }

class MyThemes {

  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xff2F73B1),
    appBarTheme: const AppBarTheme(color: Color(0xff0b3963),),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.blueGrey,
      cursorColor: Color(0xff0b3963),
      selectionHandleColor: Color(0xff2F73B1),
    ),
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    floatingActionButtonTheme:
    const FloatingActionButtonThemeData (backgroundColor: Colors.blue,focusColor: Colors.blueAccent , splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),

  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.blueGrey,
    brightness: Brightness.dark,
    highlightColor: Colors.white,
    backgroundColor: Colors.black54,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: Colors.blueGrey),
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return lightTheme;
      case MyThemeKeys.DARK:
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}