import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tema.dart';

/// Nalaga teme za igro Bomba iz lokalnega JSON sredstva.
class TemeRepository {
  const TemeRepository();

  static const String _pot = 'assets/data/teme.json';

  Future<List<Tema>> naloziTeme() async {
    final surovo = await rootBundle.loadString(_pot);
    final Map<String, dynamic> json =
        jsonDecode(surovo) as Map<String, dynamic>;
    return (json['teme'] as List<dynamic>)
        .map((e) => Tema.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final temeRepositoryProvider = Provider<TemeRepository>((ref) {
  return const TemeRepository();
});

final temeProvider = FutureProvider<List<Tema>>((ref) async {
  return ref.watch(temeRepositoryProvider).naloziTeme();
});
