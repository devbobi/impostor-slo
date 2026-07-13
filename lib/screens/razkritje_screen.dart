import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/igralec.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class RazkritjeScreen extends ConsumerStatefulWidget {
  const RazkritjeScreen({super.key});

  @override
  ConsumerState<RazkritjeScreen> createState() => _RazkritjeScreenState();
}

class _RazkritjeScreenState extends ConsumerState<RazkritjeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  bool _razkrito = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _razkrij() {
    setState(() => _razkrito = true);
    _flip.forward();
  }

  void _naprej() {
    _flip.reverse();
    setState(() => _razkrito = false);
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

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Igralec ${igralec.stevilka} od $skupaj',
                  style: const TextStyle(
                    color: AppTheme.besediloTiho,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _razkrito ? null : _razkrij,
                  child: AnimatedBuilder(
                    animation: _flip,
                    builder: (context, _) {
                      final kot = _flip.value * math.pi;
                      final jeHrbet = kot < math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(kot),
                        child: jeHrbet
                            ? _HrbetKarte(stevilka: igralec.stevilka)
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _LiceKarte(
                                  igralec: igralec,
                                  beseda: stanje.skrivnaBeseda ?? '',
                                  kategorijaIme: stanje.kategorija?.ime ?? '',
                                  impostorViDiNamig:
                                      stanje.nastavitve.impostorViDiNamig,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                if (!_razkrito)
                  Text(
                    'Podaj telefon igralcu ${igralec.stevilka}.\nTapni karto, ko si sam.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.besediloTiho,
                      height: 1.4,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _naprej,
                    child: Text(
                      index + 1 >= skupaj
                          ? 'ZAČNI NAMIGOVANJE'
                          : 'SKRIJ IN PODAJ NAPREJ',
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HrbetKarte extends StatelessWidget {
  const _HrbetKarte({required this.stevilka});

  final int stevilka;

  @override
  Widget build(BuildContext context) {
    return _Kartica(
      barva: AppTheme.povrsina,
      obroba: AppTheme.akcent,
      otroci: [
        const Text('🃏', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        Text(
          'Igralec $stevilka',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.besedilo,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tapni za razkritje',
          style: TextStyle(color: AppTheme.besediloTiho),
        ),
      ],
    );
  }
}

class _LiceKarte extends StatelessWidget {
  const _LiceKarte({
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
      return _Kartica(
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

    return _Kartica(
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

class _Kartica extends StatelessWidget {
  const _Kartica({
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
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: barva,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: obroba, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: obroba.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: otroci,
      ),
    );
  }
}
