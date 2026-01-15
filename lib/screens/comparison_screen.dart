import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/comparison.dart';
import '../models/player.dart';
import '../models/scout.dart';
import '../models/player_search.dart'; 

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
  
  // Variáveis para busca
  bool isSearching = false;
  List<PlayerSearch> searchResults1 = [];
  List<PlayerSearch> searchResults2 = [];
  TextEditingController searchController1 = TextEditingController();
  TextEditingController searchController2 = TextEditingController();

  // Método para buscar jogadores
  Future<void> _searchPlayers(String query, int playerNumber) async {
    if (query.length < 2) {
      if (playerNumber == 1) {
        setState(() {
          searchResults1.clear();
          isSearching = false;
        });
      } else {
        setState(() {
          searchResults2.clear();
          isSearching = false;
        });
      }
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final results = await service.searchPlayersByName(query);
      
      if (playerNumber == 1) {
        setState(() {
          searchResults1 = results;
          isSearching = false;
        });
      } else {
        setState(() {
          searchResults2 = results;
          isSearching = false;
        });
      }
    } catch (e) {
      print('Erro na busca: $e');
      setState(() {
        if (playerNumber == 1) {
          searchResults1.clear();
        } else {
          searchResults2.clear();
        }
        isSearching = false;
      });
    }
  }

  // Método para selecionar jogador
  void _selectPlayer(PlayerSearch player, int playerNumber) {
    if (playerNumber == 1) {
      idController1.text = player.id.toString();
      searchController1.text = player.apelido;
      setState(() {
        searchResults1.clear();
      });
    } else {
      idController2.text = player.id.toString();
      searchController2.text = player.apelido;
      setState(() {
        searchResults2.clear();
      });
    }
  }

  // Método para comparar jogadores
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
      final data = await service.getComparison(id1, id2);
      final player1Det = await service.getPlayerDetails(id1);
      final player2Det = await service.getPlayerDetails(id2);
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

  // Widget para campo de busca
  Widget _buildSearchField(
    String label,
    TextEditingController idController,
    TextEditingController searchController,
    List<PlayerSearch> searchResults,
    int playerNumber,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            )),
        const SizedBox(height: 6),
        
        // Campo de busca por nome
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  prefixIcon: Icon(Icons.search, color: color),
                  hintText: 'Buscar por nome...',
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: color),
                          onPressed: () {
                            searchController.clear();
                            if (playerNumber == 1) {
                              setState(() => searchResults1.clear());
                            } else {
                              setState(() => searchResults2.clear());
                            }
                          },
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  _searchPlayers(value, playerNumber);
                },
              ),
              
              // Campo para ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    prefixIcon: Icon(Icons.numbers, color: color),
                    hintText: 'ID do jogador (auto-preenchido)',
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ),
        
        // Resultados da busca
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final player = searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(Icons.person, color: color),
                  ),
                  title: Text(player.apelido),
                  subtitle: Text(
                    '${player.posicao}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPositionColor(player.posicao),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      player.posicao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _selectPlayer(player, playerNumber),
                );
              },
            ),
          ),
        
        if (isSearching && searchController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Buscando...', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparação de Jogadores"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card de Inputs COM BUSCA
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
                    
                    // Busca Jogador 1
                    _buildSearchField(
                      "Buscar Jogador 1",
                      idController1,
                      searchController1,
                      searchResults1,
                      1,
                      Colors.blue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // VS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "VS",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Busca Jogador 2
                    _buildSearchField(
                      "Buscar Jogador 2",
                      idController2,
                      searchController2,
                      searchResults2,
                      2,
                      Colors.red,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botão Comparar
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
                    
                    // Dica
                    const SizedBox(height: 12),
                    const Text(
                      'Digite o nome do jogador para buscar automaticamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resultados
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Carregando comparação...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else if (comp == null || player1Details == null || player2Details == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
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
                      'Busque jogadores e clique em comparar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
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
                  if (scout1 != null && scout2 != null)
                    _buildScoutComparison(),
                  
                  // Espaço extra no final para rolar melhor
                  const SizedBox(height: 40),
                ],
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("$value1 vs $value2",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
              child: Text("VS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      fontSize: 10)),
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

  Widget _buildComparisonCard(
      Player player, Player playerDetails, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
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
                  child: Icon(Icons.person, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold)),
                    Text(player.apelido,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (playerDetails.clube != null &&
                        playerDetails.clube!.isNotEmpty)
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

            // Gráficos principais
            _buildScoutComparisonChart("Gols", scout1!.gols, scout2!.gols),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Assistências", scout1!.assistencias, scout2!.assistencias),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Desarmes", scout1!.desarmes, scout2!.desarmes),
            const SizedBox(height: 12),
            _buildScoutComparisonChart("Finalizações", scout1!.finalizacoesTotais, scout2!.finalizacoesTotais),

            const SizedBox(height: 20),
            const Text(
              "Outras Estatísticas (Gráfico de Faltas)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),

            // Dois gráficos lado a lado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildFaltasChart(
                    "Jogador 1",
                    scout1!.faltasCometidas,
                    scout1!.faltasSofridas,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFaltasChart(
                    "Jogador 2",
                    scout2!.faltasCometidas,
                    scout2!.faltasSofridas,
                    Colors.red,
                  ),
                ),
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

  /// Gráfico de barras verticais para faltas cometidas vs sofridas
  Widget _buildFaltasChart(String title, int cometidas, int sofridas, Color color) {
    final maxValue = [cometidas, sofridas].reduce((a, b) => a > b ? a : b);
    final percentCometidas = maxValue > 0 ? cometidas / maxValue : 0.0;
    final percentSofridas = maxValue > 0 ? sofridas / maxValue : 0.0;

    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Barra Faltas Cometidas
            Column(
              children: [
                Text(cometidas.toString(), style: const TextStyle(color: Colors.blue)),
                Container(
                  width: 30,
                  height: 100,
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: percentCometidas,
                    child: Container(color: Colors.blue),
                  ),
                ),
                const Text("Cometidas", style: TextStyle(fontSize: 10)),
              ],
            ),
            const SizedBox(width: 16),
            // Barra Faltas Sofridas
            Column(
              children: [
                Text(sofridas.toString(), style: const TextStyle(color: Colors.red)),
                Container(
                  width: 30,
                  height: 100,
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: percentSofridas,
                    child: Container(color: Colors.red),
                  ),
                ),
                const Text("Sofridas", style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
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