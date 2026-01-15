class PlayerSearch {
  final int id;
  final String apelido;
  final String posicao;
  
  PlayerSearch({
    required this.id,
    required this.apelido,
    required this.posicao,
  });
  
  factory PlayerSearch.fromJson(Map<String, dynamic> json) {
    return PlayerSearch(
      id: json['id'] ?? 0,
      apelido: json['apelido'] ?? '',
      posicao: json['posicao'] ?? '',
    );
  }
}