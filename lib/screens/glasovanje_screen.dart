import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/igralec.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class GlasovanjeScreen extends ConsumerStatefulWidget {
  const GlasovanjeScreen({super.key});

  @override
  ConsumerState<GlasovanjeScreen> createState() => _GlasovanjeScreenState();
}

class _GlasovanjeScreenState extends ConsumerState<GlasovanjeScreen> {
  Igralec? _izbran;

  @override
  Widget build(BuildContext context) {
    final stanje = ref.watch(igraControllerProvider);
    final controller = ref.read(igraControllerProvider.notifier);

    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'KDO JE IMPOSTOR?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Izberite igralca, ki ga izločite.',
                  style: TextStyle(color: AppTheme.besediloTiho),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: stanje.igralci.length,
                    itemBuilder: (context, i) {
                      final igralec = stanje.igralci[i];
                      final izbran = _izbran?.stevilka == igralec.stevilka;
                      return GestureDetector(
                        onTap: () => setState(() => _izbran = igralec),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            color:
                                izbran ? AppTheme.akcent : AppTheme.povrsina,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: izbran
                                  ? AppTheme.akcent
                                  : AppTheme.povrsinaSvetla,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 34,
                                  color: izbran
                                      ? Colors.white
                                      : AppTheme.besediloTiho,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  igralec.prikazniIme,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: izbran
                                        ? Colors.white
                                        : AppTheme.besedilo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _izbran == null
                      ? null
                      : () => controller.izlociIgralca(_izbran!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _izbran == null
                        ? AppTheme.povrsinaSvetla
                        : AppTheme.akcent,
                  ),
                  child: const Text('POTRDI IZLOČITEV'),
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
