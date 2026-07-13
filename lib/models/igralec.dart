/// Vloga igralca v posamezni igri.
enum Vloga { navadni, impostor }

/// En igralec v krogu igre. Igralci so oštevilčeni; ime je neobvezno —
/// če ni vneseno, se prikaže privzeto "Igralec N".
class Igralec {
  Igralec({
    required this.stevilka,
    required this.vloga,
    this.ime,
    this.izlocen = false,
  });

  final int stevilka;
  final Vloga vloga;
  final String? ime;
  bool izlocen;

  bool get jeImpostor => vloga == Vloga.impostor;

  /// Ime za prikaz: vneseno ime, sicer "Igralec N".
  String get prikazniIme {
    final t = ime?.trim() ?? '';
    return t.isEmpty ? 'Igralec $stevilka' : t;
  }
}
