import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teme_repository.dart';
import '../models/bomba_nastavitve.dart';
import '../models/tema.dart';
import '../state/bomba_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/imena_urejevalnik.dart';
import '../widgets/ozadje.dart';

class BombaNastavitveScreen extends ConsumerWidget {
  const BombaNastavitveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nastavitve =
        ref.watch(bombaControllerProvider.select((s) => s.nastavitve));
    final temeAsync = ref.watch(temeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('💣 Bomba')),
      body: Ozadje(
        child: SafeArea(
          child: temeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Napaka pri nalaganju tem:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.nevarnost),
                ),
              ),
            ),
            data: (teme) => _Vsebina(nastavitve: nastavitve, teme: teme),
          ),
        ),
      ),
    );
  }
}

class _Vsebina extends ConsumerWidget {
  const _Vsebina({required this.nastavitve, required this.teme});

  final BombaNastavitve nastavitve;
  final List<Tema> teme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(bombaControllerProvider.notifier);

    return Column(
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
                      Row(
                        children: [
                          const Text('💣', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Text(
                            'Kako se igra',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.opozorilo,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dobite temo. Kdor ima bombo, mora hitro povedati '
                        'besedo na to temo in jo podati naprej. Bomba poči ob '
                        'naključnem času — kdor jo takrat drži, izgubi.',
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
              _Stevec(
                naslov: 'Število igralcev',
                vrednost: nastavitve.steviloIgralcev,
                najmanj: 2,
                najvec: 12,
                onSpremeni: (v) => controller.posodobiNastavitve(
                  nastavitve.kopija(steviloIgralcev: v),
                ),
              ),
              const SizedBox(height: 24),
              const _Naslov('Dolžina bombe'),
              const SizedBox(height: 4),
              const Text(
                'Točen čas je vedno naključen znotraj razpona.',
                style: TextStyle(color: AppTheme.besediloTiho, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final d in BombaDolzina.values) ...[
                    Expanded(
                      child: _DolzinaCip(
                        dolzina: d,
                        izbran: nastavitve.dolzina == d,
                        onTap: () => controller.posodobiNastavitve(
                          nastavitve.kopija(dolzina: d),
                        ),
                      ),
                    ),
                    if (d != BombaDolzina.values.last)
                      const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const _Naslov('Imena igralcev'),
              const SizedBox(height: 4),
              const Text(
                'Neobvezno — prazno polje pomeni »Igralec N«.',
                style: TextStyle(color: AppTheme.besediloTiho, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ImenaUrejevalnik(
                steviloIgralcev: nastavitve.steviloIgralcev,
                imena: nastavitve.imena,
                onSpremeni: (list) => controller.posodobiNastavitve(
                  nastavitve.kopija(imena: list),
                ),
              ),
              const SizedBox(height: 24),
              const _Naslov('Tema'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TemaCip(
                    ime: '🎲 Naključno',
                    izbran: nastavitve.temaId == null,
                    onTap: () => controller.posodobiNastavitve(
                      nastavitve.kopija(pocistiTemo: true),
                    ),
                  ),
                  for (final t in teme)
                    _TemaCip(
                      ime: '${t.emoji} ${t.ime}',
                      izbran: nastavitve.temaId == t.id,
                      onTap: () => controller.posodobiNastavitve(
                        nastavitve.kopija(temaId: t.id),
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
            onPressed: () => controller.zacni(teme),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.opozorilo,
              foregroundColor: const Color(0xFF2A1A00),
            ),
            child: const Text('PRIŽGI BOMBO 💣'),
          ),
        ),
      ],
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

class _DolzinaCip extends StatelessWidget {
  const _DolzinaCip({
    required this.dolzina,
    required this.izbran,
    required this.onTap,
  });

  final BombaDolzina dolzina;
  final bool izbran;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: izbran ? AppTheme.opozorilo : AppTheme.povrsina,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: izbran ? AppTheme.opozorilo : AppTheme.povrsinaSvetla,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              dolzina.ime,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: izbran ? const Color(0xFF2A1A00) : AppTheme.besedilo,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dolzina.opis,
              style: TextStyle(
                fontSize: 12,
                color: izbran
                    ? const Color(0xFF2A1A00)
                    : AppTheme.besediloTiho,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemaCip extends StatelessWidget {
  const _TemaCip({
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
          color: izbran ? AppTheme.opozorilo : AppTheme.povrsina,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: izbran ? AppTheme.opozorilo : AppTheme.povrsinaSvetla,
            width: 1.5,
          ),
        ),
        child: Text(
          ime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: izbran ? const Color(0xFF2A1A00) : AppTheme.besedilo,
          ),
        ),
      ),
    );
  }
}

class _Stevec extends StatelessWidget {
  const _Stevec({
    required this.naslov,
    required this.vrednost,
    required this.najmanj,
    required this.najvec,
    required this.onSpremeni,
  });

  final String naslov;
  final int vrednost;
  final int najmanj;
  final int najvec;
  final ValueChanged<int> onSpremeni;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                naslov,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _Krog(
              ikona: Icons.remove,
              omogocen: vrednost > najmanj,
              onTap: () => onSpremeni(vrednost - 1),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$vrednost',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.opozorilo,
                ),
              ),
            ),
            _Krog(
              ikona: Icons.add,
              omogocen: vrednost < najvec,
              onTap: () => onSpremeni(vrednost + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Krog extends StatelessWidget {
  const _Krog({
    required this.ikona,
    required this.omogocen,
    required this.onTap,
  });

  final IconData ikona;
  final bool omogocen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: omogocen ? AppTheme.opozorilo : AppTheme.povrsinaSvetla,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: omogocen ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            ikona,
            color: omogocen
                ? const Color(0xFF2A1A00)
                : AppTheme.besediloTiho,
          ),
        ),
      ),
    );
  }
}
