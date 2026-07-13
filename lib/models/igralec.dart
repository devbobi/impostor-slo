/// Vloga igralca v posamezni igri.
enum Vloga { navadni, impostor }

/// En igralec v krogu igre. V pass & play načinu so igralci oštevilčeni
/// (Igralec 1, Igralec 2 ...), ime se lahko doda kasneje.
class Igralec {
  Igralec({
    required this.stevilka,
    required this.vloga,
    this.izlocen = false,
  });

  final int stevilka;
  final Vloga vloga;
  bool izlocen;

  bool get jeImpostor => vloga == Vloga.impostor;

  String get privzetoIme => 'Igralec $stevilka';
}
