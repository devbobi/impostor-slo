/// Uporabniške nastavitve pred začetkom igre.
class NastavitveIgre {
  const NastavitveIgre({
    this.steviloIgralcev = 5,
    this.steviloImpostorjev = 1,
    this.kategorijaId,
    this.casNamigovanjaSekunde = 120,
    this.uporabiTimer = true,
    this.impostorViDiNamig = false,
    this.imena = const [],
  });

  final int steviloIgralcev;
  final int steviloImpostorjev;

  /// `null` pomeni "naključna kategorija".
  final String? kategorijaId;

  final int casNamigovanjaSekunde;
  final bool uporabiTimer;

  /// Če je `true`, impostor poleg vloge dobi tudi ime kategorije (lažje blefira).
  final bool impostorViDiNamig;

  /// Neobvezna imena igralcev (po indeksu 0..steviloIgralcev-1).
  /// Prazen niz ali manjkajoč vnos pomeni privzeto "Igralec N".
  final List<String> imena;

  /// Ime za igralca z indeksom [i] (0-osnovan) ali `null`, če ni vneseno.
  String? imeZa(int i) {
    if (i < 0 || i >= imena.length) return null;
    final t = imena[i].trim();
    return t.isEmpty ? null : t;
  }

  NastavitveIgre kopija({
    int? steviloIgralcev,
    int? steviloImpostorjev,
    String? kategorijaId,
    bool pocistiKategorijo = false,
    int? casNamigovanjaSekunde,
    bool? uporabiTimer,
    bool? impostorViDiNamig,
    List<String>? imena,
  }) {
    return NastavitveIgre(
      steviloIgralcev: steviloIgralcev ?? this.steviloIgralcev,
      steviloImpostorjev: steviloImpostorjev ?? this.steviloImpostorjev,
      kategorijaId:
          pocistiKategorijo ? null : (kategorijaId ?? this.kategorijaId),
      casNamigovanjaSekunde:
          casNamigovanjaSekunde ?? this.casNamigovanjaSekunde,
      uporabiTimer: uporabiTimer ?? this.uporabiTimer,
      impostorViDiNamig: impostorViDiNamig ?? this.impostorViDiNamig,
      imena: imena ?? this.imena,
    );
  }

  /// Najvišje dovoljeno število impostorjev glede na število igralcev.
  /// Vedno mora ostati vsaj polovica navadnih igralcev (najmanj eden manj).
  static int najvecImpostorjev(int steviloIgralcev) {
    if (steviloIgralcev <= 4) return 1;
    return (steviloIgralcev / 3).floor().clamp(1, 3);
  }
}
