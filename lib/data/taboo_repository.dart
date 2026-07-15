import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/taboo_kartica.dart';

/// Nalaga kartice za igro Prepovedane besede.
class TabooRepository {
  const TabooRepository();

  static const String _pot = 'assets/data/taboo.json';

  Future<List<TabooKartica>> naloziKartice() async {
    final surovo = await rootBundle.loadString(_pot);
    final json = jsonDecode(surovo) as Map<String, dynamic>;
    return (json['kartice'] as List<dynamic>)
        .map((e) => TabooKartica.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}

final tabooRepositoryProvider = Provider<TabooRepository>((ref) {
  return const TabooRepository();
});

final tabooKarticeProvider = FutureProvider<List<TabooKartica>>((ref) async {
  return ref.watch(tabooRepositoryProvider).naloziKartice();
});
