import 'imena_util.dart';

/// Prednastavljeni razponi trajanja bombe. Točen čas je naključen znotraj
/// razpona, tako da nikoli ni enako dolgo — in nihče ne ve, kdaj poči.
enum BombaDolzina {
  hitro(20, 45, 'Hitro', '20–45 s'),
  normalno(40, 90, 'Normalno', '40–90 s'),
  dolgo(80, 150, 'Dolgo', '80–150 s');

  const BombaDolzina(this.minSek, this.maxSek, this.ime, this.opis);

  final int minSek;
  final int maxSek;
  final String ime;
  final String opis;
}

/// Uporabniške nastavitve igre Bomba.
class BombaNastavitve {
  const BombaNastavitve({
    this.steviloIgralcev = 4,
    this.dolzina = BombaDolzina.normalno,
    this.temaId,
    this.imena = const [],
  });

  final int steviloIgralcev;
  final BombaDolzina dolzina;

  /// `null` pomeni "naključna tema".
  final String? temaId;

  /// Neobvezna imena igralcev (po indeksu).
  final List<String> imena;

  /// Ime igralca z indeksom [i] ali privzeto "Igralec N".
  String imeZa(int i) => imeIgralca(imena, i);

  BombaNastavitve kopija({
    int? steviloIgralcev,
    BombaDolzina? dolzina,
    String? temaId,
    bool pocistiTemo = false,
    List<String>? imena,
  }) {
    return BombaNastavitve(
      steviloIgralcev: steviloIgralcev ?? this.steviloIgralcev,
      dolzina: dolzina ?? this.dolzina,
      temaId: pocistiTemo ? null : (temaId ?? this.temaId),
      imena: imena ?? this.imena,
    );
  }
}
