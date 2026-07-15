import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/bomba_controller.dart';
import '../theme/app_theme.dart';

class BombaIgraScreen extends ConsumerStatefulWidget {
  const BombaIgraScreen({super.key});

  @override
  ConsumerState<BombaIgraScreen> createState() => _BombaIgraScreenState();
}

class _BombaIgraScreenState extends ConsumerState<BombaIgraScreen>
    with SingleTickerProviderStateMixin {
  Timer? _bomba;
  Timer? _tempo;
  late final AnimationController _utrip;
  late final DateTime _zacetek;
  late final int _trajanjeMs;
  int _stopnja = 0;

  @override
  void initState() {
    super.initState();
    _trajanjeMs = ref.read(bombaControllerProvider).trajanjeMs;
    _zacetek = DateTime.now();

    _utrip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Bomba poči po naključnem času (igralcem ni prikazan).
    _bomba = Timer(Duration(milliseconds: _trajanjeMs), _poci);

    // Utripanje se proti koncu stopnjuje — kot pravo tiktakanje.
    _tempo = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final pretekloMs = DateTime.now().difference(_zacetek).inMilliseconds;
      final delez = pretekloMs / _trajanjeMs;
      final novaStopnja = delez > 0.85 ? 2 : (delez > 0.6 ? 1 : 0);
      if (novaStopnja != _stopnja && mounted) {
        _stopnja = novaStopnja;
        _utrip.duration = Duration(
          milliseconds: switch (novaStopnja) { 2 => 220, 1 => 450, _ => 800 },
        );
        _utrip.repeat(reverse: true);
        HapticFeedback.selectionClick();
      }
    });
  }

  void _poci() {
    HapticFeedback.heavyImpact();
    ref.read(bombaControllerProvider.notifier).eksplodiraj();
  }

  void _podaj() {
    HapticFeedback.lightImpact();
    ref.read(bombaControllerProvider.notifier).podaj();
  }

  @override
  void dispose() {
    _bomba?.cancel();
    _tempo?.cancel();
    _utrip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(bombaControllerProvider);
    final barva = AppTheme.barvaIgralca(stanje.trenutniIndex);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
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
                const SizedBox(height: 12),
                // Tema kroga.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.povrsina,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.opozorilo, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TEMA',
                        style: TextStyle(
                          color: AppTheme.besediloTiho,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${stanje.tema?.emoji ?? ''} ${stanje.tema?.ime ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.opozorilo,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Utripajoča bomba.
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.18).animate(
                    CurvedAnimation(parent: _utrip, curve: Curves.easeInOut),
                  ),
                  child: const Text('💣', style: TextStyle(fontSize: 130)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Na vrsti je',
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Text(
                    stanje.trenutnoIme,
                    key: ValueKey(stanje.trenutniIndex),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: barva,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Povej besedo na temo in podaj naprej!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _podaj,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: barva,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(72),
                  ),
                  child: const Text('PODAJ NAPREJ 💣'),
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
