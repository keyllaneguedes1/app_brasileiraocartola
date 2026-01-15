class Scout {
  final int id; 
  final String apelido; 
  final int gols;
  final int assistencias;
  final int desarmes;
  final int faltasCometidas;
  final int faltasSofridas;
  final int finalizacoesDefendidas;
  final int finalizacoesTrave;
  final int defesasDificeis;
  final int penaltisDefendidos;
  final int jogosSemGol;
  final int totalRodadas;
  final String? posicao;

  Scout({
    required this.id, 
    required this.apelido, 
    required this.gols,
    required this.assistencias,
    required this.desarmes,
    required this.faltasCometidas,
    required this.faltasSofridas,
    required this.finalizacoesDefendidas,
    required this.finalizacoesTrave,
    required this.defesasDificeis,
    required this.penaltisDefendidos,
    required this.jogosSemGol,
    required this.totalRodadas,
    this.posicao,
  });


  factory Scout.fromJson(Map<String, dynamic> json) {
    return Scout(
      id: json["atletas.atleta_id"] ?? 0,
      apelido: json["atletas.apelido"] ?? "",
      gols: (json["G"] ?? 0) as int,
      assistencias: (json["A"] ?? 0) as int,
      desarmes: (json["DS"] ?? 0) as int,
      faltasCometidas: (json["FC"] ?? 0) as int,
      faltasSofridas: (json["FS"] ?? 0) as int,
      finalizacoesDefendidas: (json["FD"] ?? 0) as int,
      finalizacoesTrave: (json["FT"] ?? 0) as int,
      defesasDificeis: (json["DE"] ?? 0) as int,
      penaltisDefendidos: (json["DP"] ?? 0) as int,
      jogosSemGol: (json["SG"] ?? 0) as int,
      totalRodadas: 0, 
      posicao: null,
    );
  }

  // Fábrica para criar a partir da resposta do endpoint detalhado
  factory Scout.fromDetalhadoJson(Map<String, dynamic> json) {
    final totais = json['totais'] as Map<String, dynamic>;
    
    return Scout(
      id: 0, 
      apelido: "", 
      gols: (totais['G'] as num).toInt(),
      assistencias: (totais['A'] as num).toInt(),
      desarmes: (totais['DS'] as num).toInt(),
      faltasCometidas: (totais['FC'] as num).toInt(),
      faltasSofridas: (totais['FS'] as num).toInt(),
      finalizacoesDefendidas: (totais['FD'] as num).toInt(),
      finalizacoesTrave: (totais['FT'] as num).toInt(),
      defesasDificeis: (totais['DE'] as num).toInt(),
      penaltisDefendidos: (totais['DP'] as num).toInt(),
      jogosSemGol: (totais['SG'] as num).toInt(),
      totalRodadas: (json['total_rodadas'] as num).toInt(),
      posicao: json['posicao'],
    );
  }

  // Métodos úteis
  int get finalizacoesTotais => finalizacoesDefendidas + finalizacoesTrave;
  
  double get eficienciaAtaque {
    if (finalizacoesTotais == 0) return 0.0;
    return gols / finalizacoesTotais;
  }
  
  String get eficienciaAtaqueFormatada {
    return '${(eficienciaAtaque * 100).toStringAsFixed(1)}%';
  }
  
  Map<String, double> get mediasPorRodada {
    return {
      'gols': totalRodadas > 0 ? gols / totalRodadas : 0.0,
      'assistencias': totalRodadas > 0 ? assistencias / totalRodadas : 0.0,
      'desarmes': totalRodadas > 0 ? desarmes / totalRodadas : 0.0,
      'finalizacoes': totalRodadas > 0 ? finalizacoesTotais / totalRodadas : 0.0,
    };
  }
}