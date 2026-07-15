import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Urejevalnik neobveznih imen igralcev. Sam upravlja polja glede na
/// število igralcev in ob vsaki spremembi sporoči celoten seznam navzgor.
class ImenaUrejevalnik extends StatefulWidget {
  const ImenaUrejevalnik({
    super.key,
    required this.steviloIgralcev,
    required this.imena,
    required this.onSpremeni,
  });

  final int steviloIgralcev;
  final List<String> imena;
  final ValueChanged<List<String>> onSpremeni;

  @override
  State<ImenaUrejevalnik> createState() => _ImenaUrejevalnikState();
}

class _ImenaUrejevalnikState extends State<ImenaUrejevalnik> {
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
  void didUpdateWidget(ImenaUrejevalnik oldWidget) {
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
                  decoration: BoxDecoration(
                    color: AppTheme.barvaIgralca(i).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.barvaIgralca(i)),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.barvaIgralca(i),
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
                        borderSide: BorderSide(color: AppTheme.barvaIgralca(i)),
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
