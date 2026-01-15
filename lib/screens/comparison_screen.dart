import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/comparison.dart';
import '../models/player.dart';
import '../models/scout.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final service = PlayerService();
  final idController1 = TextEditingController(text: "94968");
  final idController2 = TextEditingController(text: "87863");
  Comparison? comp;
  Player? player1Details;
  Player? player2Details;
  Scout? scout1;
  Scout? scout2;
  bool isLoading = false;

  Future<void> _comparar() async {
    final id1 = int.tryParse(idController1.text);
    final id2 = int.tryParse(idController2.text);
    if (id1 == null || id2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira IDs válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // Busca comparação básica
      final data = await service.getComparison(id1, id2);
      
      // Busca detalhes completos de cada jogador para obter o clube
      final player1Det = await service.getPlayerDetails(id1);
      final player2Det = await service.getPlayerDetails(id2);
      
      // Busca scouts detalhados
      final scouts1Data = await service.getPlayerScoutsDetalhado(id1);
      final scouts2Data = await service.getPlayerScoutsDetalhado(id2);
      
      setState(() {
        comp = data;
        player1Details = player1Det;
        player2Details = player2Det;
        scout1 = Scout.fromDetalhadoJson(scouts1Data);
        scout2 = Scout.fromDetalhadoJson(scouts2Data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao comparar: $e'),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _comparar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparação de Jogadores"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card de Inputs
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.compare_arrows, color: Color(0xFF1A237E)),
                        SizedBox(width: 8),
                        Text(
                          "Comparar Jogadores",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            "ID Jogador 1",
                            idController1,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "VS",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            "ID Jogador 2",
                            idController2,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _comparar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.compare, size: 20),
                        label: Text(
                          isLoading ? 'Comparando...' : 'Comparar Jogadores',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resultados
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1A237E)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Carregando comparação...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : comp == null || player1Details == null || player2Details == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.compare_arrows,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Insira os IDs e clique em comparar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildComparisonCard(
                                comp!.jogador1.first,
                                player1Details!,
                                "Jogador 1",
                                Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildComparisonCard(
                                comp!.jogador2.first,
                                player2Details!,
                                "Jogador 2",
                                Colors.red,
                              ),
                              const SizedBox(height: 16),
                              _buildComparisonStats(),
                              const SizedBox(height: 16),
                              if (scout1 != null && scout2 != null)
                                _buildScoutComparison(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              prefixIcon: Icon(
                Icons.person,
                color: color,
              ),
            ),
            style: const TextStyle(fontSize: 16),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(Player player, Player playerDetails, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.person,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          player.apelido,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (playerDetails.clube != null && playerDetails.clube!.isNotEmpty)
                          Text(
                            playerDetails.clube!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPositionColor(player.posicao),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    player.posicao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard("Clube", playerDetails.clube ?? "-", Icons.sports),
                _buildStatCard(
                  "Pontos",
                  player.pontosFantasy.toStringAsFixed(1),
                  Icons.leaderboard,
                ),
                _buildStatCard(
                  "Média",
                  player.media?.toStringAsFixed(2) ?? "-",
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildComparisonStats() {
    if (comp == null || comp!.jogador1.isEmpty || comp!.jogador2.isEmpty) {
      return const SizedBox();
    }

    final p1 = comp!.jogador1.first;
    final p2 = comp!.jogador2.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF1A237E)),
                SizedBox(width: 8),
                Text(
                  "Análise Comparativa Básica",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              "Pontos Fantasy",
              p1.pontosFantasy,
              p2.pontosFantasy,
              isHigherBetter: true,
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              "Média",
              p1.media ?? 0,
              p2.media ?? 0,
              isHigherBetter: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoutComparison() {
    if (scout1 == null || scout2 == null) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Color(0xFF1A237E)),
                SizedBox(width: 8),
                Text(
                  "Análise de Scouts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Gráfico de barras comparativo
            _buildScoutComparisonChart("Gols", scout1!.gols, scout2!.gols),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Assistências", scout1!.assistencias, scout2!.assistencias),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Desarmes", scout1!.desarmes, scout2!.desarmes),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Finalizações", scout1!.finalizacoesTotais, scout2!.finalizacoesTotais),
            
            // Estatísticas extras
            const SizedBox(height: 20),
            const Text(
              "Outras Estatísticas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildScoutComparisonItem("Faltas Cometidas", scout1!.faltasCometidas, scout2!.faltasCometidas),
                _buildScoutComparisonItem("Faltas Sofridas", scout1!.faltasSofridas, scout2!.faltasSofridas),
                if (scout1!.posicao == "GOL" || scout2!.posicao == "GOL")
                  _buildScoutComparisonItem("Defesas Difíceis", scout1!.defesasDificeis, scout2!.defesasDificeis),
                if (scout1!.posicao == "GOL" || scout2!.posicao == "GOL")
                  _buildScoutComparisonItem("Jogos sem Gol", scout1!.jogosSemGol, scout2!.jogosSemGol),
              ],
            ),
            
            // Eficiência comparativa
            const SizedBox(height: 20),
            const Text(
              "Eficiência de Ataque",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        scout1!.eficienciaAtaqueFormatada,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: scout1!.eficienciaAtaque.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Jogador 1",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        scout2!.eficienciaAtaqueFormatada,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: scout2!.eficienciaAtaque.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Jogador 2",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Resumo
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, size: 16, color: Color(0xFF1A237E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Baseado em ${scout1!.totalRodadas} rodadas do J1 e ${scout2!.totalRodadas} rodadas do J2",
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
    );
  }

  Widget _buildScoutComparisonChart(String label, int value1, int value2) {
    final maxValue = [value1, value2].reduce((a, b) => a > b ? a : b);
    final percent1 = maxValue > 0 ? value1 / maxValue : 0.0;
    final percent2 = maxValue > 0 ? value2 / maxValue : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "$value1 vs $value2",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: FractionallySizedBox(
                  widthFactor: percent1,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value1.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                "VS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: FractionallySizedBox(
                  widthFactor: percent2,
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value2.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoutComparisonItem(String label, int value1, int value2) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value1.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "vs",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value2.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    double value1,
    double value2, {
    required bool isHigherBetter,
  }) {
    final diff = value1 - value2;
    final isP1Better = isHigherBetter ? diff > 0 : diff < 0;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isP1Better ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                value1.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isP1Better ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            diff >= 0 ? "+${diff.toStringAsFixed(1)}" : diff.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: diff > 0
                  ? Colors.green
                  : diff < 0
                      ? Colors.red
                      : Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: !isP1Better ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                value2.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isP1Better ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
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
}