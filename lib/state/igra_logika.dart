import 'dart:math';

import '../models/igralec.dart';

/// Čista (brez stranskih učinkov) logika za dodelitev vlog.
/// Ločena od Flutterja zaradi enostavnega testiranja.
class IgraLogika {
  const IgraLogika();

  /// Ustvari seznam igralcev in naključno dodeli [steviloImpostorjev] vlog
  /// impostorja. Uporablja [random] za deterministično testiranje.
  static List<Igralec> ustvariIgralce({
    required int steviloIgralcev,
    required int steviloImpostorjev,
    List<String>? imena,
    Random? random,
  }) {
    assert(steviloIgralcev >= 3, 'Potrebni so vsaj 3 igralci.');
    assert(steviloImpostorjev >= 1, 'Potreben je vsaj en impostor.');
    assert(
      steviloImpostorjev < steviloIgralcev,
      'Impostorjev mora biti manj kot vseh igralcev.',
    );

    final rng = random ?? Random();

    // Indeksi igralcev, ki postanejo impostorji.
    final vsiIndeksi = List<int>.generate(steviloIgralcev, (i) => i)
      ..shuffle(rng);
    final impostorIndeksi = vsiIndeksi.take(steviloImpostorjev).toSet();

    return List<Igralec>.generate(steviloIgralcev, (i) {
      final vneseno = (imena != null && i < imena.length)
          ? imena[i].trim()
          : '';
      return Igralec(
        stevilka: i + 1,
        vloga: impostorIndeksi.contains(i) ? Vloga.impostor : Vloga.navadni,
        ime: vneseno.isEmpty ? null : vneseno,
      );
    });
  }

  /// Izbere naključno besedo iz seznama.
  static String izberiBesedo(List<String> besede, {Random? random}) {
    assert(besede.isNotEmpty, 'Seznam besed ne sme biti prazen.');
    final rng = random ?? Random();
    return besede[rng.nextInt(besede.length)];
  }
}
