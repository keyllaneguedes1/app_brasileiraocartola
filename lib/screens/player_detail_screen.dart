import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../models/player.dart';
import '../models/round.dart';

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

  Future<void> _carregar() async {
    final det = await service.getPlayerDetails(widget.id);
    final hist = await service.getPlayerRounds(widget.id, limite: 10);
    setState(() {
      jogador = det;
      rodadas = hist;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    if (jogador == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(jogador!.apelido)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text("Clube: ${jogador!.clube ?? "-"}"),
            Text("Posição: ${jogador!.posicao}"),
            Text("Média temporada: ${jogador!.media?.toStringAsFixed(2) ?? "-"}"),
            Text("Pontos Fantasy acumulados: ${jogador!.pontosFantasy}"),
            const SizedBox(height: 12),

            const Text("Histórico por rodada",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...rodadas.map((Round r) => ListTile(
                  title: Text("Rodada ${r.rodadaId}"),
                  subtitle: Text("Pontos: ${r.pontosFantasy}"),
                )),
          ],
        ),
      ),
    );
  }
}
