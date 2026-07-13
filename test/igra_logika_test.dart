import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_slo/models/igralec.dart';
import 'package:impostor_slo/models/nastavitve_igre.dart';
import 'package:impostor_slo/state/igra_logika.dart';

void main() {
  group('IgraLogika.ustvariIgralce', () {
    test('ustvari pravilno število igralcev', () {
      final igralci = IgraLogika.ustvariIgralce(
        steviloIgralcev: 6,
        steviloImpostorjev: 2,
        random: Random(1),
      );
      expect(igralci.length, 6);
    });

    test('dodeli točno določeno število impostorjev', () {
      final igralci = IgraLogika.ustvariIgralce(
        steviloIgralcev: 8,
        steviloImpostorjev: 2,
        random: Random(42),
      );
      final impostorji = igralci.where((i) => i.jeImpostor).length;
      expect(impostorji, 2);
    });

    test('igralci so oštevilčeni od 1 naprej', () {
      final igralci = IgraLogika.ustvariIgralce(
        steviloIgralcev: 4,
        steviloImpostorjev: 1,
        random: Random(7),
      );
      expect(igralci.map((i) => i.stevilka).toList(), [1, 2, 3, 4]);
    });

    test('vnesena imena se dodelijo, prazna pa uporabijo privzeto', () {
      final igralci = IgraLogika.ustvariIgralce(
        steviloIgralcev: 3,
        steviloImpostorjev: 1,
        imena: const ['Ana', '', 'Bojan'],
        random: Random(7),
      );
      expect(igralci[0].prikazniIme, 'Ana');
      expect(igralci[1].prikazniIme, 'Igralec 2');
      expect(igralci[2].prikazniIme, 'Bojan');
    });

    test('z istim seedom je razporeditev deterministična', () {
      List<Vloga> vloge(int seed) => IgraLogika.ustvariIgralce(
            steviloIgralcev: 6,
            steviloImpostorjev: 2,
            random: Random(seed),
          ).map((i) => i.vloga).toList();

      expect(vloge(123), vloge(123));
    });
  });

  group('IgraLogika.izberiBesedo', () {
    test('vrne besedo iz seznama', () {
      const besede = ['Pica', 'Burek', 'Potica'];
      final beseda = IgraLogika.izberiBesedo(besede, random: Random(3));
      expect(besede.contains(beseda), isTrue);
    });
  });

  group('NastavitveIgre.najvecImpostorjev', () {
    test('pri malo igralcih dovoli le enega', () {
      expect(NastavitveIgre.najvecImpostorjev(3), 1);
      expect(NastavitveIgre.najvecImpostorjev(4), 1);
    });

    test('narašča z več igralci, a ostane omejen', () {
      expect(NastavitveIgre.najvecImpostorjev(6), 2);
      expect(NastavitveIgre.najvecImpostorjev(9), 3);
      expect(NastavitveIgre.najvecImpostorjev(10), 3);
    });
  });
}
