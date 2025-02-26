import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api.dart';
import '../widgets/pokemon_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String selectedType = 'fire';
  List<Pokemon> allPokemon = [];
  List<Pokemon> displayedPokemon = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 0;
  final int pageSize = 10;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  void fetchPokemon() async {
  setState(() => isLoading = true);
  try {
    final pokemons = await PokeApi.fetchPokemonByType(selectedType);
    setState(() {
      allPokemon = pokemons;
      displayedPokemon = allPokemon.take(pageSize).toList();
      currentPage = 1;
    });
  } catch (e) {
    String errorMessage = 'Failed to load Pokémon';
    if (e.toString().contains('SocketException')) {
      errorMessage = 'No internet connection. Please try again.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
  setState(() => isLoading = false);
}

  void loadMorePokemon() async {
    if (isLoadingMore) return;
    setState(() => isLoadingMore = true);

    try {
      int offset = displayedPokemon.length;
      if (displayedPokemon.length >= allPokemon.length) {
        List<Pokemon> newPokemons = await PokeApi.fetchPokemonByType(
          selectedType,
          offset: offset,
          limit: pageSize,
        );
        if (newPokemons.isNotEmpty) {
          setState(() {
            allPokemon.addAll(newPokemons);
            displayedPokemon.addAll(newPokemons);
            currentPage++;
          });
        }
      } else {
        int nextPageEnd = (currentPage + 1) * pageSize;
        setState(() {
          displayedPokemon = allPokemon.take(nextPageEnd).toList();
          currentPage++;
        });
      }
    } catch (e) {
      String errorMessage = 'Failed to load more Pokémon';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() => isLoadingMore = false);
  }


  void filterPokemon(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedPokemon = allPokemon.take(pageSize).toList();
      } else {
        displayedPokemon = allPokemon
            .where((pokemon) =>
                pokemon.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPokemon();
    _searchController.addListener(() {
      filterPokemon(_searchController.text);
    });

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnimation = _animationController.drive(CurveTween(curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Explorer')),
      body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 128),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      value: selectedType,
                      items: pokemonTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                        fetchPokemon();
                      },
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      isExpanded: true, // To make the dropdown take up the full width
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedPokemon.isEmpty
                    ? const Center(child: Text('No Pokémon found'))
                    : ListView.builder(
                      itemCount: displayedPokemon.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)), // Slide up effect
                                child: PokemonCard(pokemon: displayedPokemon[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTapDown: (_) => _animationController.reverse(), // Shrink the button when pressed
          onTapUp: (_) {
            _animationController.forward(); // Expand the button back to normal size
            loadMorePokemon(); // Load more Pokémon
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ElevatedButton(
              onPressed: isLoadingMore ? null : loadMorePokemon,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoadingMore
                  ? const CircularProgressIndicator()
                  : const Text('Load More', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}