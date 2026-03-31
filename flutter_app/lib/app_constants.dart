import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg       = Color(0xFF0A0C10);
  static const surface  = Color(0xFF111318);
  static const surface2 = Color(0xFF181C24);
  static const border   = Color(0xFF1F2533);
  static const accent   = Color(0xFFE8C547);
  static const accent2  = Color(0xFFF0A500);
  static const teal     = Color(0xFF38D9C0);
  static const pink     = Color(0xFFE85D8A);
  static const textPrimary   = Color(0xFFE8EAF2);
  static const textMuted     = Color(0xFF6B7590);
  static const success       = Color(0xFF4FD18B);
  static const error         = Color(0xFFF05C5C);
}

class AppText {
  static TextStyle heading({double size = 18, Color? color}) =>
      GoogleFonts.syne(fontSize: size, fontWeight: FontWeight.w800,
          color: color ?? AppColors.textPrimary, letterSpacing: -0.5);

  static TextStyle label({double size = 13, Color? color}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: FontWeight.w400,
          color: color ?? AppColors.textPrimary);

  static TextStyle caption({double size = 11, Color? color}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: FontWeight.w300,
          color: color ?? AppColors.textMuted, letterSpacing: 1.0);

  static TextStyle telugu({double size = 16, Color? color}) =>
      TextStyle(fontFamily: 'NotoSansTelugu', fontSize: size,
          fontWeight: FontWeight.w400, color: color ?? AppColors.textPrimary, height: 1.8);
}

class AppLanguages {
  static const List<Map<String, String>> all = [
    {'code': 'auto',      'name': 'Auto-detect',  'bcp': ''},
    {'code': 'telugu',    'name': 'Telugu',        'bcp': 'te-IN'},
    {'code': 'english',   'name': 'English',       'bcp': 'en-US'},
    {'code': 'hindi',     'name': 'Hindi',         'bcp': 'hi-IN'},
    {'code': 'tamil',     'name': 'Tamil',         'bcp': 'ta-IN'},
    {'code': 'kannada',   'name': 'Kannada',       'bcp': 'kn-IN'},
    {'code': 'malayalam', 'name': 'Malayalam',     'bcp': 'ml-IN'},
    {'code': 'marathi',   'name': 'Marathi',       'bcp': 'mr-IN'},
    {'code': 'bengali',   'name': 'Bengali',       'bcp': 'bn-IN'},
    {'code': 'gujarati',  'name': 'Gujarati',      'bcp': 'gu-IN'},
    {'code': 'punjabi',   'name': 'Punjabi',       'bcp': 'pa-IN'},
    {'code': 'odia',      'name': 'Odia',          'bcp': 'or-IN'},
  ];
}

const kAccentGradient = LinearGradient(
  colors: [AppColors.accent, AppColors.accent2],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kTealGradient = LinearGradient(
  colors: [AppColors.teal, Color(0xFF1FAFA0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
