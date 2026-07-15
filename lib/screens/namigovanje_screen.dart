import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class NamigovanjeScreen extends ConsumerStatefulWidget {
  const NamigovanjeScreen({super.key});

  @override
  ConsumerState<NamigovanjeScreen> createState() => _NamigovanjeScreenState();
}

class _NamigovanjeScreenState extends ConsumerState<NamigovanjeScreen> {
  Timer? _timer;
  int _preostalo = 0;
  bool _tece = false;

  @override
  void initState() {
    super.initState();
    final nastavitve = ref.read(igraControllerProvider).nastavitve;
    _preostalo = nastavitve.casNamigovanjaSekunde;
    if (nastavitve.uporabiTimer) {
      _zaziniTimer();
    }
  }

  void _zaziniTimer() {
    _tece = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_preostalo <= 1) {
        t.cancel();
        setState(() {
          _preostalo = 0;
          _tece = false;
        });
      } else {
        setState(() => _preostalo--);
      }
    });
  }

  void _preklopiTimer() {
    if (_tece) {
      _timer?.cancel();
      setState(() => _tece = false);
    } else {
      _zaziniTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _cas {
    final m = _preostalo ~/ 60;
    final s = _preostalo % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(igraControllerProvider);
    final uporabiTimer = stanje.nastavitve.uporabiTimer;
    final controller = ref.read(igraControllerProvider.notifier);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'NAMIGOVANJE',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vsak po vrsti pove en namig, povezan s skrivno besedo. '
                  'Nato se pogovorite in ugotovite, kdo blefira.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.besediloTiho, height: 1.4),
                ),
                const SizedBox(height: 20),
                if (stanje.zacetnik != null)
                  _ZacetnikKartica(
                    ime: stanje.zacetnik!.prikazniIme,
                    barva: AppTheme.barvaIgralca(stanje.zacetnikIndex),
                  ),
                const Spacer(),
                if (uporabiTimer) ...[
                  Text(
                    _cas,
                    style: TextStyle(
                      fontSize: 82,
                      fontWeight: FontWeight.w900,
                      color:
                          _preostalo == 0 ? AppTheme.nevarnost : AppTheme.besedilo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _preostalo == 0 ? null : _preklopiTimer,
                    icon: Icon(_tece ? Icons.pause : Icons.play_arrow),
                    label: Text(_tece ? 'Premor' : 'Nadaljuj'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.besedilo,
                      side: const BorderSide(color: AppTheme.povrsinaSvetla),
                      minimumSize: const Size(160, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ] else
                  const Icon(Icons.forum, size: 90, color: AppTheme.akcent),
                const Spacer(),
                ElevatedButton(
                  onPressed: controller.pojdiNaGlasovanje,
                  child: const Text('NA GLASOVANJE'),
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

/// Poudarjena kartica z naključno izbranim igralcem, ki pove prvo asociacijo.
class _ZacetnikKartica extends StatelessWidget {
  const _ZacetnikKartica({required this.ime, required this.barva});

  final String ime;
  final Color barva;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(AppTheme.povrsina, barva, 0.35)!,
            AppTheme.povrsina,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: barva, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: barva.withValues(alpha: 0.30),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎤 ZAČNE',
            style: TextStyle(
              color: AppTheme.besediloTiho,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ime,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: barva,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'pove prvo asociacijo, nato gre po vrsti naprej',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.besediloTiho, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
