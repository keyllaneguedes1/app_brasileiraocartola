import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/player.dart';
import '../models/round.dart';
import '../models/scout.dart';
import '../models/comparison.dart';

class PlayerService {
  final String baseUrl = "https://app-cartola-api.onrender.com";
  
  // Cache simples em memória
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  final Duration _cacheDuration = const Duration(minutes: 10);

  // Verifica se o cache ainda é válido
  bool _isCacheValid(String key) {
    if (!_cacheTimestamp.containsKey(key) || !_cache.containsKey(key)) {
      return false;
    }
    
    final lastUpdate = _cacheTimestamp[key]!;
    final now = DateTime.now();
    return now.difference(lastUpdate) < _cacheDuration;
  }

  // Salva no cache
  void _saveToCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamp[key] = DateTime.now();
  }

  // Método genérico para requisições
  Future<dynamic> _makeRequest(String url, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha na requisição: ${response.statusCode}');
    }
  }

  // 1. Listar jogadores
  Future<List<Player>> getPlayers({String? clube, String? posicao, String? nome}) async {
    final cacheKey = 'players_${clube}_${posicao}_${nome}';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Player>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/jogadores",
        queryParams: {
          if (clube != null) "clube": clube,
          if (posicao != null) "posicao": posicao,
          if (nome != null) "nome": nome,
        },
      ) as List;
      
      final players = data.map((e) => Player.fromJson(e)).toList();
      _saveToCache(cacheKey, players);
      return players;
    } catch (e) {
      print('Erro ao buscar jogadores: $e');
      return [];
    }
  }

  // 2. Detalhes do jogador
  Future<Player?> getPlayerDetails(int id) async {
    final cacheKey = 'player_details$id';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Player?;
    }

    try {
      final data = await _makeRequest("$baseUrl/jogadores/$id") as List;
      
      if (data.isNotEmpty) {
        final player = Player.fromJson(data[0]);
        _saveToCache(cacheKey, player);
        return player;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar detalhes do jogador: $e');
      return null;
    }
  }

  // 3. Rodadas do jogador
  Future<List<Round>> getPlayerRounds(int id, {int limite = 5}) async {
    final cacheKey = 'player_rounds_${id}_$limite';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Round>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/jogadores/$id/rodadas",
        queryParams: {"limite": limite.toString()},
      ) as List;
      
      final rounds = data.map((e) => Round.fromJson(e)).toList();
      _saveToCache(cacheKey, rounds);
      return rounds;
    } catch (e) {
      print('Erro ao buscar rodadas do jogador: $e');
      return [];
    }
  }

  // 4. Ranking por rodada
  Future<List<Player>> getRankingRodada(int rodada, {String? posicao, String? clube, int limite = 10}) async {
    final cacheKey = 'ranking_rodada_${rodada}_${posicao}_${clube}_$limite';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Player>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/ranking/rodada",
        queryParams: {
          "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      // Converter para Player - os dados vêm com estrutura diferente
      final players = data.map((e) {
        return Player(
          id: e["atletas.atleta_id"],
          apelido: e["atletas.apelido"],
          posicao: e["Posição"],
          pontosFantasy: (e["pontos_fantasy"] as num?)?.toDouble() ?? 0.0,
          media: null, // Não vem no ranking por rodada
          clube: null, // Não vem no ranking por rodada
        );
      }).toList();
      
      _saveToCache(cacheKey, players);
      return players;
    } catch (e) {
      print('Erro ao buscar ranking da rodada: $e');
      return [];
    }
  }

  // 5. Comparação entre jogadores
  Future<Comparison> getComparison(int id1, int id2) async {
    final cacheKey = 'comparison_${id1}_$id2';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Comparison;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/comparacao",
        queryParams: {
          "id_jogador1": id1.toString(),
          "id_jogador2": id2.toString(),
        },
      ) as Map<String, dynamic>;
      
      final comparison = Comparison.fromJson(data);
      _saveToCache(cacheKey, comparison);
      return comparison;
    } catch (e) {
      print('Erro ao fazer comparação: $e');
      throw Exception('Erro ao comparar jogadores');
    }
  }

  // 6. Top Gols
  Future<List<Scout>> topGols({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    final cacheKey = 'top_gols_${rodada}_${posicao}_${clube}_$limite';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Scout>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/ataque/top-gols",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      final scouts = data.map((e) {
        return Scout.fromJson(e); // Usa o factory fromJson
      }).toList();
      
      _saveToCache(cacheKey, scouts);
      return scouts;
    } catch (e) {
      print('Erro ao buscar top gols: $e');
      return [];
    }
  }

  // 7. Evolução Top 3
  Future<List<dynamic>> evolucaoTop3({int limiteRodadas = 5}) async {
    final cacheKey = 'evolucao_top3_$limiteRodadas';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<dynamic>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/graficos/evolucao-top3",
        queryParams: {"limite_rodadas": limiteRodadas.toString()},
      ) as List;
      
      _saveToCache(cacheKey, data);
      return data;
    } catch (e) {
      print('Erro ao buscar evolução top 3: $e');
      return [];
    }
  }

  // 8. Estatísticas do clube
  Future<List<Player>> getEstatisticasClube(String clube) async {
    final cacheKey = 'estatisticas_clube_$clube';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Player>;
    }

    try {
      final data = await _makeRequest("$baseUrl/estatisticas/clube/$clube") as List;
      
      final players = data.map((e) => Player.fromJson(e)).toList();
      _saveToCache(cacheKey, players);
      return players;
    } catch (e) {
      print('Erro ao buscar estatísticas do clube: $e');
      return [];
    }
  }

  // 9. Top pontuadores (para ranking da temporada)
  Future<List<Player>> getTopPontuadores({int limite = 20}) async {
    final cacheKey = 'top_pontuadores_$limite';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Player>;
    }

    try {
      final data = await _makeRequest(
        "$baseUrl/graficos/top-pontuadores",
        queryParams: {"limite": limite.toString()},
      ) as List;
      
      final players = data.map((e) {
        return Player(
          id: 0, // Não vem na API
          apelido: e["atletas.apelido"],
          posicao: e["Posição"],
          pontosFantasy: (e["pontos_fantasy"] as num?)?.toDouble() ?? 0.0,
          media: null,
          clube: null,
        );
      }).toList();
      
      _saveToCache(cacheKey, players);
      return players;
    } catch (e) {
      print('Erro ao buscar top pontuadores: $e');
      return [];
    }
  }

  // 10. Calcula estatísticas do jogador localmente
  Future<Map<String, dynamic>> getPlayerStats(int id) async {
    final cacheKey = 'player_stats_$id';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      final rounds = await getPlayerRounds(id, limite: 38);
      
      if (rounds.isEmpty) {
        final stats = {
          'media_ultimas_5': 0.0,
          'pontuacao_maxima': 0.0,
          'pontuacao_minima': 0.0,
          'total_rodadas': 0,
          'historico_completo': rounds,
        };
        _saveToCache(cacheKey, stats);
        return stats;
      }

      // Últimas 5 rodadas (as mais recentes)
      final ultimas5 = rounds.take(5).toList();
      final mediaUltimas5 = ultimas5.isEmpty 
          ? 0.0 
          : ultimas5.map((r) => r.pontosFantasy).reduce((a, b) => a + b) / ultimas5.length;

      // Máximo e mínimo
      final pontuacoes = rounds.map((r) => r.pontosFantasy).toList();
      final maximo = pontuacoes.reduce((a, b) => a > b ? a : b);
      final minimo = pontuacoes.reduce((a, b) => a < b ? a : b);

      final stats = {
        'media_ultimas_5': mediaUltimas5,
        'pontuacao_maxima': maximo,
        'pontuacao_minima': minimo,
        'total_rodadas': rounds.length,
        'historico_completo': rounds,
      };
      
      _saveToCache(cacheKey, stats);
      return stats;
    } catch (e) {
      print('Erro ao calcular estatísticas: $e');
      return {
        'media_ultimas_5': 0.0,
        'pontuacao_maxima': 0.0,
        'pontuacao_minima': 0.0,
        'total_rodadas': 0,
        'historico_completo': [],
      };
    }
  }

  // 11. Scouts detalhados do jogador
  Future<Map<String, dynamic>> getPlayerScoutsDetalhado(int id) async {
    final cacheKey = 'player_scouts_detalhado_$id';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      final data = await _makeRequest("$baseUrl/jogadores/$id/scouts-detalhado") as Map<String, dynamic>;
      
      _saveToCache(cacheKey, data);
      return data;
    } catch (e) {
      print('Erro ao buscar scouts detalhados: $e');
      rethrow;
    }
  }

  // 12. Limpar cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamp.clear();
  }

  // 13. Scouts extras da API
  Future<List<Scout>> topAssistencias({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/ataque/top-assistencias",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      return data.map((e) {
        return Scout.fromJson(e); // Usa o factory fromJson
      }).toList();
    } catch (e) {
      print('Erro ao buscar top assistências: $e');
      return [];
    }
  }

  Future<List<Scout>> topDesarmes({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/defesa/top-desarmes",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      return data.map((e) {
        return Scout.fromJson(e); // Usa o factory fromJson
      }).toList();
    } catch (e) {
      print('Erro ao buscar top desarmes: $e');
      return [];
    }
  }

  // 14. Outros endpoints de scouts disponíveis na API
  Future<List<Scout>> topFinalizacoesPerigosas({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/ataque/top-finalizacoes-perigosas",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      return data.map((e) {
        return Scout.fromJson(e);
      }).toList();
    } catch (e) {
      print('Erro ao buscar top finalizações perigosas: $e');
      return [];
    }
  }

  Future<List<Scout>> topFaltasSofridas({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/ataque/top-faltas-sofridas",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (posicao != null) "posicao": posicao,
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      return data.map((e) {
        return Scout.fromJson(e);
      }).toList();
    } catch (e) {
      print('Erro ao buscar top faltas sofridas: $e');
      return [];
    }
  }

  Future<List<Scout>> topDefesasDificeis({int? rodada, int limite = 10, String? clube}) async {
    try {
      final data = await _makeRequest(
        "$baseUrl/scouts/goleiros/top-defesas-dificeis",
        queryParams: {
          if (rodada != null) "rodada": rodada.toString(),
          "limite": limite.toString(),
          if (clube != null) "clube": clube,
        },
      ) as List;
      
      return data.map((e) {
        return Scout.fromJson(e);
      }).toList();
    } catch (e) {
      print('Erro ao buscar top defesas difíceis: $e');
      return [];
    }
  }

  // 15. Listar clubes disponíveis
  Future<List<String>> getClubesDisponiveis() async {
    final cacheKey = 'clubes_disponiveis';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<String>;
    }

    try {
      final jogadores = await getPlayers();
      final clubesSet = <String>{};
      
      for (var jogador in jogadores) {
        if (jogador.clube != null && jogador.clube!.isNotEmpty) {
          clubesSet.add(jogador.clube!);
        }
      }
      
      final clubesList = clubesSet.toList()..sort();
      
      // Se não encontrou clubes, usa lista padrão
      if (clubesList.isEmpty) {
        clubesList.addAll([
          "FLA", "PAL", "SAO", "COR", "GRE", "CAM", 
          "INT", "SAN", "FLU", "BOT", "CAP", "CUI",
          "FOR", "GOI", "BAH", "VAS", "CRU", "AME"
        ]);
      }
      
      _saveToCache(cacheKey, clubesList);
      return clubesList;
    } catch (e) {
      print('Erro ao buscar clubes: $e');
      // Retorna lista padrão em caso de erro
      return [
        "FLA", "PAL", "SAO", "COR", "GRE", "CAM", 
        "INT", "SAN", "FLU", "BOT", "CAP", "CUI",
        "FOR", "GOI", "BAH", "VAS", "CRU", "AME"
      ];
    }
  }

  // 16. Gols vs Assistências (para gráficos)
  Future<List<dynamic>> getGolsVsAssistencias() async {
    final cacheKey = 'gols_vs_assistencias';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<dynamic>;
    }

    try {
      final data = await _makeRequest("$baseUrl/graficos/gols-vs-assistencias") as List;
      
      _saveToCache(cacheKey, data);
      return data;
    } catch (e) {
      print('Erro ao buscar dados gols vs assistências: $e');
      return [];
    }
  }
}
