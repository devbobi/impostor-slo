import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/taboo_repository.dart';
import '../models/taboo_nastavitve.dart';
import '../state/taboo_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/imena_urejevalnik.dart';
import '../widgets/ozadje.dart';

const Color _barvaIgre = Color(0xFF00D0E0);

class TabooKoren extends ConsumerWidget {
  const TabooKoren({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faza = ref.watch(tabooControllerProvider.select((s) => s.faza));

    final Widget zaslon = switch (faza) {
      TabooFaza.nastavitve => const _NastavitveZaslon(),
      TabooFaza.pripravljen => const _PripravljenZaslon(),
      TabooFaza.igra => const _IgraZaslon(),
      TabooFaza.krogKonec => const _KrogKonecZaslon(),
      TabooFaza.konec => const _RezultatZaslon(),
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
    final n = ref.watch(tabooControllerProvider.select((s) => s.nastavitve));
    final controller = ref.read(tabooControllerProvider.notifier);
    final karticeAsync = ref.watch(tabooKarticeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🚫 Prepovedane besede')),
      body: Ozadje(
        child: SafeArea(
          child: karticeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Napaka pri nalaganju kartic:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.nevarnost),
                ),
              ),
            ),
            data: (kartice) => Column(
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
                                '🚫 Kako se igra',
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
                                'Eden drži telefon in opisuje besedo, ostali '
                                'ugibajo. Prepovedanih besed pod njo NE smeš '
                                'izgovoriti — niti sorodnih oblik. Vsaka '
                                'uganjena beseda je točka. Ko čas poteče, je '
                                'na vrsti naslednji.',
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
                        najmanj: 2,
                        najvec: 12,
                        onSpremeni: (v) => controller.posodobiNastavitve(
                          n.kopija(steviloIgralcev: v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Čas na igralca',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.besedilo,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final s in TabooNastavitve.moznCas) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.posodobiNastavitve(
                                  n.kopija(sekundeNaKrog: s),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: n.sekundeNaKrog == s
                                        ? _barvaIgre
                                        : AppTheme.povrsina,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: n.sekundeNaKrog == s
                                          ? _barvaIgre
                                          : AppTheme.povrsinaSvetla,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    '$s s',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: n.sekundeNaKrog == s
                                          ? const Color(0xFF002A2E)
                                          : AppTheme.besedilo,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (s != TabooNastavitve.moznCas.last)
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
                    onPressed: () => controller.zacni(kartice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _barvaIgre,
                      foregroundColor: const Color(0xFF002A2E),
                    ),
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

class _PripravljenZaslon extends ConsumerWidget {
  const _PripravljenZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(tabooControllerProvider);
    final controller = ref.read(tabooControllerProvider.notifier);
    final barva = AppTheme.barvaIgralca(stanje.trenutniIgralec);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const Text('🚫', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                const Text(
                  'Opisuje',
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 6),
                Text(
                  stanje.trenutnoIme,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: barva,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vzemi telefon v roke, da ga vidiš samo ti.\n'
                  'Ostali ugibajo. Imaš ${stanje.nastavitve.sekundeNaKrog} s.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.besediloTiho,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: controller.zacniKrog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: barva,
                    minimumSize: const Size.fromHeight(72),
                  ),
                  child: const Text('START'),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IgraZaslon extends ConsumerStatefulWidget {
  const _IgraZaslon();

  @override
  ConsumerState<_IgraZaslon> createState() => _IgraZaslonState();
}

class _IgraZaslonState extends ConsumerState<_IgraZaslon> {
  Timer? _timer;
  late int _preostalo;

  @override
  void initState() {
    super.initState();
    _preostalo = ref.read(tabooControllerProvider).nastavitve.sekundeNaKrog;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_preostalo <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        ref.read(tabooControllerProvider.notifier).koncajKrog();
      } else {
        setState(() => _preostalo--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(tabooControllerProvider);
    final controller = ref.read(tabooControllerProvider.notifier);
    final kartica = stanje.trenutnaKartica;
    final malo = _preostalo <= 10;

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✅ ${stanje.uganjeneVKrogu}',
                      style: const TextStyle(
                        color: AppTheme.uspeh,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$_preostalo s',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: malo ? AppTheme.nevarnost : AppTheme.besedilo,
                      ),
                    ),
                    Text(
                      '⏭ ${stanje.preskoceneVKrogu}',
                      style: const TextStyle(
                        color: AppTheme.besediloTiho,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Kartica z besedo in prepovedanimi besedami.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.povrsina,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _barvaIgre, width: 2.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        kartica?.beseda ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.besedilo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.povrsinaSvetla),
                      const SizedBox(height: 10),
                      const Text(
                        'NE SMEŠ REČI',
                        style: TextStyle(
                          color: AppTheme.nevarnost,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final p in kartica?.prepovedane ?? const <String>[])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            p,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.besediloTiho,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          controller.preskoci();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(64),
                          foregroundColor: AppTheme.besediloTiho,
                          side: const BorderSide(
                            color: AppTheme.povrsinaSvetla,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'PRESKOČI ⏭',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.uganili();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.uspeh,
                          foregroundColor: const Color(0xFF00281B),
                          minimumSize: const Size.fromHeight(64),
                        ),
                        child: const Text('UGANILI ✅'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KrogKonecZaslon extends ConsumerWidget {
  const _KrogKonecZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(tabooControllerProvider);
    final controller = ref.read(tabooControllerProvider.notifier);
    final barva = AppTheme.barvaIgralca(stanje.trenutniIgralec);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const Text('⏰', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                Text(
                  'Čas je potekel!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.opozorilo,
                      ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.povrsina,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: barva, width: 2.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stanje.trenutnoIme,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: barva,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+${stanje.uganjeneVKrogu}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.uspeh,
                        ),
                      ),
                      Text(
                        stanje.uganjeneVKrogu == 1 ? 'uganjena' : 'uganjenih',
                        style: const TextStyle(color: AppTheme.besediloTiho),
                      ),
                      if (stanje.preskoceneVKrogu > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '(${stanje.preskoceneVKrogu} preskočenih)',
                          style: const TextStyle(
                            color: AppTheme.besediloTiho,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: controller.naslednjiIgralec,
                  style: ElevatedButton.styleFrom(backgroundColor: _barvaIgre),
                  child: Text(
                    stanje.jeZadnjiIgralec
                        ? 'KONČNA LESTVICA 🏆'
                        : 'NASLEDNJI IGRALEC',
                  ),
                ),
                const SizedBox(height: 28),
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
    final stanje = ref.watch(tabooControllerProvider);
    final controller = ref.read(tabooControllerProvider.notifier);
    final kartice = ref.watch(tabooKarticeProvider).valueOrNull ?? const [];
    final n = stanje.nastavitve;

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
                      kartice.isEmpty ? null : () => controller.ponovi(kartice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _barvaIgre,
                    foregroundColor: const Color(0xFF002A2E),
                  ),
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

class _Stevec extends StatelessWidget {
  const _Stevec({
    required this.naslov,
    required this.vrednost,
    required this.najmanj,
    required this.najvec,
    required this.onSpremeni,
  });

  final String naslov;
  final int vrednost;
  final int najmanj;
  final int najvec;
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
              omogocen: vrednost > najmanj,
              onTap: () => onSpremeni(vrednost - 1),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$vrednost',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _barvaIgre,
                ),
              ),
            ),
            _Krog(
              ikona: Icons.add,
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
    required this.omogocen,
    required this.onTap,
  });

  final IconData ikona;
  final bool omogocen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: omogocen ? _barvaIgre : AppTheme.povrsinaSvetla,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: omogocen ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            ikona,
            color: omogocen
                ? const Color(0xFF002A2E)
                : AppTheme.besediloTiho,
          ),
        ),
      ),
    );
  }
}
