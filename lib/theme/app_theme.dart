import 'package:flutter/material.dart';

const maroon = Color(0xFF641225);
const deepMaroon = Color(0xFF3B1C0E);
const cream = Color(0xFFF8F1DF);
const paper = Color(0xFFFFFBEF);
const gold = Color(0xFFD9AD63);

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'serif',
  scaffoldBackgroundColor: cream,
  colorScheme: ColorScheme.fromSeed(
    seedColor: maroon,
    primary: maroon,
    secondary: gold,
    surface: paper,
  ),
);
