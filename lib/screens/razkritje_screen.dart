import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/igralec.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

/// Višina območja karte v pikslih (za izračun poteka poteg -> pokuk).
const double _kartaVisina = 380;

class RazkritjeScreen extends ConsumerStatefulWidget {
  const RazkritjeScreen({super.key});

  @override
  ConsumerState<RazkritjeScreen> createState() => _RazkritjeScreenState();
}

class _RazkritjeScreenState extends ConsumerState<RazkritjeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap;
  Animation<double>? _snapAnim;

  /// 0.0 = popolnoma zakrito, 1.0 = popolnoma razkrito.
  double _pokuk = 0;

  /// Ali je igralec vsaj enkrat pokukal (za namig na gumbu).
  bool _videl = false;

  @override
  void initState() {
    super.initState();
    _snap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..addListener(() {
        if (_snapAnim != null) {
          setState(() => _pokuk = _snapAnim!.value);
        }
      });
  }

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }

  void _posodobiPoteg(double dy) {
    _snap.stop();
    setState(() {
      _pokuk = (_pokuk - dy / _kartaVisina).clamp(0.0, 1.0);
      if (_pokuk > 0.6) _videl = true;
    });
  }

  void _spusti() {
    // Vrni karto v zakrito stanje.
    _snapAnim = Tween<double>(begin: _pokuk, end: 0).animate(
      CurvedAnimation(parent: _snap, curve: Curves.easeOut),
    );
    _snap.forward(from: 0);
  }

  void _naprej() {
    setState(() {
      _pokuk = 0;
      _videl = false;
    });
    ref.read(igraControllerProvider.notifier).naslednjeRazkritje();
  }

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(igraControllerProvider);
    final index = stanje.trenutniRazkritIndex;

    if (index >= stanje.igralci.length) {
      return const SizedBox.shrink();
    }

    final igralec = stanje.igralci[index];
    final skupaj = stanje.igralci.length;
    final zadnji = index + 1 >= skupaj;

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Na vrsti je',
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 4),
                Text(
                  igralec.prikazniIme,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.besedilo,
                      ),
                ),
                Text(
                  '${index + 1} / $skupaj',
                  style: const TextStyle(
                    color: AppTheme.besediloTiho,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                _PokukKarta(
                  pokuk: _pokuk,
                  igralec: igralec,
                  beseda: stanje.skrivnaBeseda ?? '',
                  kategorijaIme: stanje.kategorija?.ime ?? '',
                  impostorViDiNamig: stanje.nastavitve.impostorViDiNamig,
                  onPoteg: _posodobiPoteg,
                  onSpusti: _spusti,
                ),
                const SizedBox(height: 16),
                Text(
                  _videl
                      ? 'Spusti, da skriješ. Ko si pripravljen, podaj naprej.'
                      : '👆 Povleci karto navzgor in poglej svojo vlogo.\nSpusti, da se skrije.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.besediloTiho,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _naprej,
                  child: Text(
                    zadnji ? 'ZAČNI NAMIGOVANJE' : 'PODAJ NASLEDNJEMU',
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

/// Karta, ki jo z drsom navzgor "dvigneš", da pokukaš pod pokrov.
/// Ob spustu se pokrov vrne in vsebino skrije.
class _PokukKarta extends StatelessWidget {
  const _PokukKarta({
    required this.pokuk,
    required this.igralec,
    required this.beseda,
    required this.kategorijaIme,
    required this.impostorViDiNamig,
    required this.onPoteg,
    required this.onSpusti,
  });

  final double pokuk;
  final Igralec igralec;
  final String beseda;
  final String kategorijaIme;
  final bool impostorViDiNamig;
  final ValueChanged<double> onPoteg;
  final VoidCallback onSpusti;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (d) => onPoteg(d.delta.dy),
      onVerticalDragEnd: (_) => onSpusti(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: _kartaVisina,
          width: double.infinity,
          child: Stack(
            children: [
              // Vsebina (vloga / beseda) — vedno spodaj, a skrita pod pokrovom.
              Positioned.fill(
                child: _Vsebina(
                  igralec: igralec,
                  beseda: beseda,
                  kategorijaIme: kategorijaIme,
                  impostorViDiNamig: impostorViDiNamig,
                ),
              ),
              // Pokrov, ki se z drsom dviguje navzgor.
              Positioned(
                left: 0,
                right: 0,
                top: -pokuk * _kartaVisina,
                height: _kartaVisina,
                child: _Pokrov(ime: igralec.prikazniIme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pokrov extends StatelessWidget {
  const _Pokrov({required this.ime});

  final String ime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.povrsinaSvetla, AppTheme.povrsina],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.akcent, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.keyboard_double_arrow_up,
              size: 40, color: AppTheme.akcent),
          const SizedBox(height: 8),
          const Text('🤫', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            ime,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.besedilo,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Povleci navzgor',
            style: TextStyle(color: AppTheme.besediloTiho),
          ),
        ],
      ),
    );
  }
}

class _Vsebina extends StatelessWidget {
  const _Vsebina({
    required this.igralec,
    required this.beseda,
    required this.kategorijaIme,
    required this.impostorViDiNamig,
  });

  final Igralec igralec;
  final String beseda;
  final String kategorijaIme;
  final bool impostorViDiNamig;

  @override
  Widget build(BuildContext context) {
    if (igralec.jeImpostor) {
      return _Okvir(
        barva: const Color(0xFF2A1420),
        obroba: AppTheme.nevarnost,
        otroci: [
          const Text('🕵️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          const Text(
            'TI SI IMPOSTOR',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.nevarnost,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            impostorViDiNamig
                ? 'Kategorija: $kategorijaIme\nNe poznaš besede — blefiraj!'
                : 'Ne poznaš skrivne besede.\nBlefiraj in se ne izdaj!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.besediloTiho, height: 1.4),
          ),
        ],
      );
    }

    return _Okvir(
      barva: const Color(0xFF14261E),
      obroba: AppTheme.uspeh,
      otroci: [
        Text(
          'Kategorija: $kategorijaIme',
          style: const TextStyle(color: AppTheme.besediloTiho),
        ),
        const SizedBox(height: 14),
        const Text(
          'Skrivna beseda',
          style: TextStyle(
            color: AppTheme.uspeh,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          beseda,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppTheme.besedilo,
          ),
        ),
      ],
    );
  }
}

class _Okvir extends StatelessWidget {
  const _Okvir({
    required this.barva,
    required this.obroba,
    required this.otroci,
  });

  final Color barva;
  final Color obroba;
  final List<Widget> otroci;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: barva,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: obroba, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: otroci,
      ),
    );
  }
}
