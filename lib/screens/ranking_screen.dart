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

  Future<void> _carregar() async {
    final r = await service.getRankingRodada(
      rodada,
      posicao: posicao,
      limite: 10,
    );
    final rc = clube != null
        ? await service.getRankingRodada(
            rodada,
            posicao: posicao,
            clube: clube,
            limite: 10,
          )
        : <Player>[];
    setState(() {
      rankingRodada = r;
      rankingClube = rc;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rankings")),
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
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text("Rodada $r")))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      rodada = v!;
                    });
                    _carregar();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: posicao,
                  hint: const Text("Posição"),
                  items: ["GOL", "ZAG", "LAT", "MEI", "ATA"]
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      posicao = v;
                    });
                    _carregar();
                  },
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: "Clube (opcional)"),
                    onSubmitted: (v) {
                      clube = v.isEmpty ? null : v;
                      _carregar();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ranking da rodada
            const Text("Top 10 da Rodada",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: rankingRodada.length,
                itemBuilder: (_, i) {
                  final Player j = rankingRodada[i];
                  return ListTile(
                    title: Text(j.apelido),
                    subtitle: Text("${j.posicao} • ${j.pontosFantasy} pts"),
                  );
                },
              ),
            ),

            // Ranking do clube
            if (clube != null)
              const Text("Top 10 do Clube",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            if (clube != null)
              Expanded(
                child: ListView.builder(
                  itemCount: rankingClube.length,
                  itemBuilder: (_, i) {
                    final Player j = rankingClube[i];
                    return ListTile(
                      title: Text(j.apelido),
                      subtitle: Text("${j.posicao} • ${j.pontosFantasy} pts"),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
