import 'package:flutter/cupertino.dart';

class ColorPair {
  final Color foreground; //text color usuall
  final Color background;

  const ColorPair(this.background, this.foreground);
}

abstract class ThemeType {
  ColorPair get primary;
  ColorPair get primaryAccent1;
  ColorPair get primaryAccent2;

  ColorPair get secondary;
  ColorPair get secondaryAccent1;
  ColorPair get secondaryAccent2;

  ColorPair get buttonBuy;
  ColorPair get buttonSell;
}

class Theme<T extends ThemeType> extends InheritedWidget {
  final ThemeType theme;

  Theme(this.theme, Widget child) : super(child: child);

  static ThemeType of(BuildContext ctx) {
    return (ctx.inheritFromWidgetOfExactType(Theme) as Theme).theme;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
