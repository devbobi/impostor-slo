import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_theme.dart';
import '../widgets/ozadje.dart';
import 'navodila_screen.dart';

class DomovScreen extends StatelessWidget {
  const DomovScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ozadje(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text(
                  '🥸',
                  style: TextStyle(fontSize: 84),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'VSILJIVEC',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: AppTheme.besedilo,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kdo blefira?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.akcent2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => odpriNastavitve(context),
                  child: const Text('NOVA IGRA'),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NavodilaScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppTheme.besedilo,
                    side: const BorderSide(color: AppTheme.povrsinaSvetla),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'KAKO SE IGRA',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
