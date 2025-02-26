import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApi {
  static const String baseUrl = "https://pokeapi.co/api/v2";

  static Future<List<Pokemon>> fetchPokemonByType(String type, {int offset = 0, int limit = 10}) async {

    final response = await http.get(Uri.parse("$baseUrl/type/$type"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['pokemon'].skip(offset).take(limit).toList();

      List<Future<Pokemon?>> futurePokemon = results.map((entry) async {
        try {
          final pokemonResponse = await http.get(Uri.parse(entry['pokemon']['url']));
          if (pokemonResponse.statusCode == 200) {
            return Pokemon.fromJson(jsonDecode(pokemonResponse.body));
          }
        } catch (e) {
          print("Error fetching Pokémon: ${entry['pokemon']['name']}, $e");
        }
        return null;
      }).toList();

      // Wait for all Pokémon fetch requests to complete
      List<Pokemon> pokemonList = (await Future.wait(futurePokemon)).whereType<Pokemon>().toList();

      return pokemonList;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}
