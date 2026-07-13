import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kategorija.dart';

/// Nalaga kategorije besed iz lokalnega JSON sredstva.
class BesedeRepository {
  const BesedeRepository();

  static const String _pot = 'assets/data/besede.json';

  Future<List<Kategorija>> naloziKategorije() async {
    final surovo = await rootBundle.loadString(_pot);
    final Map<String, dynamic> json =
        jsonDecode(surovo) as Map<String, dynamic>;
    final seznam = (json['kategorije'] as List<dynamic>)
        .map((e) => Kategorija.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return seznam;
  }
}

final besedeRepositoryProvider = Provider<BesedeRepository>((ref) {
  return const BesedeRepository();
});

/// Asinhrono naložene kategorije, na voljo celotni aplikaciji.
final kategorijeProvider = FutureProvider<List<Kategorija>>((ref) async {
  final repo = ref.watch(besedeRepositoryProvider);
  return repo.naloziKategorije();
});
