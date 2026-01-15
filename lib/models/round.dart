// lib/models/round.dart
class Round {
  final int rodadaId;
  final double pontosFantasy;

  Round({
    required this.rodadaId,
    required this.pontosFantasy,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      rodadaId: json["atletas.rodada_id"],
      pontosFantasy: (json["pontos_fantasy"] as num?)?.toDouble() ?? 0.0,
    );
  }
}
