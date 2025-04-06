import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.montserrat().fontFamily,
  colorScheme: ColorScheme.dark( 
    surface: normaliseColor(Color(0xFF1E1E1E)),
    surfaceContainerHighest: Colors.grey[900],
    primary: normaliseColor(Color(0xFF00B7FF)),
    onSurface: Colors.white, 
    onSurfaceVariant: Colors.grey[300]
  ),
);

Color normaliseColor (Color color) {
  return Color.fromARGB(255, color.red, color.green, color.blue);
}
