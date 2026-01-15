// lib/models/scout.dart
class Scout {
  final int id;
  final String apelido;
  final int gols;
  final int assistencias;
  final int desarmes;
  final int faltasCometidas;
  final int faltasSofridas;
  final int finalizacoesPerigosas;
  final int defesasDificeis;
  final int penaltisDefendidos;
  final int jogosSemGol;

  Scout({
    required this.id,
    required this.apelido,
    this.gols = 0,
    this.assistencias = 0,
    this.desarmes = 0,
    this.faltasCometidas = 0,
    this.faltasSofridas = 0,
    this.finalizacoesPerigosas = 0,
    this.defesasDificeis = 0,
    this.penaltisDefendidos = 0,
    this.jogosSemGol = 0,
  });

  factory Scout.fromJson(Map<String, dynamic> json) {
    return Scout(
      id: json["atletas.atleta_id"],
      apelido: json["atletas.apelido"],
      gols: (json["G"] ?? 0) as int,
      assistencias: (json["A"] ?? 0) as int,
      desarmes: (json["DS"] ?? 0) as int,
      faltasCometidas: (json["FC"] ?? 0) as int,
      faltasSofridas: (json["FS"] ?? 0) as int,
      finalizacoesPerigosas: (json["Finalizacoes_Perigosas"] ?? 0) as int,
      defesasDificeis: (json["DE"] ?? 0) as int,
      penaltisDefendidos: (json["DP"] ?? 0) as int,
      jogosSemGol: (json["SG"] ?? 0) as int,
    );
  }
}
