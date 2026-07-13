import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';

class NavodilaScreen extends StatelessWidget {
  const NavodilaScreen({super.key});

  static const List<(String, String)> _koraki = [
    (
      '1. Priprava',
      'Izberite število igralcev, kategorijo in koliko impostorjev bo v igri. Potrebujete en telefon, ki ga podajate med igralci.'
    ),
    (
      '2. Razkritje vlog',
      'Telefon kroži med igralci. Vsak na skrivaj pogleda svojo vlogo. Večina vidi isto skrivno besedo, impostor pa vidi le, da je impostor.'
    ),
    (
      '3. Namigovanje',
      'Po vrsti vsak pove en namig, povezan s skrivno besedo — dovolj jasno, da dokažete, da besedo poznate, a ne preveč očitno. Impostor blefira.'
    ),
    (
      '4. Glasovanje',
      'Po pogovoru glasujete, kdo je po vašem mnenju impostor. Izberete izločenega igralca.'
    ),
    (
      '5. Razplet',
      'Če ujamete impostorja, zmagajo navadni igralci. Če izločite nedolžnega, zmaga impostor.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kako se igra')),
      body: Ozadje(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _koraki.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final (naslov, opis) = _koraki[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        naslov,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppTheme.akcent2,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        opis,
                        style: const TextStyle(
                          color: AppTheme.besediloTiho,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
