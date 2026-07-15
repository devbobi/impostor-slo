import 'imena_util.dart';

/// Uporabniške nastavitve igre Prepovedane besede.
class TabooNastavitve {
  const TabooNastavitve({
    this.steviloIgralcev = 4,
    this.sekundeNaKrog = 60,
    this.imena = const [],
  });

  final int steviloIgralcev;
  final int sekundeNaKrog;
  final List<String> imena;

  String imeZa(int i) => imeIgralca(imena, i);

  static const List<int> moznCas = [30, 60, 90, 120];

  TabooNastavitve kopija({
    int? steviloIgralcev,
    int? sekundeNaKrog,
    List<String>? imena,
  }) {
    return TabooNastavitve(
      steviloIgralcev: steviloIgralcev ?? this.steviloIgralcev,
      sekundeNaKrog: sekundeNaKrog ?? this.sekundeNaKrog,
      imena: imena ?? this.imena,
    );
  }
}
