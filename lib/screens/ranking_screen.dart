import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/player.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final service = PlayerService();
  int rodada = 1;
  String? posicao;
  String? clube;
  List<Player> rankingRodada = [];
  List<Player> rankingClube = [];
  bool isLoading = true;

  Future<void> _carregar() async {
    setState(() => isLoading = true);
    
    try {
      final r = await service.getRankingRodada(
        rodada,
        posicao: posicao,
        limite: 10,
      );
      
      List<Player> rc = [];
      if (clube != null && clube!.isNotEmpty) {
        // Para ranking do clube, buscamos jogadores do clube e ordenamos
        final jogadoresClube = await service.getPlayers(clube: clube, posicao: posicao);
        jogadoresClube.sort((a, b) => b.pontosFantasy.compareTo(a.pontosFantasy));
        rc = jogadoresClube.take(10).toList();
      }
      
      setState(() {
        rankingRodada = r;
        rankingClube = rc;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar ranking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
        title: const Text("Rankings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.pushNamed(context, '/ranking-temporada');
            },
            tooltip: "Ranking da Temporada",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
            tooltip: "Recarregar",
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de Filtros
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filtros de Ranking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: rodada,
                          decoration: const InputDecoration(
                            labelText: "Rodada",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: List.generate(38, (i) => i + 1)
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Text("Rodada $r"),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => rodada = v);
                              _carregar();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: posicao,
                          decoration: const InputDecoration(
                            labelText: "Posição",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Todas"),
                            ),
                            ...["GOL", "ZAG", "LAT", "MEI", "ATA"]
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ))
                                .toList(),
                          ],
                          onChanged: (v) {
                            setState(() => posicao = v);
                            _carregar();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Clube (opcional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_soccer),
                      hintText: "Ex: FLA, PAL, SAO...",
                    ),
                    onSubmitted: (v) {
                      setState(() {
                        clube = v.isEmpty ? null : v;
                      });
                      _carregar();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Carregando rankings...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : DefaultTabController(
                    length: clube != null ? 2 : 1,
                    child: Column(
                      children: [
                        // Tabs
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            labelColor: const Color(0xFF1A237E),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF1A237E),
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.emoji_events, size: 20),
                                    const SizedBox(width: 8),
                                    const Text("Rodada"),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A237E)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        rodada.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (clube != null)
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.flag, size: 20),
                                      const SizedBox(width: 8),
                                      Text("Clube $clube"),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Ranking da Rodada
                              _buildRankingList(
                                rankingRodada,
                                "Top 10 da Rodada $rodada",
                                true,
                              ),

                              // Ranking do Clube
                              if (clube != null)
                                _buildRankingList(
                                  rankingClube,
                                  "Top 10 do $clube",
                                  false,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(
    List<Player> jogadores,
    String titulo,
    bool mostrarPosicao,
  ) {
    if (jogadores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Nenhum jogador encontrado",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: jogadores.length,
            itemBuilder: (_, index) {
              final player = jogadores[index];
              final isTop3 = index < 3;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      fontWeight:
                          isTop3 ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${player.posicao}${player.clube != null && mostrarPosicao ? ' • ${player.clube}' : ''}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${player.pontosFantasy.toStringAsFixed(1)} pts",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      if (player.media != null)
                        Text(
                          "Média: ${player.media!.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color? _getTop3Color(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Ouro
      case 1:
        return const Color(0xFFC0C0C0); // Prata
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return null;
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