import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Skupno gradientno ozadje z rahlim "party" pridihom.
class Ozadje extends StatelessWidget {
  const Ozadje({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF181430),
            AppTheme.ozadje,
            Color(0xFF241634),
          ],
        ),
      ),
      child: child,
    );
  }
}
