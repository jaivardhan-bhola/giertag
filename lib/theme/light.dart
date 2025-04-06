import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightmode = ThemeData(
    fontFamily: GoogleFonts.montserrat().fontFamily,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        surface: Colors.white,
        surfaceContainerHighest: Colors.grey[200],
        primary: normaliseColor(Color(0xFF00B7FF)),
        onSurface: normaliseColor(Color(0xFF1E1E1E)),
        onSurfaceVariant: Colors.grey[400]));

Color normaliseColor(Color color) {
  return Color.fromARGB(255, color.red, color.green, color.blue);
}
