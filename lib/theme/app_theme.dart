import 'package:flutter/material.dart';

/// Temna, party-friendly tema z živahnimi akcenti.
class AppTheme {
  AppTheme._();

  // Osnovne barve.
  static const Color ozadje = Color(0xFF12101E);
  static const Color povrsina = Color(0xFF1E1B2E);
  static const Color povrsinaSvetla = Color(0xFF2A263F);
  static const Color akcent = Color(0xFF7C4DFF); // vijolična
  static const Color akcent2 = Color(0xFFFF4D8D); // roza
  static const Color uspeh = Color(0xFF00E5A0); // zelena
  static const Color opozorilo = Color(0xFFFFC24B); // rumena
  static const Color nevarnost = Color(0xFFFF5252); // rdeča (impostor)
  static const Color besedilo = Color(0xFFF5F3FF);
  static const Color besediloTiho = Color(0xFFB4AECB);

  static ThemeData temna() {
    final osnova = ThemeData.dark(useMaterial3: true);
    return osnova.copyWith(
      scaffoldBackgroundColor: ozadje,
      colorScheme: const ColorScheme.dark(
        primary: akcent,
        secondary: akcent2,
        surface: povrsina,
        error: nevarnost,
        onPrimary: Colors.white,
        onSurface: besedilo,
      ),
      textTheme: osnova.textTheme.apply(
        bodyColor: besedilo,
        displayColor: besedilo,
        fontFamily: 'Roboto',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: besedilo,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: akcent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: povrsina,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
