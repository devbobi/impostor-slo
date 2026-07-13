import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/besede_repository.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class RezultatScreen extends ConsumerWidget {
  const RezultatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stanje = ref.watch(igraControllerProvider);
    final controller = ref.read(igraControllerProvider.notifier);
    final kategorije = ref.watch(kategorijeProvider).valueOrNull ?? const [];

    final impostorUlovljen = stanje.izid == Izid.impostorUlovljen;
    final izlocen = stanje.izlocenIgralec;
    final impostorji = stanje.igralci.where((i) => i.jeImpostor).toList();

    final (String naslov, String emoji, Color barva) = impostorUlovljen
        ? ('NAVADNI ZMAGAJO!', '🎉', AppTheme.uspeh)
        : ('IMPOSTOR ZMAGA!', '🕵️', AppTheme.nevarnost);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                Text(emoji, style: const TextStyle(fontSize: 76)),
                const SizedBox(height: 12),
                Text(
                  naslov,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: barva,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (izlocen != null)
                          _Vrstica(
                            oznaka: 'Izločen',
                            vrednost: 'Igralec ${izlocen.stevilka}'
                                '${izlocen.jeImpostor ? ' (impostor)' : ' (nedolžen)'}',
                            barva: izlocen.jeImpostor
                                ? AppTheme.uspeh
                                : AppTheme.nevarnost,
                          ),
                        const Divider(height: 24),
                        _Vrstica(
                          oznaka: impostorji.length > 1
                              ? 'Impostorji'
                              : 'Impostor',
                          vrednost: impostorji
                              .map((i) => 'Igralec ${i.stevilka}')
                              .join(', '),
                          barva: AppTheme.nevarnost,
                        ),
                        const SizedBox(height: 12),
                        _Vrstica(
                          oznaka: 'Skrivna beseda',
                          vrednost: stanje.skrivnaBeseda ?? '-',
                          barva: AppTheme.akcent2,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: kategorije.isEmpty
                      ? null
                      : () => controller.ponoviIgro(kategorije),
                  child: const Text('ŠE ENKRAT (iste nastavitve)'),
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
                    'NAZAJ NA ZAČETEK',
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

class _Vrstica extends StatelessWidget {
  const _Vrstica({
    required this.oznaka,
    required this.vrednost,
    required this.barva,
  });

  final String oznaka;
  final String vrednost;
  final Color barva;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          oznaka,
          style: const TextStyle(color: AppTheme.besediloTiho, fontSize: 15),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            vrednost,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: barva,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
