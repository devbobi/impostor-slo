import 'imena_util.dart';

/// Uporabniške nastavitve igre "Kdo je najbolj verjetno?".
class NajverjetnejeNastavitve {
  const NajverjetnejeNastavitve({
    this.steviloIgralcev = 4,
    this.steviloKrogov = 10,
    this.imena = const [],
  });

  final int steviloIgralcev;
  final int steviloKrogov;
  final List<String> imena;

  String imeZa(int i) => imeIgralca(imena, i);

  static const List<int> moznaStevilaKrogov = [5, 10, 15, 20];

  NajverjetnejeNastavitve kopija({
    int? steviloIgralcev,
    int? steviloKrogov,
    List<String>? imena,
  }) {
    return NajverjetnejeNastavitve(
      steviloIgralcev: steviloIgralcev ?? this.steviloIgralcev,
      steviloKrogov: steviloKrogov ?? this.steviloKrogov,
      imena: imena ?? this.imena,
    );
  }
}
