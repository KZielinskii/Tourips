import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'themes.dart';

class _CustomTheme extends InheritedWidget {
  final CustomThemeState data;

  const _CustomTheme({
    required this.data,
    required Key? super.key,
    required super.child,
  });

  @override
  bool updateShouldNotify(_CustomTheme oldWidget) {
    return true;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final MyThemeKeys initialThemeKey;

  const CustomTheme({
    required Key key,
    required this.initialThemeKey,
    required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => CustomThemeState();

  static ThemeData of(BuildContext context) {
    _CustomTheme? inherited =
    context.dependOnInheritedWidgetOfExactType<_CustomTheme>();
    return inherited?.data.theme ?? MyThemes.lightTheme;
  }

  static CustomThemeState instanceOf(BuildContext context) {
    _CustomTheme? inherited =
    context.dependOnInheritedWidgetOfExactType<_CustomTheme>();
    return inherited?.data ?? CustomThemeState();
  }
}

class CustomThemeState extends State<CustomTheme> {
  late ThemeData _theme;

  ThemeData get theme => _theme;

  @override
  void initState() {
    _theme = MyThemes.getThemeFromKey(widget.initialThemeKey);
    super.initState();
  }

  void changeTheme(MyThemeKeys themeKey) {
    setState(() {
      _theme = MyThemes.getThemeFromKey(themeKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CustomTheme(
      data: this,
      key: null,
      child: widget.child,
    );
  }
}