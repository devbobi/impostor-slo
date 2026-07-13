/// Kategorija besed (npr. Hrana, Poklici ...) skupaj s svojim naborom besed.
class Kategorija {
  const Kategorija({
    required this.id,
    required this.ime,
    required this.emoji,
    required this.besede,
  });

  final String id;
  final String ime;
  final String emoji;
  final List<String> besede;

  factory Kategorija.fromJson(Map<String, dynamic> json) {
    return Kategorija(
      id: json['id'] as String,
      ime: json['ime'] as String,
      emoji: (json['emoji'] as String?) ?? '❓',
      besede: (json['besede'] as List<dynamic>)
          .map((e) => e as String)
          .toList(growable: false),
    );
  }
}
