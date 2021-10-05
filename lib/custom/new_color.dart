import 'package:flutter/material.dart';

class CustomColor {

  static final CustomColor _instance = CustomColor._internal();
  static final _primary = 0xffF66257;

  factory CustomColor() {
    return _instance;
  }

  CustomColor._internal();

  final ColorSwatch colors = ColorSwatch(_primary, const {
    Color1 : Color(0xff5DA9DD),
  });

}

const String Color1 = "Color1";