// lib/models/comparison.dart
import 'player.dart';

class Comparison {
  final List<Player> jogador1;
  final List<Player> jogador2;

  Comparison({required this.jogador1, required this.jogador2});

  factory Comparison.fromJson(Map<String, dynamic> json) {
    return Comparison(
      jogador1: (json["jogador1"] as List).map((e) => Player.fromJson(e)).toList(),
      jogador2: (json["jogador2"] as List).map((e) => Player.fromJson(e)).toList(),
    );
  }
}
