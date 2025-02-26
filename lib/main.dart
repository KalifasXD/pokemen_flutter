import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PokemonExplorerApp());
}

class PokemonExplorerApp extends StatelessWidget {
  const PokemonExplorerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Explorer',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomeScreen(),
    );
  }
}

