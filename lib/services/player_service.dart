import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/player.dart';
import '../models/round.dart';
import '../models/scout.dart';
import '../models/comparison.dart';

class PlayerService {
  final String baseUrl = "https://app-cartola-api.onrender.com";

  Future<List<Player>> getPlayers({String? clube, String? posicao, String? nome}) async {
    final uri = Uri.parse("$baseUrl/jogadores").replace(queryParameters: {
      if (clube != null) "clube": clube,
      if (posicao != null) "posicao": posicao,
      if (nome != null) "nome": nome,
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Player.fromJson(e)).toList();
  }

  Future<Player?> getPlayerDetails(int id) async {
    final res = await http.get(Uri.parse("$baseUrl/jogadores/$id"));
    final list = jsonDecode(res.body) as List;
    return list.isNotEmpty ? Player.fromJson(list[0]) : null;
  }

  Future<List<Round>> getPlayerRounds(int id, {int limite = 5}) async {
    final res = await http.get(Uri.parse("$baseUrl/jogadores/$id/rodadas?limite=$limite"));
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Round.fromJson(e)).toList();
  }

  Future<List<Player>> getRankingRodada(int rodada, {String? posicao, String? clube, int limite = 10}) async {
    final uri = Uri.parse("$baseUrl/ranking/rodada").replace(queryParameters: {
      "rodada": rodada.toString(),
      "limite": limite.toString(),
      if (posicao != null) "posicao": posicao,
      if (clube != null) "clube": clube,
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Player.fromJson(e)).toList();
  }

  Future<Comparison> getComparison(int id1, int id2) async {
    final uri = Uri.parse("$baseUrl/comparacao?id_jogador1=$id1&id_jogador2=$id2");
    final res = await http.get(uri);
    return Comparison.fromJson(jsonDecode(res.body));
  }

  Future<List<Scout>> topGols({int? rodada, int limite = 10, String? posicao, String? clube}) async {
    final uri = Uri.parse("$baseUrl/scouts/ataque/top-gols").replace(queryParameters: {
      if (rodada != null) "rodada": rodada.toString(),
      "limite": limite.toString(),
      if (posicao != null) "posicao": posicao,
      if (clube != null) "clube": clube,
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as List;
    return data.map((e) => Scout.fromJson(e)).toList();
  }

  Future<List<dynamic>> evolucaoTop3({int limiteRodadas = 5}) async {
    final uri = Uri.parse("$baseUrl/graficos/evolucao-top3?limite_rodadas=$limiteRodadas");
    final res = await http.get(uri);
    return jsonDecode(res.body);
  }
}

  
