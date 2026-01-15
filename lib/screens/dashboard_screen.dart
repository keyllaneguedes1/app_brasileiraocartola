import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/evolucao_top3_chart.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clube = ModalRoute.of(context)?.settings.arguments as String?;
    _carregar();
  }

  Future<void> _carregar() async {
    final liga = await service.getRankingRodada(rodada, limite: 5, posicao: posicao);
    final doClube = clube != null
        ? await service.getRankingRodada(rodada, limite: 5, posicao: posicao, clube: clube)
        : <Player>[];
    setState(() {
      topLiga = liga;
      topClube = doClube;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Filtros
            Row(
              children: [
                DropdownButton<int>(
                  value: rodada,
                  items: List.generate(38, (i) => i + 1)
                      .map((r) => DropdownMenuItem(value: r, child: Text("Rodada $r")))
                      .toList(),
                  onChanged: (v) => setState(() {
                    rodada = v!;
                    _carregar();
                  }),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: posicao,
                  hint: const Text("Posição"),
                  items: ["GOL", "ZAG", "LAT", "MEI", "ATA"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    posicao = v;
                    _carregar();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Conteúdo
            Expanded(
              child: ListView(
                children: [
                  const Text("Top 5 da Liga",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...topLiga.map((Player j) => ListTile(
                        title: Text(j.apelido),
                        subtitle: Text("${j.posicao} • ${j.pontosFantasy} pts"),
                      )),
                  const SizedBox(height: 12),

                  if (clube != null)
                    const Text("Top 5 do Clube",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (clube != null)
                    ...topClube.map((Player j) => ListTile(
                          title: Text(j.apelido),
                          subtitle: Text("${j.posicao} • ${j.pontosFantasy} pts"),
                        )),
                  const SizedBox(height: 12),

                  const Text("Evolução Top 3 (temporada)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 200, child: EvolucaoTop3Chart()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
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
        // ADICIONE ESTAS PROPRIEDADES:
        backgroundColor: Colors.blue, // Cor de fundo
        selectedItemColor: Colors.white, // Cor do item selecionado
        unselectedItemColor: Colors.white70, // Cor dos itens não selecionados
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Estilo do label selecionado
        showSelectedLabels: true, // Mostrar labels dos selecionados
        showUnselectedLabels: true, // Mostrar labels dos não selecionados
        type: BottomNavigationBarType.fixed, // Para mais de 3 itens
        
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
      ),
    );
  }
}
