import 'package:flutter/material.dart';

const lighColorScheme = ColorScheme.light(
  primary: Colors.red,
  onPrimary: Colors.black,
  primaryContainer: Colors.white,
  onSecondaryContainer: Colors.white
);

const blackColorScheme = ColorScheme.light(
  brightness: Brightness.dark,
  primary: Colors.red,
  onPrimary: Colors.white,
  primaryContainer: Color.fromARGB(255, 16, 16, 16),
  onSecondaryContainer: Color.fromARGB(255, 28, 27, 27)
);
