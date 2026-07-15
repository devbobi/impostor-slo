/// Ime igralca z indeksom [i] (0-osnovan) iz seznama neobveznih imen.
/// Če ime ni vneseno, vrne privzeto "Igralec N".
String imeIgralca(List<String> imena, int i) {
  if (i >= 0 && i < imena.length) {
    final t = imena[i].trim();
    if (t.isNotEmpty) return t;
  }
  return 'Igralec ${i + 1}';
}
