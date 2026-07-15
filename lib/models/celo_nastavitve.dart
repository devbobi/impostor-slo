/// Uporabniške nastavitve igre "Beseda na čelu".
class CeloNastavitve {
  const CeloNastavitve({
    this.kategorijaId,
    this.sekunde = 60,
    this.uporabiNagib = true,
  });

  /// `null` pomeni "naključna kategorija".
  final String? kategorijaId;
  final int sekunde;

  /// Če je `true`, se za pravilno/preskok uporablja nagib telefona.
  /// Sicer se tapne levo/desno polovico zaslona.
  final bool uporabiNagib;

  static const List<int> moznCas = [30, 60, 90, 120];

  CeloNastavitve kopija({
    String? kategorijaId,
    bool pocistiKategorijo = false,
    int? sekunde,
    bool? uporabiNagib,
  }) {
    return CeloNastavitve(
      kategorijaId:
          pocistiKategorijo ? null : (kategorijaId ?? this.kategorijaId),
      sekunde: sekunde ?? this.sekunde,
      uporabiNagib: uporabiNagib ?? this.uporabiNagib,
    );
  }
}

/// Rezultat ene besede v igri.
class CeloRezultat {
  const CeloRezultat({required this.beseda, required this.uganjena});

  final String beseda;
  final bool uganjena;
}
