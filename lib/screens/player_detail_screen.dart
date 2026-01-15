import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../models/scout.dart';

class PlayerDetailScreen extends StatefulWidget {
  final int id;
  const PlayerDetailScreen({super.key, required this.id});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  final service = PlayerService();
  Player? jogador;
  List<Round> rodadas = [];
  Map<String, dynamic> stats = {};
  Scout? scout;
  bool isLoading = true;

  Future<void> _carregar() async {
    setState(() => isLoading = true);
    
    try {
      final det = await service.getPlayerDetails(widget.id);
      final hist = await service.getPlayerRounds(widget.id, limite: 10);
      final estatisticas = await service.getPlayerStats(widget.id);
      final scoutsData = await service.getPlayerScoutsDetalhado(widget.id);
      
      setState(() {
        jogador = det;
        rodadas = hist;
        stats = estatisticas;
        scout = Scout.fromDetalhadoJson(scoutsData);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
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
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (jogador == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Jogador não encontrado")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Jogador não encontrado",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(jogador!.apelido),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
            tooltip: "Recarregar dados",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações Básicas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getPositionColor(jogador!.posicao).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _getPositionColor(jogador!.posicao),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              jogador!.posicao.isNotEmpty 
                                  ? jogador!.posicao.substring(0, 1)
                                  : "?",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getPositionColor(jogador!.posicao),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jogador!.apelido,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${jogador!.clube ?? "Clube não informado"} • ${jogador!.posicao}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Estatísticas em linha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Pontos Total", jogador!.pontosFantasy.toStringAsFixed(1)),
                        _buildStatItem("Média", jogador!.media?.toStringAsFixed(2) ?? "-"),
                        _buildStatItem("Rodadas", stats['total_rodadas']?.toString() ?? "0"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Estatísticas Avançadas
            const Text(
              "Estatísticas da Temporada",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatCard(
                  "Média Últimas 5",
                  stats['media_ultimas_5']?.toStringAsFixed(2) ?? "-",
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatCard(
                  "Pontuação Máxima",
                  stats['pontuacao_maxima']?.toStringAsFixed(1) ?? "-",
                  Icons.arrow_upward,
                  Colors.green,
                ),
                _buildStatCard(
                  "Pontuação Mínima",
                  stats['pontuacao_minima']?.toStringAsFixed(1) ?? "-",
                  Icons.arrow_downward,
                  Colors.red,
                ),
                _buildStatCard(
                  "Total de Rodadas",
                  stats['total_rodadas']?.toString() ?? "0",
                  Icons.format_list_numbered,
                  Colors.blue,
                ),
              ],
            ),

            // Scouts Detalhados (se disponível)
            if (scout != null) ...[
              const SizedBox(height: 16),
              const Text(
                "Estatísticas Detalhadas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Estatísticas de Ataque
                      _buildScoutSection(
                        "⚽ Ataque",
                        [
                          _buildScoutItem("Gols", scout!.gols),
                          _buildScoutItem("Assistências", scout!.assistencias),
                          _buildScoutItem("Finalizações", scout!.finalizacoesTotais),
                          _buildScoutItem("Eficiência", scout!.eficienciaAtaqueFormatada),
                        ],
                        Colors.green,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Estatísticas de Defesa/Meio
                      _buildScoutSection(
                        "🛡️ Defesa/Meio",
                        [
                          _buildScoutItem("Desarmes", scout!.desarmes),
                          _buildScoutItem("Faltas Cometidas", scout!.faltasCometidas),
                          _buildScoutItem("Faltas Sofridas", scout!.faltasSofridas),
                          if (scout!.posicao == "GOL") 
                            _buildScoutItem("Defesas Difíceis", scout!.defesasDificeis),
                          if (scout!.posicao == "GOL")
                            _buildScoutItem("Jogos sem Gol", scout!.jogosSemGol),
                        ],
                        Colors.blue,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Estatísticas Específicas por Posição
                      if (scout!.posicao == "GOL") 
                        _buildScoutSection(
                          "🧤 Goleiro",
                          [
                            _buildScoutItem("Pênaltis Defendidos", scout!.penaltisDefendidos),
                            _buildScoutItem("Finalizações Defendidas", scout!.finalizacoesDefendidas),
                            _buildScoutItem("Finalizações na Trave", scout!.finalizacoesTrave),
                          ],
                          Colors.orange,
                        ),
                      
                      if (scout!.posicao == "ATA" || scout!.posicao == "MEI")
                        _buildScoutSection(
                          "🎯 Criação",
                          [
                            _buildScoutItem("Finalizações Perigosas", scout!.finalizacoesDefendidas + scout!.finalizacoesTrave),
                            _buildScoutItem("Assistências por Rodada", (scout!.assistencias / scout!.totalRodadas).toStringAsFixed(2)),
                            _buildScoutItem("Gols por Rodada", (scout!.gols / scout!.totalRodadas).toStringAsFixed(2)),
                          ],
                          Colors.purple,
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Médias por rodada
                      Text(
                        "Médias por rodada:",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: scout!.mediasPorRodada.entries.map((entry) {
                          return Chip(
                            label: Text(
                              "${entry.key}: ${entry.value.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Resumo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Baseado em ${scout!.totalRodadas} rodadas",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Histórico de Rodadas
            const Text(
              "Últimas Rodadas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (rodadas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Nenhuma rodada registrada"),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: rodadas.map((rodada) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPontosColor(rodada.pontosFantasy),
                          child: Text(
                            rodada.pontosFantasy.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          "Rodada ${rodada.rodadaId}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "${rodada.pontosFantasy.toStringAsFixed(1)} pts",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPontosColor(rodada.pontosFantasy),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoutSection(String titulo, List<Widget> itens, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: itens,
        ),
      ],
    );
  }

  Widget _buildScoutItem(String label, dynamic value) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Color _getPontosColor(double pontos) {
    if (pontos >= 8.0) return Colors.green;
    if (pontos >= 6.0) return Colors.lightGreen;
    if (pontos >= 4.0) return Colors.yellow;
    if (pontos >= 2.0) return Colors.orange;
    return Colors.red;
  }
}