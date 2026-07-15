import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_slo/models/bomba_nastavitve.dart';
import 'package:impostor_slo/state/bomba_controller.dart';

void main() {
  group('nakljucnoTrajanjeMs', () {
    test('je vedno znotraj razpona izbrane dolžine', () {
      for (final d in BombaDolzina.values) {
        for (var seed = 0; seed < 50; seed++) {
          final ms = nakljucnoTrajanjeMs(d, Random(seed));
          expect(ms, greaterThanOrEqualTo(d.minSek * 1000));
          expect(ms, lessThan((d.maxSek + 1) * 1000));
        }
      }
    });

    test('ni vedno enako dolgo', () {
      final vrednosti = <int>{};
      for (var seed = 0; seed < 30; seed++) {
        vrednosti.add(nakljucnoTrajanjeMs(BombaDolzina.normalno, Random(seed)));
      }
      expect(vrednosti.length, greaterThan(5));
    });
  });

  group('BombaNastavitve.imeZa', () {
    test('vrne vneseno ime, sicer privzeto', () {
      const n = BombaNastavitve(
        steviloIgralcev: 3,
        imena: ['Ana', '', 'Bojan'],
      );
      expect(n.imeZa(0), 'Ana');
      expect(n.imeZa(1), 'Igralec 2');
      expect(n.imeZa(2), 'Bojan');
    });

    test('vrne privzeto, če imen sploh ni', () {
      const n = BombaNastavitve(steviloIgralcev: 4);
      expect(n.imeZa(2), 'Igralec 3');
    });
  });
}
