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

  Future<void> _load() async {
    final d = await service.evolucaoTop3(limiteRodadas: 38);

    // Aqui ainda vem como List<dynamic>, então convertemos para Round
    final arrData = d.where((e) => e["atletas.apelido"] == "Arrascaeta").toList();
    final matData = d.where((e) => e["atletas.apelido"] == "Matheus Pereira").toList();
    final kaiData = d.where((e) => e["atletas.apelido"] == "Kaio Jorge").toList();

    setState(() {
      arr = arrData.map((e) => Round.fromJson(e)).toList();
      mat = matData.map((e) => Round.fromJson(e)).toList();
      kai = kaiData.map((e) => Round.fromJson(e)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<FlSpot> toSpots(List<Round> series) =>
      series.map((r) => FlSpot(r.rodadaId.toDouble(), r.pontosFantasy)).toList();

  @override
  Widget build(BuildContext context) {
    if (arr.isEmpty && mat.isEmpty && kai.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: toSpots(arr),
            isCurved: true,
            color: Colors.red,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: toSpots(mat),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: toSpots(kai),
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
