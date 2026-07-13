import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/besede_repository.dart';
import '../models/kategorija.dart';
import '../models/nastavitve_igre.dart';
import '../state/igra_controller.dart';
import '../theme/app_theme.dart';
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
                naslov: 'Število igralcev',
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
                naslov: 'Število impostorjev',
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
                'Neobvezno — prazno polje pomeni »Igralec N«.',
                style: TextStyle(color: AppTheme.besediloTiho, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _ImenaUrejevalnik(
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
                    ime: '🎲 Naključno',
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
                  title: const Text('Časovnik za namigovanje'),
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
                    'Lažje blefira (priporočeno za začetnike)',
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
            child: const Text('ZAČNI'),
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

/// Urejevalnik neobveznih imen igralcev. Sam upravlja polja glede na
/// število igralcev in ob vsaki spremembi sporoči celoten seznam navzgor.
class _ImenaUrejevalnik extends StatefulWidget {
  const _ImenaUrejevalnik({
    required this.steviloIgralcev,
    required this.imena,
    required this.onSpremeni,
  });

  final int steviloIgralcev;
  final List<String> imena;
  final ValueChanged<List<String>> onSpremeni;

  @override
  State<_ImenaUrejevalnik> createState() => _ImenaUrejevalnikState();
}

class _ImenaUrejevalnikState extends State<_ImenaUrejevalnik> {
  late List<TextEditingController> _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = List.generate(
      widget.steviloIgralcev,
      (i) => TextEditingController(
        text: i < widget.imena.length ? widget.imena[i] : '',
      ),
    );
  }

  @override
  void didUpdateWidget(_ImenaUrejevalnik oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steviloIgralcev != _ctrl.length) {
      _uskladiKolicino(widget.steviloIgralcev);
    }
  }

  void _uskladiKolicino(int novo) {
    if (novo > _ctrl.length) {
      for (var i = _ctrl.length; i < novo; i++) {
        _ctrl.add(TextEditingController(
          text: i < widget.imena.length ? widget.imena[i] : '',
        ));
      }
    } else if (novo < _ctrl.length) {
      for (var i = _ctrl.length - 1; i >= novo; i--) {
        _ctrl[i].dispose();
        _ctrl.removeAt(i);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _javiSpremembo() {
    widget.onSpremeni(_ctrl.map((c) => c.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _ctrl.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.povrsinaSvetla,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.besediloTiho,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ctrl[i],
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: AppTheme.besedilo),
                    onChanged: (_) => _javiSpremembo(),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Igralec ${i + 1}',
                      hintStyle: const TextStyle(color: AppTheme.besediloTiho),
                      filled: true,
                      fillColor: AppTheme.povrsina,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.akcent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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
