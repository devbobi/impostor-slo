import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/igralec.dart';
import '../models/kategorija.dart';
import '../models/nastavitve_igre.dart';
import 'igra_logika.dart';

/// Faze poteka igre.
enum FazaIgre {
  nastavitve,
  razkritje, // pass & play razkrivanje vlog
  namigovanje, // krog namigov (opcijski timer)
  glasovanje, // izbira izločenega igralca
  rezultat, // razkritje zmagovalca
}

/// Kdo je zmagal krog.
enum Izid { impostorUlovljen, impostorPrezivel, nedolocen }

class IgraStanje {
  const IgraStanje({
    required this.faza,
    required this.nastavitve,
    this.kategorija,
    this.skrivnaBeseda,
    this.igralci = const [],
    this.trenutniRazkritIndex = 0,
    this.izlocenIgralec,
    this.izid = Izid.nedolocen,
  });

  final FazaIgre faza;
  final NastavitveIgre nastavitve;
  final Kategorija? kategorija;
  final String? skrivnaBeseda;
  final List<Igralec> igralci;

  /// Kateri igralec je na vrsti med [FazaIgre.razkritje].
  final int trenutniRazkritIndex;

  /// Igralec, ki je bil izglasovan v [FazaIgre.glasovanje].
  final Igralec? izlocenIgralec;
  final Izid izid;

  bool get vsiRazkriti => trenutniRazkritIndex >= igralci.length;

  IgraStanje kopija({
    FazaIgre? faza,
    NastavitveIgre? nastavitve,
    Kategorija? kategorija,
    String? skrivnaBeseda,
    List<Igralec>? igralci,
    int? trenutniRazkritIndex,
    Igralec? izlocenIgralec,
    bool pocistiIzlocenega = false,
    Izid? izid,
  }) {
    return IgraStanje(
      faza: faza ?? this.faza,
      nastavitve: nastavitve ?? this.nastavitve,
      kategorija: kategorija ?? this.kategorija,
      skrivnaBeseda: skrivnaBeseda ?? this.skrivnaBeseda,
      igralci: igralci ?? this.igralci,
      trenutniRazkritIndex: trenutniRazkritIndex ?? this.trenutniRazkritIndex,
      izlocenIgralec:
          pocistiIzlocenega ? null : (izlocenIgralec ?? this.izlocenIgralec),
      izid: izid ?? this.izid,
    );
  }
}

class IgraController extends StateNotifier<IgraStanje> {
  IgraController()
      : super(const IgraStanje(
          faza: FazaIgre.nastavitve,
          nastavitve: NastavitveIgre(),
        ));

  final Random _random = Random();

  void posodobiNastavitve(NastavitveIgre nastavitve) {
    state = state.kopija(nastavitve: nastavitve);
  }

  /// Začne nov krog: izbere kategorijo in besedo ter dodeli vloge.
  void zacniIgro(List<Kategorija> vseKategorije) {
    final nastavitve = state.nastavitve;

    final Kategorija kategorija;
    if (nastavitve.kategorijaId == null) {
      kategorija = vseKategorije[_random.nextInt(vseKategorije.length)];
    } else {
      kategorija = vseKategorije.firstWhere(
        (k) => k.id == nastavitve.kategorijaId,
        orElse: () => vseKategorije[_random.nextInt(vseKategorije.length)],
      );
    }

    final beseda = IgraLogika.izberiBesedo(kategorija.besede, random: _random);
    final igralci = IgraLogika.ustvariIgralce(
      steviloIgralcev: nastavitve.steviloIgralcev,
      steviloImpostorjev: nastavitve.steviloImpostorjev,
      random: _random,
    );

    state = state.kopija(
      faza: FazaIgre.razkritje,
      kategorija: kategorija,
      skrivnaBeseda: beseda,
      igralci: igralci,
      trenutniRazkritIndex: 0,
      pocistiIzlocenega: true,
      izid: Izid.nedolocen,
    );
  }

  /// Naslednji igralec pri pass & play razkrivanju.
  void naslednjeRazkritje() {
    final naslednji = state.trenutniRazkritIndex + 1;
    if (naslednji >= state.igralci.length) {
      state = state.kopija(
        trenutniRazkritIndex: naslednji,
        faza: FazaIgre.namigovanje,
      );
    } else {
      state = state.kopija(trenutniRazkritIndex: naslednji);
    }
  }

  void pojdiNaGlasovanje() {
    state = state.kopija(faza: FazaIgre.glasovanje);
  }

  /// Izloči izbranega igralca in določi izid.
  void izlociIgralca(Igralec igralec) {
    final Izid izid =
        igralec.jeImpostor ? Izid.impostorUlovljen : Izid.impostorPrezivel;
    state = state.kopija(
      faza: FazaIgre.rezultat,
      izlocenIgralec: igralec,
      izid: izid,
    );
  }

  /// Nova igra z istimi nastavitvami (nove vloge in beseda).
  void ponoviIgro(List<Kategorija> vseKategorije) {
    zacniIgro(vseKategorije);
  }

  /// Vrni se na nastavitveni zaslon.
  void ponastavi() {
    state = IgraStanje(
      faza: FazaIgre.nastavitve,
      nastavitve: state.nastavitve,
    );
  }
}

final igraControllerProvider =
    StateNotifierProvider<IgraController, IgraStanje>((ref) {
  return IgraController();
});
