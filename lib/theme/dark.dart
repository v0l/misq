import 'dart:ui';

import 'package:misq/theme/base.dart';

/// Color names from here: https://www.color-blindness.com/color-name-hue/
///
const LimeGreen = const Color(0xFF25b135);
const Jaguar = const Color(0xFF29292a);
const VeryLightGrey = const Color(0xFFc9c9c9);
const Mortar = const Color(0xFF5a5a5a);

const LimeGreenPari = const ColorPair(LimeGreen, Jaguar);
const JaguarPair = const ColorPair(Jaguar, VeryLightGrey);
const MortarPair = const ColorPair(Mortar, VeryLightGrey);

class DarkTheme extends ThemeType {
  ColorPair get primaryAccent1 => JaguarPair;

  ColorPair get primaryAccent2 => null;

  ColorPair get primary => LimeGreenPari;

  ColorPair get secondaryAccent1 => MortarPair;

  ColorPair get secondaryAccent2 => null;

  ColorPair get secondary => JaguarPair;
}
