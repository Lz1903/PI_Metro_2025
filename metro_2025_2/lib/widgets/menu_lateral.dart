import 'package:flutter/material.dart';
import 'package:metro_2025_2/telas/tela_estoque.dart';
import 'package:metro_2025_2/telas/tela_pessoas.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../telas/tela_login.dart';
import '../telas/visao_geral.dart';
import '../telas/tela_retirada.dart';
import '../telas/tela_devolucao.dart';
import '../telas/tela_historico.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  Future<void> fazerLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (route) => false,
    );
  }

  Widget _botao(BuildContext context, IconData icon, String title, Widget page) {
    return SizedBox(
      height: 50,
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1780),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text("Você tem certeza que deseja sair da sua conta?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      fazerLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Sair", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1780),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: const Row(
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 20),
            Text(
              "Sair",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Container(
    color: const Color(0xFF1A1780),
    width: 300,
    child: SizedBox.expand(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _botao(context, Icons.house_rounded, "Visão Geral", const VisaoGeral()),
            const SizedBox(height: 30),
            _botao(context, Icons.people_alt, "Pessoas", const TelaPessoas()),
            const SizedBox(height: 30),
            _botao(context, Icons.category, "Estoque", const TelaEstoque()),
            const SizedBox(height: 30),
            _botao(context, Icons.move_up_rounded, "Retirada", const TelaRetirada()),
            const SizedBox(height: 30),
            _botao(context, Icons.move_down_rounded, "Devolução", const TelaDevolucao()),
            const SizedBox(height: 30),
            _botao(context, Icons.history, "Histórico", const TelaHistorico()),
            const SizedBox(height: 30),
            _logoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
  }
}

