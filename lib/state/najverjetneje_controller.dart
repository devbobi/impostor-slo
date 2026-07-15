import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/najverjetneje_nastavitve.dart';

enum NajFaza { nastavitve, igra, konec }

class NajStanje {
  const NajStanje({
    required this.faza,
    required this.nastavitve,
    this.trditve = const [],
    this.krogIndex = 0,
    this.tocke = const [],
  });

  final NajFaza faza;
  final NajverjetnejeNastavitve nastavitve;

  /// Premešane trditve za to igro (dolžina = število krogov).
  final List<String> trditve;
  final int krogIndex;

  /// Točke po igralcih (indeks = igralec).
  final List<int> tocke;

  String? get trenutnaTrditev =>
      krogIndex < trditve.length ? trditve[krogIndex] : null;

  /// Indeksi igralcev z največ točkami (lahko je izenačenje).
  List<int> get zmagovalci {
    if (tocke.isEmpty) return const [];
    final najvec = tocke.reduce(max);
    if (najvec == 0) return const [];
    return [
      for (var i = 0; i < tocke.length; i++)
        if (tocke[i] == najvec) i,
    ];
  }

  NajStanje kopija({
    NajFaza? faza,
    NajverjetnejeNastavitve? nastavitve,
    List<String>? trditve,
    int? krogIndex,
    List<int>? tocke,
  }) {
    return NajStanje(
      faza: faza ?? this.faza,
      nastavitve: nastavitve ?? this.nastavitve,
      trditve: trditve ?? this.trditve,
      krogIndex: krogIndex ?? this.krogIndex,
      tocke: tocke ?? this.tocke,
    );
  }
}

class NajController extends StateNotifier<NajStanje> {
  NajController()
      : super(const NajStanje(
          faza: NajFaza.nastavitve,
          nastavitve: NajverjetnejeNastavitve(),
        ));

  final Random _random = Random();

  void posodobiNastavitve(NajverjetnejeNastavitve n) {
    state = state.kopija(nastavitve: n);
  }

  void zacni(List<String> vseTrditve) {
    final n = state.nastavitve;
    final izbrane = izberiTrditve(vseTrditve, n.steviloKrogov, _random);
    state = state.kopija(
      faza: NajFaza.igra,
      trditve: izbrane,
      krogIndex: 0,
      tocke: List<int>.filled(n.steviloIgralcev, 0),
    );
  }

  /// Igralec [i] je dobil največ glasov v tem krogu.
  void glasujZa(int i) {
    final nove = [...state.tocke];
    if (i >= 0 && i < nove.length) nove[i]++;
    _naprej(nove);
  }

  /// Krog se preskoči brez točke.
  void preskoci() => _naprej(state.tocke);

  void _naprej(List<int> tocke) {
    final naslednji = state.krogIndex + 1;
    if (naslednji >= state.trditve.length) {
      state = state.kopija(faza: NajFaza.konec, tocke: tocke, krogIndex: naslednji);
    } else {
      state = state.kopija(krogIndex: naslednji, tocke: tocke);
    }
  }

  void ponovi(List<String> vseTrditve) => zacni(vseTrditve);

  void ponastavi() {
    state = NajStanje(
      faza: NajFaza.nastavitve,
      nastavitve: state.nastavitve,
    );
  }
}

/// Premeša in vzame [koliko] trditev. Ločeno zaradi testiranja.
List<String> izberiTrditve(List<String> vse, int koliko, Random random) {
  final kopija = [...vse]..shuffle(random);
  return kopija.take(koliko.clamp(1, kopija.length)).toList(growable: false);
}

final najControllerProvider =
    StateNotifierProvider<NajController, NajStanje>((ref) {
  return NajController();
});
