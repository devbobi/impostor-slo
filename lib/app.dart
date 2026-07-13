import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/igra_controller.dart';
import 'theme/app_theme.dart';
import 'screens/domov_screen.dart';
import 'screens/nastavitve_screen.dart';
import 'screens/razkritje_screen.dart';
import 'screens/namigovanje_screen.dart';
import 'screens/glasovanje_screen.dart';
import 'screens/rezultat_screen.dart';

class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impostor SLO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temna(),
      home: const KorenZaslon(),
    );
  }
}

/// Preklaplja med zasloni glede na trenutno fazo igre.
class KorenZaslon extends ConsumerWidget {
  const KorenZaslon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faza = ref.watch(igraControllerProvider.select((s) => s.faza));

    final Widget zaslon = switch (faza) {
      FazaIgre.nastavitve => const _StartniPreklop(),
      FazaIgre.razkritje => const RazkritjeScreen(),
      FazaIgre.namigovanje => const NamigovanjeScreen(),
      FazaIgre.glasovanje => const GlasovanjeScreen(),
      FazaIgre.rezultat => const RezultatScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: KeyedSubtree(
        key: ValueKey(faza),
        child: zaslon,
      ),
    );
  }
}

/// Med fazo "nastavitve" pokažemo domači zaslon; iz njega se odpre
/// nastavitveni zaslon prek navigacije.
class _StartniPreklop extends StatelessWidget {
  const _StartniPreklop();

  @override
  Widget build(BuildContext context) {
    return const DomovScreen();
  }
}

/// Pomožna funkcija za odpiranje nastavitvenega zaslona.
void odpriNastavitve(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NastavitveScreen()),
  );
}
