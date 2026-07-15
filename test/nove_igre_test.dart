import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_slo/models/najverjetneje_nastavitve.dart';
import 'package:impostor_slo/models/taboo_nastavitve.dart';
import 'package:impostor_slo/state/najverjetneje_controller.dart';

void main() {
  group('izberiTrditve', () {
    final vse = List<String>.generate(50, (i) => 'trditev $i');

    test('vrne točno toliko trditev, kot je krogov', () {
      expect(izberiTrditve(vse, 10, Random(1)).length, 10);
      expect(izberiTrditve(vse, 20, Random(1)).length, 20);
    });

    test('ne vrne več, kot je na voljo', () {
      expect(izberiTrditve(vse, 999, Random(1)).length, 50);
    });

    test('trditve se v eni igri ne ponavljajo', () {
      final izbrane = izberiTrditve(vse, 20, Random(3));
      expect(izbrane.toSet().length, izbrane.length);
    });

    test('različni seedi dajo različen izbor', () {
      final a = izberiTrditve(vse, 10, Random(1));
      final b = izberiTrditve(vse, 10, Random(2));
      expect(a, isNot(equals(b)));
    });
  });

  group('NajStanje.zmagovalci', () {
    NajStanje stanje(List<int> tocke) => NajStanje(
          faza: NajFaza.konec,
          nastavitve: NajverjetnejeNastavitve(steviloIgralcev: tocke.length),
          tocke: tocke,
        );

    test('vrne enega zmagovalca', () {
      expect(stanje([1, 5, 2]).zmagovalci, [1]);
    });

    test('vrne vse ob izenačenju', () {
      expect(stanje([3, 3, 1]).zmagovalci, [0, 1]);
    });

    test('brez točk ni zmagovalca', () {
      expect(stanje([0, 0, 0]).zmagovalci, isEmpty);
    });
  });

  group('Nastavitve imen', () {
    test('Najverjetneje vrne vneseno ime, sicer privzeto', () {
      const n = NajverjetnejeNastavitve(
        steviloIgralcev: 3,
        imena: ['Ana', '', 'Bojan'],
      );
      expect(n.imeZa(0), 'Ana');
      expect(n.imeZa(1), 'Igralec 2');
      expect(n.imeZa(2), 'Bojan');
    });

    test('Taboo vrne vneseno ime, sicer privzeto', () {
      const n = TabooNastavitve(steviloIgralcev: 2, imena: ['  ', 'Cene']);
      expect(n.imeZa(0), 'Igralec 1');
      expect(n.imeZa(1), 'Cene');
    });
  });
}
