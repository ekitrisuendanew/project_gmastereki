import 'package:flutter/material.dart';

class NewColor {

  static final NewColor _instance = NewColor._internal();
  static const _primary = 0xffF66257;

  factory NewColor() {
    return _instance;
  }

  NewColor._internal();

  final ColorSwatch colors = const ColorSwatch(_primary, {
    color1 : Color(0xff5DA9DD),
  });

}

const String color1 = "Color1";