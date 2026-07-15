import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nalaga trditve za igro "Kdo je najbolj verjetno?".
class TrditveRepository {
  const TrditveRepository();

  static const String _pot = 'assets/data/trditve.json';

  Future<List<String>> naloziTrditve() async {
    final surovo = await rootBundle.loadString(_pot);
    final json = jsonDecode(surovo) as Map<String, dynamic>;
    return (json['trditve'] as List<dynamic>)
        .map((e) => e as String)
        .toList(growable: false);
  }
}

final trditveRepositoryProvider = Provider<TrditveRepository>((ref) {
  return const TrditveRepository();
});

final trditveProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(trditveRepositoryProvider).naloziTrditve();
});
