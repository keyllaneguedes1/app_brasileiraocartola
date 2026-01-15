import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/players_list_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/comparison_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/ranking_temporada_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brasileirão Scout",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Configuração básica de cores
        primaryColor: const Color(0xFF1A237E),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF00B0FF),
          background: Color(0xFFF5F5F5),
          surface: Colors.white,
        ),
        
        // Configurações de componentes
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        
        // AppBar
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1A237E),
          elevation: 4,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        
        
        // Inputs
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFF00B0FF)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        
        // Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            elevation: 3,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        
        // Textos
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
          displayMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF424242),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/players': (_) => const PlayersListScreen(),
        '/rankings': (_) => const RankingScreen(),
        '/ranking-temporada': (_) => const RankingTemporadaScreen(),
        '/comparison': (_) => const ComparisonScreen(),
      },
    );
  }
}