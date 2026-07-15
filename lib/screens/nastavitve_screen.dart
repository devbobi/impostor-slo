import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/besede_repository.dart';
import '../models/kategorija.dart';
import '../models/nastavitve_igre.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/imena_urejevalnik.dart';
import '../widgets/ozadje.dart';

class NastavitveScreen extends ConsumerWidget {
  const NastavitveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nastavitve = ref.watch(
      igraControllerProvider.select((s) => s.nastavitve),
    );
    final kategorijeAsync = ref.watch(kategorijeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavitve igre')),
      body: Ozadje(
        child: SafeArea(
          child: kategorijeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Napaka pri nalaganju besed:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.nevarnost),
                ),
              ),
            ),
            data: (kategorije) => _Vsebina(
              nastavitve: nastavitve,
              kategorije: kategorije,
            ),
          ),
        ),
      ),
    );
  }
}

class _Vsebina extends ConsumerWidget {
  const _Vsebina({required this.nastavitve, required this.kategorije});

  final NastavitveIgre nastavitve;
  final List<Kategorija> kategorije;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(igraControllerProvider.notifier);
    final najvecImp =
        NastavitveIgre.najvecImpostorjev(nastavitve.steviloIgralcev);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Stepper(
                naslov: 'Ĺ tevilo igralcev',
                vrednost: nastavitve.steviloIgralcev,
                najmanj: 3,
                najvec: 10,
                onSpremeni: (v) {
                  final novMax = NastavitveIgre.najvecImpostorjev(v);
                  controller.posodobiNastavitve(nastavitve.kopija(
                    steviloIgralcev: v,
                    steviloImpostorjev:
                        nastavitve.steviloImpostorjev.clamp(1, novMax),
                  ));
                },
              ),
              const SizedBox(height: 16),
              _Stepper(
                naslov: 'Ĺ tevilo impostorjev',
                vrednost: nastavitve.steviloImpostorjev,
                najmanj: 1,
                najvec: najvecImp,
                onSpremeni: (v) {
                  controller.posodobiNastavitve(
                    nastavitve.kopija(steviloImpostorjev: v),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Imena igralcev',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.besedilo,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Neobvezno â€” prazno polje pomeni Â»Igralec NÂ«.',
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
              const Text(
                'Kategorija',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.besedilo,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _KategorijaCip(
                    ime: 'đźŽ˛ NakljuÄŤno',
                    izbran: nastavitve.kategorijaId == null,
                    onTap: () => controller.posodobiNastavitve(
                      nastavitve.kopija(pocistiKategorijo: true),
                    ),
                  ),
                  for (final k in kategorije)
                    _KategorijaCip(
                      ime: '${k.emoji} ${k.ime}',
                      izbran: nastavitve.kategorijaId == k.id,
                      onTap: () => controller.posodobiNastavitve(
                        nastavitve.kopija(kategorijaId: k.id),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: SwitchListTile(
                  value: nastavitve.uporabiTimer,
                  activeThumbColor: AppTheme.akcent,
                  title: const Text('ÄŚasovnik za namigovanje'),
                  subtitle: Text(
                    nastavitve.uporabiTimer
                        ? '${nastavitve.casNamigovanjaSekunde ~/ 60} min ${nastavitve.casNamigovanjaSekunde % 60} s'
                        : 'Izklopljen',
                    style: const TextStyle(color: AppTheme.besediloTiho),
                  ),
                  onChanged: (v) => controller.posodobiNastavitve(
                    nastavitve.kopija(uporabiTimer: v),
                  ),
                ),
              ),
              if (nastavitve.uporabiTimer) ...[
                const SizedBox(height: 8),
                _CasDrsnik(
                  sekunde: nastavitve.casNamigovanjaSekunde,
                  onSpremeni: (v) => controller.posodobiNastavitve(
                    nastavitve.kopija(casNamigovanjaSekunde: v),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  value: nastavitve.impostorViDiNamig,
                  activeThumbColor: AppTheme.akcent,
                  title: const Text('Impostor vidi kategorijo'),
                  subtitle: const Text(
                    'LaĹľje blefira (priporoÄŤeno za zaÄŤetnike)',
                    style: TextStyle(color: AppTheme.besediloTiho),
                  ),
                  onChanged: (v) => controller.posodobiNastavitve(
                    nastavitve.kopija(impostorViDiNamig: v),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ElevatedButton(
            onPressed: () {
              controller.zacniIgro(kategorije);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('ZAÄŚNI'),
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
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
            _KrozniGumb(
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
                  color: AppTheme.akcent2,
                ),
              ),
            ),
            _KrozniGumb(
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

class _KrozniGumb extends StatelessWidget {
  const _KrozniGumb({
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
      color: omogocen ? AppTheme.akcent : AppTheme.povrsinaSvetla,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: omogocen ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            ikona,
            color: omogocen ? Colors.white : AppTheme.besediloTiho,
          ),
        ),
      ),
    );
  }
}

class _KategorijaCip extends StatelessWidget {
  const _KategorijaCip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: izbran ? AppTheme.akcent : AppTheme.povrsina,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: izbran ? AppTheme.akcent : AppTheme.povrsinaSvetla,
            width: 1.5,
          ),
        ),
        child: Text(
          ime,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: izbran ? Colors.white : AppTheme.besedilo,
          ),
        ),
      ),
    );
  }
}


class _CasDrsnik extends StatelessWidget {
  const _CasDrsnik({required this.sekunde, required this.onSpremeni});

  final int sekunde;
  final ValueChanged<int> onSpremeni;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Slider(
          value: sekunde.toDouble(),
          min: 30,
          max: 300,
          divisions: 9,
          activeColor: AppTheme.akcent,
          label: '${sekunde ~/ 60}:${(sekunde % 60).toString().padLeft(2, '0')}',
          onChanged: (v) => onSpremeni(v.round()),
        ),
      ),
    );
  }
}
