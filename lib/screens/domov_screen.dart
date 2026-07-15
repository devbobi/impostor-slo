import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';
import 'bomba_koren.dart';
import 'najverjetneje_screens.dart';
import 'navodila_screen.dart';
import 'taboo_screens.dart';

class DomovScreen extends StatelessWidget {
  const DomovScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                const SizedBox(height: 24),
                const Text(
                  '🥸',
                  style: TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'VSILJIVEC',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: AppTheme.besedilo,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Družabne igre za en telefon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.akcent2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Izberi igro',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.besediloTiho,
                  ),
                ),
                const SizedBox(height: 12),
                _IgraKartica(
                  emoji: '🕵️',
                  naslov: 'Vsiljivec',
                  opis: 'Vsi poznajo skrivno besedo — razen enega. '
                      'Kdo blefira?',
                  barva: AppTheme.akcent,
                  onTap: () => odpriNastavitve(context),
                ),
                const SizedBox(height: 14),
                _IgraKartica(
                  emoji: '💣',
                  naslov: 'Bomba',
                  opis: 'Naštevaj besede na temo in podaj naprej. '
                      'Kdor drži bombo, ko poči, izgubi.',
                  barva: AppTheme.opozorilo,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const BombaKoren()),
                  ),
                ),
                const SizedBox(height: 14),
                _IgraKartica(
                  emoji: '🤔',
                  naslov: 'Kdo je najbolj verjetno?',
                  opis: 'Trditev, vsi pokažejo na enega. '
                      'Kdor dobi največ prstov, dobi točko.',
                  barva: const Color(0xFF4DA3FF),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NajverjetnejeKoren(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _IgraKartica(
                  emoji: '🚫',
                  naslov: 'Prepovedane besede',
                  opis: 'Opisuj besedo, a brez prepovedanih. '
                      'Ostali ugibajo, čas teče.',
                  barva: const Color(0xFF00D0E0),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const TabooKoren()),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NavodilaScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppTheme.besedilo,
                    side: const BorderSide(color: AppTheme.povrsinaSvetla),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'PRAVILA — VSILJIVEC',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
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

/// Kartica ene igre na domačem zaslonu.
class _IgraKartica extends StatelessWidget {
  const _IgraKartica({
    required this.emoji,
    required this.naslov,
    required this.opis,
    required this.barva,
    required this.onTap,
  });

  final String emoji;
  final String naslov;
  final String opis;
  final Color barva;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(AppTheme.povrsina, barva, 0.28)!,
                AppTheme.povrsina,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: barva, width: 2),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      naslov,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: barva,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opis,
                      style: const TextStyle(
                        color: AppTheme.besediloTiho,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.besediloTiho),
            ],
          ),
        ),
      ),
    );
  }
}
