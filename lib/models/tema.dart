/// Tema za igro Bomba (npr. "Živali") — igralci naštevajo besede na to temo.
class Tema {
  const Tema({
    required this.id,
    required this.ime,
    required this.emoji,
  });

  final String id;
  final String ime;
  final String emoji;

  factory Tema.fromJson(Map<String, dynamic> json) {
    return Tema(
      id: json['id'] as String,
      ime: json['ime'] as String,
      emoji: (json['emoji'] as String?) ?? '❓',
    );
  }
}
