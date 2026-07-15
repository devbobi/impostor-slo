import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bomba_nastavitve.dart';
import '../models/tema.dart';

enum BombaFaza { nastavitve, igra, konec }

class BombaStanje {
  const BombaStanje({
    required this.faza,
    required this.nastavitve,
    this.tema,
    this.trajanjeMs = 0,
    this.trenutniIndex = 0,
    this.porazenecIndex,
  });

  final BombaFaza faza;
  final BombaNastavitve nastavitve;
  final Tema? tema;

  /// Naključno izbrano trajanje bombe — igralcem NI prikazano.
  final int trajanjeMs;

  /// Kdo je trenutno na vrsti (drži bombo).
  final int trenutniIndex;

  /// Kdo je držal bombo, ko je počila.
  final int? porazenecIndex;

  String get trenutnoIme => nastavitve.imeZa(trenutniIndex);

  String? get porazenecIme =>
      porazenecIndex == null ? null : nastavitve.imeZa(porazenecIndex!);

  BombaStanje kopija({
    BombaFaza? faza,
    BombaNastavitve? nastavitve,
    Tema? tema,
    int? trajanjeMs,
    int? trenutniIndex,
    int? porazenecIndex,
    bool pocistiPorazenca = false,
  }) {
    return BombaStanje(
      faza: faza ?? this.faza,
      nastavitve: nastavitve ?? this.nastavitve,
      tema: tema ?? this.tema,
      trajanjeMs: trajanjeMs ?? this.trajanjeMs,
      trenutniIndex: trenutniIndex ?? this.trenutniIndex,
      porazenecIndex:
          pocistiPorazenca ? null : (porazenecIndex ?? this.porazenecIndex),
    );
  }
}

class BombaController extends StateNotifier<BombaStanje> {
  BombaController()
      : super(const BombaStanje(
          faza: BombaFaza.nastavitve,
          nastavitve: BombaNastavitve(),
        ));

  final Random _random = Random();

  void posodobiNastavitve(BombaNastavitve n) {
    state = state.kopija(nastavitve: n);
  }

  /// Začne igro: izbere temo, naključno trajanje in naključnega začetnika.
  void zacni(List<Tema> vseTeme) {
    final n = state.nastavitve;

    final Tema tema;
    if (n.temaId == null) {
      tema = vseTeme[_random.nextInt(vseTeme.length)];
    } else {
      tema = vseTeme.firstWhere(
        (t) => t.id == n.temaId,
        orElse: () => vseTeme[_random.nextInt(vseTeme.length)],
      );
    }

    state = state.kopija(
      faza: BombaFaza.igra,
      tema: tema,
      trajanjeMs: nakljucnoTrajanjeMs(n.dolzina, _random),
      trenutniIndex: _random.nextInt(n.steviloIgralcev),
      pocistiPorazenca: true,
    );
  }

  /// Podaj bombo naslednjemu igralcu.
  void podaj() {
    if (state.faza != BombaFaza.igra) return;
    final naslednji =
        (state.trenutniIndex + 1) % state.nastavitve.steviloIgralcev;
    state = state.kopija(trenutniIndex: naslednji);
  }

  /// Bomba je počila — izgubi tisti, ki je trenutno na vrsti.
  void eksplodiraj() {
    if (state.faza != BombaFaza.igra) return;
    state = state.kopija(
      faza: BombaFaza.konec,
      porazenecIndex: state.trenutniIndex,
    );
  }

  /// Nova runda z istimi nastavitvami.
  void ponovi(List<Tema> vseTeme) => zacni(vseTeme);

  /// Nazaj na nastavitve.
  void ponastavi() {
    state = BombaStanje(
      faza: BombaFaza.nastavitve,
      nastavitve: state.nastavitve,
    );
  }
}

/// Naključno trajanje bombe znotraj razpona izbrane dolžine.
/// Ločeno in čisto zaradi testiranja.
int nakljucnoTrajanjeMs(BombaDolzina dolzina, Random random) {
  final razpon = dolzina.maxSek - dolzina.minSek;
  final sekunde = dolzina.minSek + random.nextInt(razpon + 1);
  // Dodatna naključnost v milisekundah, da čas ni "okrogel".
  return sekunde * 1000 + random.nextInt(1000);
}

final bombaControllerProvider =
    StateNotifierProvider<BombaController, BombaStanje>((ref) {
  return BombaController();
});
