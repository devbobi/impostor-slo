import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/besede_repository.dart';
import '../models/celo_nastavitve.dart';
import '../state/celo_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

const Color _barvaIgre = Color(0xFF9CCC65);

/// Nagib, pri katerem se sproži dejanje, in meja za vrnitev v nevtralni položaj.
const double _pragSprozitve = 6.5;
const double _pragNevtralno = 3.5;

class CeloKoren extends ConsumerStatefulWidget {
  const CeloKoren({super.key});

  @override
  ConsumerState<CeloKoren> createState() => _CeloKorenState();
}

class _CeloKorenState extends ConsumerState<CeloKoren> {
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _nastaviOrientacijo(CeloFaza faza) {
    final lezece = faza == CeloFaza.odstevanje || faza == CeloFaza.igra;
    SystemChrome.setPreferredOrientations(
      lezece
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
  }

  @override
  Widget build(BuildContext context) {
    final faza = ref.watch(celoControllerProvider.select((s) => s.faza));
    ref.listen(
      celoControllerProvider.select((s) => s.faza),
      (_, next) => _nastaviOrientacijo(next),
    );

    final Widget zaslon = switch (faza) {
      CeloFaza.nastavitve => const _NastavitveZaslon(),
      CeloFaza.odstevanje => const _OdstevanjeZaslon(),
      CeloFaza.igra => const _IgraZaslon(),
      CeloFaza.konec => const _RezultatZaslon(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(faza), child: zaslon),
    );
  }
}

class _NastavitveZaslon extends ConsumerWidget {
  const _NastavitveZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(celoControllerProvider.select((s) => s.nastavitve));
    final controller = ref.read(celoControllerProvider.notifier);
    final kategorijeAsync = ref.watch(kategorijeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🙈 Beseda na čelu')),
      body: Ozadje(
        child: SafeArea(
          child: kategorijeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Napaka pri nalaganju besed:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.nevarnost),
                ),
              ),
            ),
            data: (kategorije) => Column(
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
                                '🙈 Kako se igra',
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
                                'Telefon si daš na čelo — besede ne vidiš, '
                                'vidijo pa jo vsi drugi. Oni opisujejo, ti '
                                'ugibaš.\n\n'
                                '⬇️ Ko uganeš — nagni telefon DOL.\n'
                                '⬆️ Če ne veš — nagni GOR za preskok.',
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
                      const _Naslov('Čas'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final s in CeloNastavitve.moznCas) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.posodobiNastavitve(
                                  n.kopija(sekunde: s),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: n.sekunde == s
                                        ? _barvaIgre
                                        : AppTheme.povrsina,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: n.sekunde == s
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
                                      color: n.sekunde == s
                                          ? const Color(0xFF16250A)
                                          : AppTheme.besedilo,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (s != CeloNastavitve.moznCas.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: SwitchListTile(
                          value: n.uporabiNagib,
                          activeThumbColor: _barvaIgre,
                          title: const Text('Nagib telefona'),
                          subtitle: Text(
                            n.uporabiNagib
                                ? 'Nagni dol = pravilno, gor = preskoči'
                                : 'Tapni desno = pravilno, levo = preskoči',
                            style: const TextStyle(
                              color: AppTheme.besediloTiho,
                            ),
                          ),
                          onChanged: (v) => controller.posodobiNastavitve(
                            n.kopija(uporabiNagib: v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _Naslov('Kategorija'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Cip(
                            ime: '🎲 Naključno',
                            izbran: n.kategorijaId == null,
                            onTap: () => controller.posodobiNastavitve(
                              n.kopija(pocistiKategorijo: true),
                            ),
                          ),
                          for (final k in kategorije)
                            _Cip(
                              ime: '${k.emoji} ${k.ime}',
                              izbran: n.kategorijaId == k.id,
                              onTap: () => controller.posodobiNastavitve(
                                n.kopija(kategorijaId: k.id),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: ElevatedButton(
                    onPressed: () => controller.zacni(kategorije),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _barvaIgre,
                      foregroundColor: const Color(0xFF16250A),
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

/// "Daj telefon na čelo" + odštevanje (že v ležečem načinu).
class _OdstevanjeZaslon extends ConsumerStatefulWidget {
  const _OdstevanjeZaslon();

  @override
  ConsumerState<_OdstevanjeZaslon> createState() => _OdstevanjeZaslonState();
}

class _OdstevanjeZaslonState extends ConsumerState<_OdstevanjeZaslon> {
  Timer? _timer;
  int _stevec = 5;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_stevec <= 1) {
        t.cancel();
        HapticFeedback.mediumImpact();
        ref.read(celoControllerProvider.notifier).zacniIgro();
      } else {
        HapticFeedback.selectionClick();
        setState(() => _stevec--);
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
    final kat = ref.watch(celoControllerProvider).kategorija;

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '📱 Daj telefon na čelo!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _barvaIgre,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kategorija: ${kat?.emoji ?? ''} ${kat?.ime ?? ''}',
                  style: const TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_stevec',
                  style: const TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.besedilo,
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

class _IgraZaslon extends ConsumerStatefulWidget {
  const _IgraZaslon();

  @override
  ConsumerState<_IgraZaslon> createState() => _IgraZaslonState();
}

class _IgraZaslonState extends ConsumerState<_IgraZaslon> {
  Timer? _cas;
  Timer? _odzivTimer;
  StreamSubscription<AccelerometerEvent>? _senzor;

  late int _preostalo;

  /// Ali senzor lahko sproži novo dejanje (telefon se je vrnil v nevtralno).
  bool _pripravljen = true;

  /// Kratek povratni prikaz: `true` = pravilno, `false` = preskok.
  bool? _odziv;

  @override
  void initState() {
    super.initState();
    final n = ref.read(celoControllerProvider).nastavitve;
    _preostalo = n.sekunde;

    _cas = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_preostalo <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        ref.read(celoControllerProvider.notifier).koncaj();
      } else {
        setState(() => _preostalo--);
      }
    });

    if (n.uporabiNagib) {
      _senzor = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(_obdelajNagib);
    }
  }

  void _obdelajNagib(AccelerometerEvent e) {
    // Telefon je na čelu (pokončno, ležeč zaslon): z ~ 0.
    // Nagib naprej/dol -> z močno negativen; nagib nazaj/gor -> z pozitiven.
    final z = e.z;
    if (!_pripravljen) {
      if (z.abs() < _pragNevtralno) _pripravljen = true;
      return;
    }
    if (z < -_pragSprozitve) {
      _pripravljen = false;
      _dejanje(true);
    } else if (z > _pragSprozitve) {
      _pripravljen = false;
      _dejanje(false);
    }
  }

  void _dejanje(bool uganjena) {
    final controller = ref.read(celoControllerProvider.notifier);
    if (uganjena) {
      HapticFeedback.mediumImpact();
      controller.uganil();
    } else {
      HapticFeedback.selectionClick();
      controller.preskoci();
    }
    setState(() => _odziv = uganjena);
    _odzivTimer?.cancel();
    _odzivTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _odziv = null);
    });
  }

  @override
  void dispose() {
    _cas?.cancel();
    _odzivTimer?.cancel();
    _senzor?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(celoControllerProvider);
    final naNagib = stanje.nastavitve.uporabiNagib;

    // Med povratnim prikazom se cel zaslon obarva.
    if (_odziv != null) {
      final pravilno = _odziv!;
      return Scaffold(
        backgroundColor:
            pravilno ? AppTheme.uspeh : AppTheme.povrsinaSvetla,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                pravilno ? '✅' : '⏭',
                style: const TextStyle(fontSize: 70),
              ),
              const SizedBox(height: 8),
              Text(
                pravilno ? 'PRAVILNO!' : 'PRESKOK',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: pravilno
                      ? const Color(0xFF00281B)
                      : AppTheme.besedilo,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        // Rezerva, če nagib ne deluje: desna polovica = pravilno, leva = preskok.
        onTapUp: (d) {
          final sredina = MediaQuery.of(context).size.width / 2;
          _dejanje(d.globalPosition.dx > sredina);
        },
        child: Ozadje(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 20,
                  child: Text(
                    '✅ ${stanje.uganjene}',
                    style: const TextStyle(
                      color: AppTheme.uspeh,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 20,
                  child: Text(
                    '$_preostalo s',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: _preostalo <= 10
                          ? AppTheme.nevarnost
                          : AppTheme.besedilo,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FittedBox(
                      child: Text(
                        stanje.trenutnaBeseda ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 76,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.besedilo,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Text(
                    naNagib
                        ? '⬇️ dol = pravilno     ⬆️ gor = preskoči'
                        : '👈 tapni levo = preskoči     tapni desno = pravilno 👉',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.besediloTiho,
                      fontSize: 13,
                    ),
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

class _RezultatZaslon extends ConsumerWidget {
  const _RezultatZaslon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(celoControllerProvider);
    final controller = ref.read(celoControllerProvider.notifier);
    final kategorije = ref.watch(kategorijeProvider).valueOrNull ?? const [];

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('🙈', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(
                  '${stanje.uganjene} ${stanje.uganjene == 1 ? 'uganjena' : 'uganjenih'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.uspeh,
                      ),
                ),
                if (stanje.preskocene > 0)
                  Text(
                    '${stanje.preskocene} preskočenih',
                    style: const TextStyle(color: AppTheme.besediloTiho),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: stanje.rezultati.isEmpty
                      ? const Center(
                          child: Text(
                            'Nobene besede.',
                            style: TextStyle(color: AppTheme.besediloTiho),
                          ),
                        )
                      : ListView.separated(
                          itemCount: stanje.rezultati.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final r = stanje.rezultati[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.povrsina,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: r.uganjena
                                      ? AppTheme.uspeh
                                      : AppTheme.povrsinaSvetla,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(r.uganjena ? '✅' : '⏭'),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      r.beseda,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: r.uganjena
                                            ? AppTheme.besedilo
                                            : AppTheme.besediloTiho,
                                      ),
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
                  onPressed: kategorije.isEmpty
                      ? null
                      : () => controller.ponovi(kategorije),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _barvaIgre,
                    foregroundColor: const Color(0xFF16250A),
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

class _Naslov extends StatelessWidget {
  const _Naslov(this.besedilo);

  final String besedilo;

  @override
  Widget build(BuildContext context) {
    return Text(
      besedilo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.besedilo,
      ),
    );
  }
}

class _Cip extends StatelessWidget {
  const _Cip({
    required this.ime,
    required this.izbran,
    required this.onTap,
  });

  final String ime;
  final bool izbran;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: izbran ? _barvaIgre : AppTheme.povrsina,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: izbran ? _barvaIgre : AppTheme.povrsinaSvetla,
            width: 1.5,
          ),
        ),
        child: Text(
          ime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: izbran ? const Color(0xFF16250A) : AppTheme.besedilo,
          ),
        ),
      ),
    );
  }
}
