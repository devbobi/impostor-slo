/// Ena kartica za igro Prepovedane besede: beseda, ki jo opisuješ,
/// in besede, ki jih pri tem ne smeš uporabiti.
class TabooKartica {
  const TabooKartica({required this.beseda, required this.prepovedane});

  final String beseda;
  final List<String> prepovedane;

  factory TabooKartica.fromJson(Map<String, dynamic> json) {
    return TabooKartica(
      beseda: json['beseda'] as String,
      prepovedane: (json['prepovedane'] as List<dynamic>)
          .map((e) => e as String)
          .toList(growable: false),
    );
  }
}
