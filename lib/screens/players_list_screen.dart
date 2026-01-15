import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/player.dart';
import 'player_detail_screen.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  final service = PlayerService();
  List<Player> jogadores = [];
  String? posicao;
  String? clube;
  String? nome;

  Future<void> _carregar() async {
    final data = await service.getPlayers(clube: clube, posicao: posicao, nome: nome);
    setState(() => jogadores = data);
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jogadores")),
      body: Column(
        children: [
          // Barra de busca e filtro
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: "Buscar por nome"),
                    onSubmitted: (v) {
                      nome = v;
                      _carregar();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: posicao,
                  hint: const Text("Posição"),
                  items: ["GOL", "ZAG", "LAT", "MEI", "ATA"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      posicao = v;
                    });
                    _carregar();
                  },
                ),
              ],
            ),
          ),

          // Lista de jogadores
          Expanded(
            child: ListView.builder(
              itemCount: jogadores.length,
              itemBuilder: (_, i) {
                final Player j = jogadores[i];
                return ListTile(
                  title: Text(j.apelido),
                  subtitle: Text("${j.clube ?? "-"} • ${j.posicao}"),
                  trailing: Text(j.media?.toStringAsFixed(2) ?? "-"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerDetailScreen(id: j.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
