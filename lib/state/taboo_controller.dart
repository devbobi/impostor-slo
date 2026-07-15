import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/taboo_kartica.dart';
import '../models/taboo_nastavitve.dart';

enum TabooFaza {
  nastavitve,
  pripravljen, // "Na vrsti je X — tapni START"
  igra, // teče čas, opisuje
  krogKonec, // rezultat kroga
  konec, // končna lestvica
}

class TabooStanje {
  const TabooStanje({
    required this.faza,
    required this.nastavitve,
    this.kartice = const [],
    this.karticaIndex = 0,
    this.trenutniIgralec = 0,
    this.tocke = const [],
    this.uganjeneVKrogu = 0,
    this.preskoceneVKrogu = 0,
  });

  final TabooFaza faza;
  final TabooNastavitve nastavitve;

  /// Premešan kupček kartic za celotno igro.
  final List<TabooKartica> kartice;
  final int karticaIndex;

  /// Kdo trenutno opisuje.
  final int trenutniIgralec;

  /// Točke po igralcih.
  final List<int> tocke;

  final int uganjeneVKrogu;
  final int preskoceneVKrogu;

  TabooKartica? get trenutnaKartica =>
      kartice.isEmpty ? null : kartice[karticaIndex % kartice.length];

  String get trenutnoIme => nastavitve.imeZa(trenutniIgralec);

  bool get jeZadnjiIgralec =>
      trenutniIgralec + 1 >= nastavitve.steviloIgralcev;

  List<int> get zmagovalci {
    if (tocke.isEmpty) return const [];
    final najvec = tocke.reduce(max);
    if (najvec == 0) return const [];
    return [
      for (var i = 0; i < tocke.length; i++)
        if (tocke[i] == najvec) i,
    ];
  }

  TabooStanje kopija({
    TabooFaza? faza,
    TabooNastavitve? nastavitve,
    List<TabooKartica>? kartice,
    int? karticaIndex,
    int? trenutniIgralec,
    List<int>? tocke,
    int? uganjeneVKrogu,
    int? preskoceneVKrogu,
  }) {
    return TabooStanje(
      faza: faza ?? this.faza,
      nastavitve: nastavitve ?? this.nastavitve,
      kartice: kartice ?? this.kartice,
      karticaIndex: karticaIndex ?? this.karticaIndex,
      trenutniIgralec: trenutniIgralec ?? this.trenutniIgralec,
      tocke: tocke ?? this.tocke,
      uganjeneVKrogu: uganjeneVKrogu ?? this.uganjeneVKrogu,
      preskoceneVKrogu: preskoceneVKrogu ?? this.preskoceneVKrogu,
    );
  }
}

class TabooController extends StateNotifier<TabooStanje> {
  TabooController()
      : super(const TabooStanje(
          faza: TabooFaza.nastavitve,
          nastavitve: TabooNastavitve(),
        ));

  final Random _random = Random();

  void posodobiNastavitve(TabooNastavitve n) {
    state = state.kopija(nastavitve: n);
  }

  /// Pripravi igro: premeša kartice, ponastavi točke, prvi igralec na vrsti.
  void zacni(List<TabooKartica> vseKartice) {
    final premesane = [...vseKartice]..shuffle(_random);
    state = state.kopija(
      faza: TabooFaza.pripravljen,
      kartice: premesane,
      karticaIndex: 0,
      trenutniIgralec: 0,
      tocke: List<int>.filled(state.nastavitve.steviloIgralcev, 0),
      uganjeneVKrogu: 0,
      preskoceneVKrogu: 0,
    );
  }

  /// Igralec je pripravljen — začne se odštevanje.
  void zacniKrog() {
    state = state.kopija(
      faza: TabooFaza.igra,
      uganjeneVKrogu: 0,
      preskoceneVKrogu: 0,
    );
  }

  /// Ekipa je uganila besedo (+1 točka opisovalcu).
  void uganili() {
    final nove = [...state.tocke];
    nove[state.trenutniIgralec]++;
    state = state.kopija(
      tocke: nove,
      uganjeneVKrogu: state.uganjeneVKrogu + 1,
      karticaIndex: state.karticaIndex + 1,
    );
  }

  /// Kartico preskočimo (brez točke).
  void preskoci() {
    state = state.kopija(
      preskoceneVKrogu: state.preskoceneVKrogu + 1,
      karticaIndex: state.karticaIndex + 1,
    );
  }

  /// Čas je potekel.
  void koncajKrog() {
    if (state.faza != TabooFaza.igra) return;
    state = state.kopija(faza: TabooFaza.krogKonec);
  }

  /// Naprej na naslednjega igralca ali na končno lestvico.
  void naslednjiIgralec() {
    if (state.jeZadnjiIgralec) {
      state = state.kopija(faza: TabooFaza.konec);
    } else {
      state = state.kopija(
        faza: TabooFaza.pripravljen,
        trenutniIgralec: state.trenutniIgralec + 1,
        uganjeneVKrogu: 0,
        preskoceneVKrogu: 0,
      );
    }
  }

  void ponovi(List<TabooKartica> vseKartice) => zacni(vseKartice);

  void ponastavi() {
    state = TabooStanje(
      faza: TabooFaza.nastavitve,
      nastavitve: state.nastavitve,
    );
  }
}

final tabooControllerProvider =
    StateNotifierProvider<TabooController, TabooStanje>((ref) {
  return TabooController();
});
