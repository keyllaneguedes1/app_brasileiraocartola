import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/player_service.dart';

class GolsAssistenciasChart extends StatefulWidget {
  final int limiteTop; // Mudei o nome aqui também
  
  const GolsAssistenciasChart({
    Key? key,
    this.limiteTop = 15,
  }) : super(key: key);

  @override
  _GolsAssistenciasChartState createState() => _GolsAssistenciasChartState();
}

class _GolsAssistenciasChartState extends State<GolsAssistenciasChart> {
  final PlayerService _service = PlayerService();
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  int _limiteAtual = 15;

  @override
  void initState() {
    super.initState();
    _limiteAtual = widget.limiteTop; // Use o novo nome
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _service.getGolsVsAssistencias();
      setState(() {
        _data = List<Map<String, dynamic>>.from(dados);
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar gols vs assistências: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getTopJogadores() {
    if (_data.isEmpty) return [];
    
    final listaOrdenada = List<Map<String, dynamic>>.from(_data);
    listaOrdenada.sort((a, b) {
      final golsA = (a['G'] ?? 0) as num;
      final assistA = (a['A'] ?? 0) as num;
      final totalA = golsA.toDouble() + assistA.toDouble();
      
      final golsB = (b['G'] ?? 0) as num;
      final assistB = (b['A'] ?? 0) as num;
      final totalB = golsB.toDouble() + assistB.toDouble();
      
      return totalB.compareTo(totalA);
    });
    
    return listaOrdenada.take(_limiteAtual).toList();
  }

  double _getValorNumerico(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is int) return valor.toDouble();
    if (valor is double) return valor;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final topJogadores = _getTopJogadores();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚽ Gols vs Assistências',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _limiteAtual,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      onChanged: (int? novoValor) {
                        if (novoValor != null) {
                          setState(() {
                            _limiteAtual = novoValor;
                          });
                        }
                      },
                      items: [10, 15, 20, 25].map((int valor) {
                        return DropdownMenuItem<int>(
                          value: valor,
                          child: Text('Top $valor'),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (topJogadores.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.compare_arrows, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Sem dados disponíveis',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 350,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.white,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final jogador = topJogadores[groupIndex];
                          final nome = jogador['atletas.apelido']?.toString() ?? '';
                          final gols = _getValorNumerico(jogador['G']);
                          final assist = _getValorNumerico(jogador['A']);
                          
                          String label = rodIndex == 0 
                            ? 'Gols: ${gols.toInt()}' 
                            : 'Assistências: ${assist.toInt()}';
                          
                          return BarTooltipItem(
                            '$nome\n$label',
                            const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < topJogadores.length) {
                              final nome = topJogadores[index]['atletas.apelido']?.toString() ?? '';
                              return Text(
                                nome.length > 8 ? '${nome.substring(0, 7)}...' : nome,
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    barGroups: topJogadores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final jogador = entry.value;
                      final gols = _getValorNumerico(jogador['G']);
                      final assist = _getValorNumerico(jogador['A']);
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: gols,
                            width: 12,
                            color: Colors.red,
                          ),
                          BarChartRodData(
                            toY: assist,
                            width: 12,
                            color: Colors.blue,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendaItem(Colors.red, 'Gols'),
                const SizedBox(width: 20),
                _buildLegendaItem(Colors.blue, 'Assistências'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendaItem(Color cor, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}