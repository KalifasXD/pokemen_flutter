class Pokemon {
  final String name;
  final String imageUrl;
  final int hp;
  final int attack;
  final int defense;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.hp,
    required this.attack,
    required this.defense,
  });


  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'], 
      imageUrl: json['sprites']['front_default'] ?? '', 
      hp: json['stats'][0]['base_stat'], 
      attack: json['stats'][1]['base_stat'], 
      defense: json['stats'][2]['base_stat']);
  }
}