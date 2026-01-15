import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/players_list_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/comparison_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brasileirão Scout",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/players': (_) => const PlayersListScreen(),
        '/rankings': (_) => const RankingScreen(),
        '/comparison': (_) => const ComparisonScreen(),
      },
    );
  }
}
