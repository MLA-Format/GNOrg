import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design-token constants mirroring the GNOrg web color scheme.
abstract class AppColors {
  static const Color lime = Color(0xFFE8F56E);
  static const Color limePale = Color(0xFFF0F8A0);
  static const Color navy = Color(0xFF0A0F2E);
  static const Color cardDark = Color(0xFF1E2130);
  static const Color inputDark = Color(0xFF13151F);
}

/// Global theme applied to the Flutter app.
ThemeData buildAppTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.navy,
      surface: AppColors.cardDark,
    ),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
