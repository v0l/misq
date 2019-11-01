import 'dart:ui';

import 'package:misq/theme/base.dart';

/// Color names from here: https://www.color-blindness.com/color-name-hue/
///
const White = const Color(0xFFFFFFFF);
const LimeGreen = const Color(0xFF25b135);
const Jaguar = const Color(0xFF29292a);
const VeryLightGrey = const Color(0xFFc9c9c9);
const Mortar = const Color(0xFF5a5a5a);
const Bastille = const Color(0xFF2f2f30);
const PersianRed = const Color(0xFFd73030);
const Green = const Color(0xFF006600);
const BlackRussian = const Color(0xFF1d1d21);
const Gainsboro = const Color(0xFFdadada);

const LimeGreenPair = const ColorPair(LimeGreen, Jaguar);
const JaguarPair = const ColorPair(Jaguar, Gainsboro);
const MortarPair = const ColorPair(Mortar, VeryLightGrey);
const BastillePair = const ColorPair(Bastille, Gainsboro);
const PersianRedPair = const ColorPair(PersianRed, White);
const GreenPair = const ColorPair(Green, White);
const BlackRussianPair = const ColorPair(BlackRussian, Gainsboro);

class DarkTheme extends ThemeType {
  ColorPair get primaryAccent1 => JaguarPair;

  ColorPair get primaryAccent2 => null;

  ColorPair get primary => LimeGreenPair;

  ColorPair get secondaryAccent1 => MortarPair;

  ColorPair get secondaryAccent2 => BlackRussianPair;

  ColorPair get secondary => BastillePair;

  ColorPair get buttonBuy => GreenPair;

  ColorPair get buttonSell => PersianRedPair;
}
