import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../screens/pokemon_detail_screen.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Hero( // Add Hero animation to the image
          tag: pokemon.name,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              pokemon.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => PokemonDetailScreen(pokemon: pokemon),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
