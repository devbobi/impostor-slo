import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/bomba_controller.dart';
import 'bomba_igra_screen.dart';
import 'bomba_nastavitve_screen.dart';
import 'bomba_rezultat_screen.dart';

/// Korenski zaslon igre Bomba — preklaplja med fazami.
class BombaKoren extends ConsumerWidget {
  const BombaKoren({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faza = ref.watch(bombaControllerProvider.select((s) => s.faza));

    final Widget zaslon = switch (faza) {
      BombaFaza.nastavitve => const BombaNastavitveScreen(),
      BombaFaza.igra => const BombaIgraScreen(),
      BombaFaza.konec => const BombaRezultatScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(faza), child: zaslon),
    );
  }
}
