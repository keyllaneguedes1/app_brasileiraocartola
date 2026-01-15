import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? clubeSelecionado;

  // Lista de clubes disponíveis
  final List<String> clubes = ["FLA", "PAL", "SAO", "COR", "GRE", "CAM"];

  void _entrar() {
    if (clubeSelecionado != null) {
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: clubeSelecionado,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecione o Clube")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bem-vindo ao Brasileirão Scout!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Dropdown de clubes
            DropdownButtonFormField<String>(
              value: clubeSelecionado,
              items: clubes
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => clubeSelecionado = v),
              decoration: const InputDecoration(
                labelText: "Clube",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Botão de entrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: clubeSelecionado == null ? null : _entrar,
                child: const Text("Entrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
