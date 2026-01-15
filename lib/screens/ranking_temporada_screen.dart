import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/player.dart';

class RankingTemporadaScreen extends StatefulWidget {
  const RankingTemporadaScreen({super.key});

  @override
  State<RankingTemporadaScreen> createState() => _RankingTemporadaScreenState();
}

class _RankingTemporadaScreenState extends State<RankingTemporadaScreen> {
  final service = PlayerService();
  List<Player> rankingTemporada = [];
  bool isLoading = true;

  Future<void> _carregar() async {
    setState(() => isLoading = true);
    
    try {
      final temporada = await service.getTopPontuadores(limite: 20);
      setState(() => rankingTemporada = temporada);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar ranking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ranking da Temporada 2025"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rankingTemporada.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Nenhum dado disponível",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rankingTemporada.length,
                  itemBuilder: (context, index) {
                    final player = rankingTemporada[index];
                    final isTop3 = index < 3;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isTop3 ? _getTop3Color(index)?.withOpacity(0.1) : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPositionColor(player.posicao),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          player.apelido,
                          style: TextStyle(
                            fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(player.posicao),
                        trailing: Text(
                          "${player.pontosFantasy.toStringAsFixed(1)} pts",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color? _getTop3Color(int index) {
    switch (index) {
      case 0: return const Color(0xFFFFD700); // Ouro
      case 1: return const Color(0xFFC0C0C0); // Prata
      case 2: return const Color(0xFFCD7F32); // Bronze
      default: return null;
    }
  }

  Color _getPositionColor(String posicao) {
    switch (posicao) {
      case "GOL":
        return Colors.orange;
      case "ZAG":
        return Colors.green;
      case "LAT":
        return Colors.blue;
      case "MEI":
        return Colors.purple;
      case "ATA":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}