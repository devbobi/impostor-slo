import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trditve_repository.dart';
import '../models/najverjetneje_nastavitve.dart';
import '../state/najverjetneje_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/imena_urejevalnik.dart';
import '../widgets/ozadje.dart';

/// Barva te igre.
const Color _barvaIgre = Color(0xFF4DA3FF);

/// Korenski zaslon — preklaplja med fazami.
class NajverjetnejeKoren extends ConsumerWidget {
  const NajverjetnejeKoren({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faza = ref.watch(najControllerProvider.select((s) => s.faza));

    final Widget zaslon = switch (faza) {
      NajFaza.nastavitve => const _NastavitveZaslon(),
      NajFaza.igra => const _IgraZaslon(),
      NajFaza.konec => const _RezultatZaslon(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(faza), child: zaslon),
    );
  }
}

class _NastavitveZaslon extends ConsumerWidget {
  const _NastavitveZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(najControllerProvider.select((s) => s.nastavitve));
    final controller = ref.read(najControllerProvider.notifier);
    final trditveAsync = ref.watch(trditveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🤔 Kdo je najbolj verjetno?')),
      body: Ozadje(
        child: SafeArea(
          child: trditveAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Napaka pri nalaganju trditev:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.nevarnost),
                ),
              ),
            ),
            data: (trditve) => Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🤔 Kako se igra',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _barvaIgre,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Telefon pokaže trditev. Na tri vsi hkrati '
                                'pokažete na tistega, ki mu najbolj ustreza. '
                                'Kdor dobi največ prstov, dobi točko.',
                                style: TextStyle(
                                  color: AppTheme.besediloTiho,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Stevec(
                        naslov: 'Število igralcev',
                        vrednost: n.steviloIgralcev,
                        najmanj: 3,
                        najvec: 12,
                        barva: _barvaIgre,
                        onSpremeni: (v) => controller.posodobiNastavitve(
                          n.kopija(steviloIgralcev: v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Število krogov',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.besedilo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final k
                              in NajverjetnejeNastavitve.moznaStevilaKrogov) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.posodobiNastavitve(
                                  n.kopija(steviloKrogov: k),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: n.steviloKrogov == k
                                        ? _barvaIgre
                                        : AppTheme.povrsina,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: n.steviloKrogov == k
                                          ? _barvaIgre
                                          : AppTheme.povrsinaSvetla,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    '$k',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: n.steviloKrogov == k
                                          ? Colors.white
                                          : AppTheme.besedilo,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (k != NajverjetnejeNastavitve
                                .moznaStevilaKrogov.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Imena igralcev',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.besedilo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ImenaUrejevalnik(
                        steviloIgralcev: n.steviloIgralcev,
                        imena: n.imena,
                        onSpremeni: (list) => controller.posodobiNastavitve(
                          n.kopija(imena: list),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: ElevatedButton(
                    onPressed: () => controller.zacni(trditve),
                    style: ElevatedButton.styleFrom(backgroundColor: _barvaIgre),
                    child: const Text('ZAČNI'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IgraZaslon extends ConsumerWidget {
  const _IgraZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(najControllerProvider);
    final controller = ref.read(najControllerProvider.notifier);
    final n = stanje.nastavitve;

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Krog ${stanje.krogIndex + 1} / ${stanje.trditve.length}',
                  style: const TextStyle(
                    color: AppTheme.besediloTiho,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Trditev.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(AppTheme.povrsina, _barvaIgre, 0.30)!,
                        AppTheme.povrsina,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _barvaIgre, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'KDO JE NAJBOLJ VERJETNO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.besediloTiho,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${stanje.trenutnaTrditev ?? ''}?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.besedilo,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '👉 Na tri vsi pokažite na enega. Tapnite zmagovalca kroga.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.besediloTiho, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: n.steviloIgralcev,
                    itemBuilder: (context, i) {
                      final barva = AppTheme.barvaIgralca(i);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.glasujZa(i);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.povrsina,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: barva, width: 2),
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                n.imeZa(i),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: barva,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: controller.preskoci,
                  child: const Text(
                    'Preskoči trditev',
                    style: TextStyle(color: AppTheme.besediloTiho),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RezultatZaslon extends ConsumerWidget {
  const _RezultatZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(najControllerProvider);
    final controller = ref.read(najControllerProvider.notifier);
    final trditve = ref.watch(trditveProvider).valueOrNull ?? const [];
    final n = stanje.nastavitve;

    // Igralci, urejeni po točkah (padajoče).
    final vrstniRed = [for (var i = 0; i < n.steviloIgralcev; i++) i]
      ..sort((a, b) => stanje.tocke[b].compareTo(stanje.tocke[a]));
    final zmagovalci = stanje.zmagovalci;

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                Text(
                  zmagovalci.isEmpty
                      ? 'Konec igre'
                      : (zmagovalci.length == 1
                          ? '${n.imeZa(zmagovalci.first)} zmaga!'
                          : 'Izenačeno!'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.opozorilo,
                      ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: vrstniRed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, mesto) {
                      final i = vrstniRed[mesto];
                      final barva = AppTheme.barvaIgralca(i);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.povrsina,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: mesto == 0 ? AppTheme.opozorilo : barva,
                            width: mesto == 0 ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${mesto + 1}.',
                              style: const TextStyle(
                                color: AppTheme.besediloTiho,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                n.imeZa(i),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: barva,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Text(
                              '${stanje.tocke[i]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: AppTheme.besedilo,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      trditve.isEmpty ? null : () => controller.ponovi(trditve),
                  style: ElevatedButton.styleFrom(backgroundColor: _barvaIgre),
                  child: const Text('ŠE ENKRAT'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: controller.ponastavi,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppTheme.besedilo,
                    side: const BorderSide(color: AppTheme.povrsinaSvetla),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'NASTAVITVE',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Preprost števec z + in − (uporabljen v nastavitvah te igre).
class _Stevec extends StatelessWidget {
  const _Stevec({
    required this.naslov,
    required this.vrednost,
    required this.najmanj,
    required this.najvec,
    required this.barva,
    required this.onSpremeni,
  });

  final String naslov;
  final int vrednost;
  final int najmanj;
  final int najvec;
  final Color barva;
  final ValueChanged<int> onSpremeni;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                naslov,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _Krog(
              ikona: Icons.remove,
              barva: barva,
              omogocen: vrednost > najmanj,
              onTap: () => onSpremeni(vrednost - 1),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$vrednost',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: barva,
                ),
              ),
            ),
            _Krog(
              ikona: Icons.add,
              barva: barva,
              omogocen: vrednost < najvec,
              onTap: () => onSpremeni(vrednost + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Krog extends StatelessWidget {
  const _Krog({
    required this.ikona,
    required this.barva,
    required this.omogocen,
    required this.onTap,
  });

  final IconData ikona;
  final Color barva;
  final bool omogocen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: omogocen ? barva : AppTheme.povrsinaSvetla,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: omogocen ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            ikona,
            color: omogocen ? Colors.white : AppTheme.besediloTiho,
          ),
        ),
      ),
    );
  }
}
