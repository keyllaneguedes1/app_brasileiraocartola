// lib/models/player.dart
class Player {
  final int id;
  final String apelido;
  final String posicao;
  final String? clube;
  final double pontosFantasy;
  final double? media;

  Player({
    required this.id,
    required this.apelido,
    required this.posicao,
    this.clube,
    required this.pontosFantasy,
    this.media,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json["atletas.atleta_id"],
      apelido: json["atletas.apelido"],
      posicao: json["Posição"],
      clube: json["clube"] ?? json["atletas.clube_id"],
      pontosFantasy: (json["pontos_fantasy"] as num?)?.toDouble() ?? 0.0,
      media: (json["atletas.media_num"] as num?)?.toDouble(),
    );
  }
}
