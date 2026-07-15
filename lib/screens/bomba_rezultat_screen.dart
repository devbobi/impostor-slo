import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teme_repository.dart';
import '../state/bomba_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class BombaRezultatScreen extends ConsumerWidget {
  const BombaRezultatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(bombaControllerProvider);
    final controller = ref.read(bombaControllerProvider.notifier);
    final teme = ref.watch(temeProvider).valueOrNull ?? const [];
    final barva = AppTheme.barvaIgralca(stanje.porazenecIndex ?? 0);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const Text('💥', style: TextStyle(fontSize: 110)),
                const SizedBox(height: 8),
                Text(
                  'BOOM!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.nevarnost,
                        letterSpacing: 3,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(AppTheme.povrsina, barva, 0.35)!,
                        AppTheme.povrsina,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: barva, width: 2.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Bomba je počila pri',
                        style: TextStyle(color: AppTheme.besediloTiho),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stanje.porazenecIme ?? '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: barva,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tema je bila: ${stanje.tema?.emoji ?? ''} '
                        '${stanje.tema?.ime ?? '-'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.besediloTiho,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      teme.isEmpty ? null : () => controller.ponovi(teme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.opozorilo,
                    foregroundColor: const Color(0xFF2A1A00),
                  ),
                  child: const Text('ŠE ENKRAT 💣'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: controller.ponastavi,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
