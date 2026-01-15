import 'package:flutter/material.dart';
import '../services/player_service.dart';

class ScoutsScreen extends StatefulWidget {
  const ScoutsScreen({Key? key}) : super(key: key);

  @override
  _ScoutsScreenState createState() => _ScoutsScreenState();
}

class _ScoutsScreenState extends State<ScoutsScreen> {
  final PlayerService _service = PlayerService();
  
  // Estado dos filtros
  int? _rodada;
  String? _posicao;
  String? _clube;
  int _limite = 10;
  
  // Dados scouts
  List<Map<String, dynamic>> _assistencias = [];
  List<Map<String, dynamic>> _gols = [];
  List<Map<String, dynamic>> _desarmes = [];
  List<Map<String, dynamic>> _finalizacoesPerigosas = [];
  List<Map<String, dynamic>> _faltasSofridas = [];
  List<Map<String, dynamic>> _faltasCometidas = [];
  List<Map<String, dynamic>> _defesasDificies = [];
  List<Map<String, dynamic>> _penaltisDefendidos = [];
  List<Map<String, dynamic>> _jogosSemGol = [];
  
  bool _isLoading = true;
  int _selectedCategory = 0;
  
  // Categorias de scouts
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Ataque',
      'icon': Icons.sports_soccer,
      'color': Colors.red,
      'scouts': ['Gols', 'Assistências', 'Finalizações Perigosas', 'Faltas Sofridas']
    },
    {
      'title': 'Defesa',
      'icon': Icons.shield,
      'color': Colors.blue,
      'scouts': ['Desarmes', 'Faltas Cometidas', 'Jogos sem Gol']
    },
    {
      'title': 'Goleiros',
      'icon': Icons.sports_handball,
      'color': Colors.orange,
      'scouts': ['Defesas Difíceis', 'Pênaltis Defendidos']
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadScouts();
  }

  Future<void> _loadScouts() async {
    setState(() => _isLoading = true);
    
    try {
      // Carrega todos os scouts em paralelo
      await Future.wait([
        _loadTopScout('assistencias'),
        _loadTopScout('gols'),
        _loadTopScout('desarmes'),
        _loadTopScout('finalizacoes-perigosas'),
        _loadTopScout('faltas-sofridas'),
        _loadTopScout('faltas-cometidas'),
        _loadTopScout('defesas-dificeis'),
        _loadTopScout('penaltis-defendidos'),
        _loadTopScout('jogos-sem-gol'),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar scouts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTopScout(String type) async {
    try {
      final data = await _service.getTopScout(
        type: type,
        rodada: _rodada,
        limite: _limite,
        posicao: _posicao,
        clube: _clube,
      );
      
      setState(() {
        switch (type) {
          case 'assistencias':
            _assistencias = data;
            break;
          case 'gols':
            _gols = data;
            break;
          case 'desarmes':
            _desarmes = data;
            break;
          case 'finalizacoes-perigosas':
            _finalizacoesPerigosas = data;
            break;
          case 'faltas-sofridas':
            _faltasSofridas = data;
            break;
          case 'faltas-cometidas':
            _faltasCometidas = data;
            break;
          case 'defesas-dificeis':
            _defesasDificies = data;
            break;
          case 'penaltis-defendidos':
            _penaltisDefendidos = data;
            break;
          case 'jogos-sem-gol':
            _jogosSemGol = data;
            break;
        }
      });
    } catch (e) {
      print('Erro ao carregar $type: $e');
    }
  }

  List<Map<String, dynamic>> _getCurrentScoutList() {
    final category = _categories[_selectedCategory];
    final scoutName = category['scouts'][_selectedSubCategory];
    
    switch (scoutName) {
      case 'Assistências':
        return _assistencias;
      case 'Gols':
        return _gols;
      case 'Desarmes':
        return _desarmes;
      case 'Finalizações Perigosas':
        return _finalizacoesPerigosas;
      case 'Faltas Sofridas':
        return _faltasSofridas;
      case 'Faltas Cometidas':
        return _faltasCometidas;
      case 'Defesas Difíceis':
        return _defesasDificies;
      case 'Pênaltis Defendidos':
        return _penaltisDefendidos;
      case 'Jogos sem Gol':
        return _jogosSemGol;
      default:
        return [];
    }
  }

  String _getScoutColumnName(String scoutName) {
    switch (scoutName) {
      case 'Assistências':
        return 'A';
      case 'Gols':
        return 'G';
      case 'Desarmes':
        return 'DS';
      case 'Finalizações Perigosas':
        return 'Finalizacoes_Perigosas';
      case 'Faltas Sofridas':
        return 'FS';
      case 'Faltas Cometidas':
        return 'FC';
      case 'Defesas Difíceis':
        return 'DE';
      case 'Pênaltis Defendidos':
        return 'DP';
      case 'Jogos sem Gol':
        return 'SG';
      default:
        return 'pontos';
    }
  }

  Widget _buildScoutCard(Map<String, dynamic> scout, int index, String scoutName) {
    final columnName = _getScoutColumnName(scoutName);
    final value = scout[columnName] ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRankColor(index),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          scout['atletas.apelido'] ?? 'N/A',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              scoutName.split(' ').first,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros de Scouts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            
            // Filtro de rodada
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Rodada (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'Ex: 1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _rodada = int.tryParse(value);
                } else {
                  _rodada = null;
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Botão aplicar filtros
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadScouts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Aplicar Filtros',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _selectedSubCategory = 0;

  @override
  Widget build(BuildContext context) {
    final currentCategory = _categories[_selectedCategory];
    final currentScoutList = _getCurrentScoutList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scouts Detalhados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScouts,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Card de filtros
          _buildFilterCard(),
          
          // Categorias horizontais
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = index == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category['icon'], size: 18),
                        const SizedBox(width: 6),
                        Text(category['title']),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: (category['color'] as Color).withOpacity(0.2),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? category['color'] : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = index;
                        _selectedSubCategory = 0;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Subcategorias (scouts específicos)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (currentCategory['scouts'] as List).length,
                itemBuilder: (context, index) {
                  final scoutName = (currentCategory['scouts'] as List)[index];
                  final isSelected = index == _selectedSubCategory;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(scoutName),
                      selected: isSelected,
                      selectedColor: (currentCategory['color'] as Color).withOpacity(0.3),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? currentCategory['color'] : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedSubCategory = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Carregando scouts...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : currentScoutList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum dado encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tente ajustar os filtros',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: currentScoutList.length,
                        itemBuilder: (context, index) {
                          final scoutName = (currentCategory['scouts'] as List)[_selectedSubCategory];
                          return _buildScoutCard(
                            currentScoutList[index],
                            index,
                            scoutName,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // Ouro
    if (index == 1) return const Color(0xFFC0C0C0); // Prata
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF1A237E); // Azul padrão
  }

  Color _getCategoryColor() {
    return _categories[_selectedCategory]['color'];
  }
}