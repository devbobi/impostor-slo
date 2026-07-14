import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/igralec.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';

/// Višina območja karte v pikslih (za izračun poteka poteg -> pokuk).
const double _kartaVisina = 380;

/// Koliko časa je gumb "naprej" zaklenjen po kliku (prepreči dvojni klik
/// oz. nehoten preskok igralca).
const Duration _zaklepNaprej = Duration(milliseconds: 750);

class RazkritjeScreen extends ConsumerStatefulWidget {
  const RazkritjeScreen({super.key});

  @override
  ConsumerState<RazkritjeScreen> createState() => _RazkritjeScreenState();
}

class _RazkritjeScreenState extends ConsumerState<RazkritjeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snap;
  Animation<double>? _snapAnim;
  Timer? _zaklepTimer;

  /// 0.0 = popolnoma zakrito, 1.0 = popolnoma razkrito.
  double _pokuk = 0;

  /// Ali je igralec vsaj enkrat pokukal (za namig na gumbu).
  bool _videl = false;

  /// Gumb "naprej" je začasno zaklenjen (proti dvojnemu kliku).
  bool _zaklenjen = false;

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
    _zaklepTimer?.cancel();
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
    _snapAnim = Tween<double>(begin: _pokuk, end: 0).animate(
      CurvedAnimation(parent: _snap, curve: Curves.easeOut),
    );
    _snap.forward(from: 0);
  }

  void _naprej() {
    if (_zaklenjen) return;
    // Močan haptični pulz kot jasen signal, da se je zamenjal igralec.
    HapticFeedback.mediumImpact();
    setState(() {
      _pokuk = 0;
      _videl = false;
      _zaklenjen = true;
    });
    ref.read(igraControllerProvider.notifier).naslednjeRazkritje();
    _zaklepTimer?.cancel();
    _zaklepTimer = Timer(_zaklepNaprej, () {
      if (mounted) setState(() => _zaklenjen = false);
    });
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
    final barva = AppTheme.barvaIgralca(index);

    return Scaffold(
      // Ozadje se animirano obarva v barvo trenutnega igralca -> ob prehodu
      // je takoj vidno, da je na vrsti nekdo drug.
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(AppTheme.ozadje, barva, 0.30)!,
              AppTheme.ozadje,
              Color.lerp(AppTheme.ozadje, barva, 0.16)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Napredek: pika za vsakega igralca, trenutni poudarjen.
                _Napredek(skupaj: skupaj, trenutni: index, barva: barva),
                const SizedBox(height: 14),
                const Text(
                  'Na vrsti je',
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 6),
                // Ime v barvi igralca — velik, jasen indikator menjave.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Text(
                    igralec.prikazniIme,
                    key: ValueKey(index),
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: barva,
                            ),
                  ),
                ),
                const Spacer(),
                _PokukKarta(
                  pokuk: _pokuk,
                  barva: barva,
                  index: index,
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
                  onPressed: _zaklenjen ? null : _naprej,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: barva,
                    disabledBackgroundColor: AppTheme.povrsinaSvetla,
                    foregroundColor: Colors.white,
                  ),
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

/// Vrstica pik, ki kaže napredek skozi igralce.
class _Napredek extends StatelessWidget {
  const _Napredek({
    required this.skupaj,
    required this.trenutni,
    required this.barva,
  });

  final int skupaj;
  final int trenutni;
  final Color barva;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < skupaj; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == trenutni ? 26 : 9,
            height: 9,
            decoration: BoxDecoration(
              color: i == trenutni
                  ? barva
                  : (i < trenutni
                      ? AppTheme.besediloTiho
                      : AppTheme.povrsinaSvetla),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}

/// Karta, ki jo z drsom navzgor "dvigneš", da pokukaš pod pokrov.
/// Ob spustu se pokrov vrne in vsebino skrije.
class _PokukKarta extends StatelessWidget {
  const _PokukKarta({
    required this.pokuk,
    required this.barva,
    required this.index,
    required this.igralec,
    required this.beseda,
    required this.kategorijaIme,
    required this.impostorViDiNamig,
    required this.onPoteg,
    required this.onSpusti,
  });

  final double pokuk;
  final Color barva;
  final int index;
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
              Positioned.fill(
                child: _Vsebina(
                  igralec: igralec,
                  beseda: beseda,
                  kategorijaIme: kategorijaIme,
                  impostorViDiNamig: impostorViDiNamig,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -pokuk * _kartaVisina,
                height: _kartaVisina,
                child: _Pokrov(
                  ime: igralec.prikazniIme,
                  stevilka: igralec.stevilka,
                  barva: barva,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pokrov extends StatelessWidget {
  const _Pokrov({
    required this.ime,
    required this.stevilka,
    required this.barva,
  });

  final String ime;
  final int stevilka;
  final Color barva;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppTheme.povrsina, barva, 0.30)!,
            AppTheme.povrsina,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: barva, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.keyboard_double_arrow_up,
              size: 40, color: Colors.white),
          const SizedBox(height: 10),
          // Velik barvni krog s številko igralca.
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: barva,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: barva.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '$stevilka',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ime,
            textAlign: TextAlign.center,
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
