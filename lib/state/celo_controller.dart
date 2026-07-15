import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/celo_nastavitve.dart';
import '../models/kategorija.dart';

enum CeloFaza {
  nastavitve,
  odstevanje, // "daj telefon na čelo" + 3-2-1
  igra,
  konec,
}

class CeloStanje {
  const CeloStanje({
    required this.faza,
    required this.nastavitve,
    this.kategorija,
    this.besede = const [],
    this.index = 0,
    this.rezultati = const [],
  });

  final CeloFaza faza;
  final CeloNastavitve nastavitve;
  final Kategorija? kategorija;

  /// Premešane besede za to rundo.
  final List<String> besede;
  final int index;
  final List<CeloRezultat> rezultati;

  String? get trenutnaBeseda => index < besede.length ? besede[index] : null;

  int get uganjene => rezultati.where((r) => r.uganjena).length;
  int get preskocene => rezultati.where((r) => !r.uganjena).length;

  CeloStanje kopija({
    CeloFaza? faza,
    CeloNastavitve? nastavitve,
    Kategorija? kategorija,
    List<String>? besede,
    int? index,
    List<CeloRezultat>? rezultati,
  }) {
    return CeloStanje(
      faza: faza ?? this.faza,
      nastavitve: nastavitve ?? this.nastavitve,
      kategorija: kategorija ?? this.kategorija,
      besede: besede ?? this.besede,
      index: index ?? this.index,
      rezultati: rezultati ?? this.rezultati,
    );
  }
}

class CeloController extends StateNotifier<CeloStanje> {
  CeloController()
      : super(const CeloStanje(
          faza: CeloFaza.nastavitve,
          nastavitve: CeloNastavitve(),
        ));

  final Random _random = Random();

  void posodobiNastavitve(CeloNastavitve n) {
    state = state.kopija(nastavitve: n);
  }

  /// Pripravi rundo: izbere kategorijo in premeša besede.
  void zacni(List<Kategorija> vseKategorije) {
    final n = state.nastavitve;

    final Kategorija kategorija;
    if (n.kategorijaId == null) {
      kategorija = vseKategorije[_random.nextInt(vseKategorije.length)];
    } else {
      kategorija = vseKategorije.firstWhere(
        (k) => k.id == n.kategorijaId,
        orElse: () => vseKategorije[_random.nextInt(vseKategorije.length)],
      );
    }

    state = state.kopija(
      faza: CeloFaza.odstevanje,
      kategorija: kategorija,
      besede: [...kategorija.besede]..shuffle(_random),
      index: 0,
      rezultati: const [],
    );
  }

  /// Odštevanje je končano — beseda se prikaže in čas teče.
  void zacniIgro() {
    state = state.kopija(faza: CeloFaza.igra);
  }

  void uganil() => _zabelezi(true);

  void preskoci() => _zabelezi(false);

  void _zabelezi(bool uganjena) {
    if (state.faza != CeloFaza.igra) return;
    final beseda = state.trenutnaBeseda;
    if (beseda == null) return;

    final novi = [
      ...state.rezultati,
      CeloRezultat(beseda: beseda, uganjena: uganjena),
    ];
    final naslednji = state.index + 1;

    // Če zmanjka besed, se runda konča predčasno.
    if (naslednji >= state.besede.length) {
      state = state.kopija(
        faza: CeloFaza.konec,
        rezultati: novi,
        index: naslednji,
      );
    } else {
      state = state.kopija(rezultati: novi, index: naslednji);
    }
  }

  /// Čas je potekel.
  void koncaj() {
    if (state.faza != CeloFaza.igra) return;
    state = state.kopija(faza: CeloFaza.konec);
  }

  void ponovi(List<Kategorija> vseKategorije) => zacni(vseKategorije);

  void ponastavi() {
    state = CeloStanje(
      faza: CeloFaza.nastavitve,
      nastavitve: state.nastavitve,
    );
  }
}

final celoControllerProvider =
    StateNotifierProvider<CeloController, CeloStanje>((ref) {
  return CeloController();
});
