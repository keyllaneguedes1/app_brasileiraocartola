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
  final TextEditingController _searchController = TextEditingController();
  List<Player> jogadores = [];
  List<Player> jogadoresFiltrados = [];
  String? posicao;
  String? clube;
  bool isLoading = true;
  bool isSearching = false;

  Future<void> _carregar() async {
    setState(() => isLoading = true);
    
    try {
      final data = await service.getPlayers(clube: clube, posicao: posicao);
      setState(() {
        jogadores = data;
        jogadoresFiltrados = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar jogadores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filtrar() {
    final termo = _searchController.text.trim().toLowerCase();
    
    if (termo.isEmpty) {
      setState(() {
        jogadoresFiltrados = jogadores;
        isSearching = false;
      });
    } else {
      setState(() {
        jogadoresFiltrados = jogadores.where((jogador) {
          return jogador.apelido.toLowerCase().contains(termo);
        }).toList();
        isSearching = true;
      });
    }
  }

  void _limparBusca() {
    _searchController.clear();
    setState(() {
      jogadoresFiltrados = jogadores;
      isSearching = false;
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
      appBar: AppBar(
        title: const Text("Jogadores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
            tooltip: "Recarregar",
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca e filtro
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: "Buscar por nome",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: isSearching
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: _limparBusca,
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _filtrar(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _filtrar,
                        icon: const Icon(Icons.search, size: 20),
                        label: const Text("Buscar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
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
                          onChanged: (v) {
                            setState(() => posicao = v);
                            _carregar();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Indicador de busca
          if (isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Resultados para: ${_searchController.text}",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: _limparBusca,
                    child: const Text("Limpar"),
                  ),
                ],
              ),
            ),

          // Lista de jogadores
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : jogadoresFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              isSearching
                                  ? "Nenhum jogador encontrado para '${_searchController.text}'"
                                  : "Nenhum jogador encontrado",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isSearching)
                              TextButton(
                                onPressed: _limparBusca,
                                child: const Text("Limpar busca"),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: jogadoresFiltrados.length,
                        itemBuilder: (_, i) {
                          final Player j = jogadoresFiltrados[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getPositionColor(j.posicao),
                                child: Text(
                                  j.posicao.isNotEmpty 
                                      ? j.posicao.substring(0, 1)
                                      : "?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                j.apelido,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text("${j.posicao}"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${j.pontosFantasy.toStringAsFixed(1)} pts",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (j.media != null)
                                    Text(
                                      "Média: ${j.media!.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerDetailScreen(id: j.id),
                                ),
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