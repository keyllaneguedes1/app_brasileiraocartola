import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/player_service.dart';
import '../models/round.dart';

class EvolucaoTop3Chart extends StatefulWidget {
  const EvolucaoTop3Chart({super.key});

  @override
  State<EvolucaoTop3Chart> createState() => _EvolucaoTop3ChartState();
}

class _EvolucaoTop3ChartState extends State<EvolucaoTop3Chart> {
  final service = PlayerService();
  List<Round> arr = [];
  List<Round> mat = [];
  List<Round> kai = [];
  bool isLoading = true;

  Future<void> _load() async {
    setState(() => isLoading = true);
    
    try {
      final d = await service.evolucaoTop3(limiteRodadas: 38);
      
      // Organiza os dados por jogador
      final Map<String, List<Round>> dadosPorJogador = {};
      
      for (var item in d) {
        final nome = item["atletas.apelido"];
        if (nome == null) continue;
        
        if (!dadosPorJogador.containsKey(nome)) {
          dadosPorJogador[nome] = [];
        }
        
        dadosPorJogador[nome]!.add(Round.fromJson(item));
      }
      
      // Ordena por rodada para cada jogador
      dadosPorJogador.forEach((nome, rodadas) {
        rodadas.sort((a, b) => a.rodadaId.compareTo(b.rodadaId));
      });
      
      setState(() {
        arr = dadosPorJogador["Arrascaeta"] ?? [];
        mat = dadosPorJogador["Matheus Pereira"] ?? [];
        kai = dadosPorJogador["Kaio Jorge"] ?? [];
      });
    } catch (e) {
      print('Erro ao carregar gráfico: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<FlSpot> toSpots(List<Round> series) {
    if (series.isEmpty) return [];
    
    // Ordena por rodada para garantir a ordem correta
    final sorted = List<Round>.from(series)
      ..sort((a, b) => a.rodadaId.compareTo(b.rodadaId));
    
    return sorted
        .map((r) => FlSpot(r.rodadaId.toDouble(), r.pontosFantasy))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Carregando gráfico...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final hasArr = arr.isNotEmpty;
    final hasMat = mat.isNotEmpty;
    final hasKai = kai.isNotEmpty;

    if (!hasArr && !hasMat && !hasKai) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Dados não disponíveis',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Cria lista de dados das séries
    final seriesData = <Map<String, dynamic>>[];
    if (hasArr) {
      seriesData.add({
        'nome': 'Arrascaeta',
        'cor': const Color(0xFF00B0FF),
        'spots': toSpots(arr),
      });
    }
    if (hasMat) {
      seriesData.add({
        'nome': 'Matheus Pereira',
        'cor': const Color(0xFF4CAF50),
        'spots': toSpots(mat),
      });
    }
    if (hasKai) {
      seriesData.add({
        'nome': 'Kaio Jorge',
        'cor': const Color(0xFFFF9800),
        'spots': toSpots(kai),
      });
    }

    return Column(
      children: [
        // Legenda
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: seriesData.map((serie) {
              return _buildLegendItem(serie['nome'] as String, serie['cor'] as Color);
            }).toList(),
          ),
        ),
        
        // Gráfico
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 4,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        // Encontra a série correspondente
                        String jogadorNome = 'Jogador';
                        for (var i = 0; i < seriesData.length; i++) {
                          final serie = seriesData[i];
                          final spots = serie['spots'] as List<FlSpot>;
                          if (spots.any((spot) => spot.x == touchedSpot.x && spot.y == touchedSpot.y)) {
                            jogadorNome = serie['nome'] as String;
                            break;
                          }
                        }
                        
                        return LineTooltipItem(
                          '$jogadorNome\nRodada ${touchedSpot.x.toInt()}\n${touchedSpot.y.toStringAsFixed(1)} pts',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: seriesData.map((serie) {
                  return LineChartBarData(
                    spots: serie['spots'] as List<FlSpot>,
                    isCurved: true,
                    color: serie['cor'] as Color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getYInterval(),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _getXInterval(),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _getYInterval(),
                  verticalInterval: _getXInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200.withOpacity(0.5),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                minX: _getMinX(),
                maxX: _getMaxX(),
                minY: 0,
                maxY: _getMaxY(),
              ),
            ),
          ),
        ),
        
        // Rótulos dos eixos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rodada',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Pontos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String nome, Color cor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          nome,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  double _getMinX() {
    final todasRodadas = [...arr, ...mat, ...kai];
    if (todasRodadas.isEmpty) return 1;
    
    final minRodada = todasRodadas
        .map((r) => r.rodadaId)
        .reduce((a, b) => a < b ? a : b);
    return minRodada.toDouble();
  }

  double _getMaxX() {
    final todasRodadas = [...arr, ...mat, ...kai];
    if (todasRodadas.isEmpty) return 38;
    
    final maxRodada = todasRodadas
        .map((r) => r.rodadaId)
        .reduce((a, b) => a > b ? a : b);
    return maxRodada.toDouble();
  }

  double _getMaxY() {
    final allValues = [
      ...arr.map((e) => e.pontosFantasy),
      ...mat.map((e) => e.pontosFantasy),
      ...kai.map((e) => e.pontosFantasy),
    ];
    
    if (allValues.isEmpty) return 20;
    
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  double _getYInterval() {
    final maxY = _getMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 40) return 10;
    return 15;
  }

  double _getXInterval() {
    final minX = _getMinX();
    final maxX = _getMaxX();
    final range = maxX - minX;
    
    if (range <= 10) return 1;
    if (range <= 20) return 2;
    if (range <= 30) return 5;
    return 10;
  }
}