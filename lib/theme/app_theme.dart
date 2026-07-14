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

  /// Živahne, med seboj dobro ločljive barve — vsak igralec dobi svojo,
  /// da je ob prehodu na naslednjega jasno vidno, da se je zaslon spremenil.
  static const List<Color> igralecBarve = [
    Color(0xFF7C4DFF), // vijolična
    Color(0xFFFF4D8D), // roza
    Color(0xFF00E5A0), // zelena
    Color(0xFFFFC24B), // rumena
    Color(0xFF4DA3FF), // modra
    Color(0xFFFF8A3D), // oranžna
    Color(0xFF00D0E0), // cian
    Color(0xFFB388FF), // svetlo vijolična
    Color(0xFF9CCC65), // limeta
    Color(0xFFF06292), // magenta
  ];

  static Color barvaIgralca(int index) =>
      igralecBarve[index % igralecBarve.length];

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
