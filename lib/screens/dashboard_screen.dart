import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/evolucao_top3_chart.dart';
import '../widgets/gols_assistencias_chart.dart'; 
import '../models/player.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final service = PlayerService();
  int rodada = 1;
  String? posicao;
  String? clube;
  List<Player> topLiga = [];
  List<Player> topClube = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clube = ModalRoute.of(context)?.settings.arguments as String?;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => isLoading = true);
    
    try {
      final liga = await service.getRankingRodada(rodada, limite: 5, posicao: posicao);
      List<Player> doClube = [];
      
        if (clube != null) {
          // Para ranking do clube, buscamos estatísticas do clube
          final estatisticasClube = await service.getEstatisticasClube(clube!);
          // Filtra por posição se necessário
          var jogadoresFiltrados = estatisticasClube;
          if (posicao != null) {
            jogadoresFiltrados = jogadoresFiltrados.where((j) => j.posicao == posicao).toList();
          }
          // Ordena por pontos e pega os top 5
          jogadoresFiltrados.sort((a, b) => b.pontosFantasy.compareTo(a.pontosFantasy));
          doClube = jogadoresFiltrados.take(5).toList();
        }
      
      setState(() {
        topLiga = liga;
        topClube = doClube;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Brasileirão Statistics"),
        actions: [
          if (clube != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sports_soccer, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    clube!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtros
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Filtros",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                                  ),
                                  items: List.generate(38, (i) => i + 1)
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text("Rodada $r"),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => rodada = value);
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
                                  onChanged: (value) {
                                    setState(() => posicao = value);
                                    _carregar();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Top 5 da Liga
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text(
                                "Top 5 da Liga",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Rodada $rodada",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          if (topLiga.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Nenhum dado disponível",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...topLiga.asMap().entries.map((entry) {
                              final index = entry.key;
                              final player = entry.value;
                              return ListTile(
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
                                    fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(player.posicao),
                                trailing: Text(
                                  "${player.pontosFantasy.toStringAsFixed(1)} pts",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),

                  if (clube != null) const SizedBox(height: 20),

                  // Top 5 do Clube
                  if (clube != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flag, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Top 5 do $clube",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            if (topClube.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  "Nenhum jogador encontrado",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ...topClube.asMap().entries.map((entry) {
                                final player = entry.value;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getPositionColor(player.posicao),
                                    child: Text(
                                      player.posicao.substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(player.apelido),
                                  subtitle: Text(player.posicao),
                                  trailing: Text(
                                    "${player.pontosFantasy.toStringAsFixed(1)} pts",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Gráfico de Gols vs Assistências 
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.sports_soccer, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Gols vs Assistências",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Comparação entre os principais jogadores",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const GolsAssistenciasChart(limiteTop: 10),
                          const SizedBox(height: 8),
                          const Text(
                            "Gols (vermelho) vs Assistências (azul) dos top 10 jogadores",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gráfico de Evolução
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                "Evolução Top 3",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(
                            height: 250,
                            child: EvolucaoTop3Chart(),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Evolução dos 3 melhores jogadores na temporada",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break; 
          case 1:
            Navigator.pushNamed(context, '/players');
            break;
          case 2:
            Navigator.pushNamed(context, '/rankings');
            break;
          case 3:
            Navigator.pushNamed(context, '/comparison');
            break;
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1A237E),
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Jogadores",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Rankings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: "Comparar",
        ),
      ],
    );
  }
}