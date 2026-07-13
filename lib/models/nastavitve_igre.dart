/// Uporabniške nastavitve pred začetkom igre.
class NastavitveIgre {
  const NastavitveIgre({
    this.steviloIgralcev = 5,
    this.steviloImpostorjev = 1,
    this.kategorijaId,
    this.casNamigovanjaSekunde = 120,
    this.uporabiTimer = true,
    this.impostorViDiNamig = false,
  });

  final int steviloIgralcev;
  final int steviloImpostorjev;

  /// `null` pomeni "naključna kategorija".
  final String? kategorijaId;

  final int casNamigovanjaSekunde;
  final bool uporabiTimer;

  /// Če je `true`, impostor poleg vloge dobi tudi ime kategorije (lažje blefira).
  final bool impostorViDiNamig;

  NastavitveIgre kopija({
    int? steviloIgralcev,
    int? steviloImpostorjev,
    String? kategorijaId,
    bool pocistiKategorijo = false,
    int? casNamigovanjaSekunde,
    bool? uporabiTimer,
    bool? impostorViDiNamig,
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
    );
  }

  /// Najvišje dovoljeno število impostorjev glede na število igralcev.
  /// Vedno mora ostati vsaj polovica navadnih igralcev (najmanj eden manj).
  static int najvecImpostorjev(int steviloIgralcev) {
    if (steviloIgralcev <= 4) return 1;
    return (steviloIgralcev / 3).floor().clamp(1, 3);
  }
}
