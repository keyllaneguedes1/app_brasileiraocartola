import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/comparison.dart';
import '../models/player.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final service = PlayerService();
  final idController1 = TextEditingController(text: "94968"); // exemplo
  final idController2 = TextEditingController(text: "87863"); // exemplo
  Comparison? comp;

  Future<void> _comparar() async {
    final id1 = int.tryParse(idController1.text);
    final id2 = int.tryParse(idController2.text);
    if (id1 == null || id2 == null) return;

    final data = await service.getComparison(id1, id2);
    setState(() => comp = data);
  }

  @override
  void initState() {
    super.initState();
    _comparar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comparação de Jogadores")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Inputs para IDs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: idController1,
                    decoration: const InputDecoration(labelText: "ID Jogador 1"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: idController2,
                    decoration: const InputDecoration(labelText: "ID Jogador 2"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _comparar, child: const Text("Comparar")),
              ],
            ),
            const SizedBox(height: 12),

            // Resultado
            if (comp == null)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (comp != null)
              Expanded(
                child: ListView(
                  children: [
                    _buildPlayerCard(comp!.jogador1.first, "Jogador 1"),
                    const Divider(),
                    _buildPlayerCard(comp!.jogador2.first, "Jogador 2"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player, String titulo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Nome: ${player.apelido}"),
            Text("Clube: ${player.clube ?? "-"}"),
            Text("Posição: ${player.posicao}"),
            Text("Média: ${player.media?.toStringAsFixed(2) ?? "-"}"),
            Text("Pontos Fantasy: ${player.pontosFantasy}"),
          ],
        ),
      ),
    );
  }
}
