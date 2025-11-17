// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/tela_inicial.dart';
import 'package:metro_2025_2/tela_inicial_admin.dart';

class TelaLogin extends StatefulWidget{
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = false;

  Future<void> fazerLogin() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("http://127.0.0.1:8000/auth/login"); // use 10.0.2.2 no Android
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // salvar tokens e tipo de usuário localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data["access_token"]);
        await prefs.setBool('is_admin', data["admin"]);
        await prefs.setString('refresh_token', data["refresh_token"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bem-vindo, ${data["nome"] ?? "usuário"}!")),
        );

        // redirecionar conforme o tipo de usuário
        if (data["admin"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaInicialAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaInicial()),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["detail"] ?? "Erro no login")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }

    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    final azulEscuro = const Color(0xFF1A1A8F);
    
    return Scaffold(
      //backgroundColor: const Color(0xFF1A1A8F),
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 450;
        return isMobile ? 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: constraints.maxHeight * 0.35,
              width: constraints.maxWidth,
              color: Color(0xFF1A1780),
              padding: const EdgeInsets.symmetric(vertical: 40),
                child:  Center(
                  child: Image.asset(
                    'assets/imagens/logo_metro_mobile.png',
                    height: 100,
                  ),
                ),
            ),
            Row(
                children: const [
                  Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 10))),
                  Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 10))),
                  Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 10))),
                  Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 10))),
                  Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 10))),
                ],
              ),
            const SizedBox(height: 50),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("E-mail",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: TextStyle(color: Color(0xFF1A1780)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Senha",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: TextStyle(color: Color(0xFF1A1780)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 24),
            Center(
              child:SizedBox(
                width: 180,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1780),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : fazerLogin,
                  child: const Text(
                    "ENTRAR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
        ) : 
        Container(
        color: const Color(0xFF1A1780),
        child:Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8), 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8)
                ),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child:  Center(
                  child: Image.asset(
                    'assets/imagens/logo_metro.png',
                    height: 100,
                  ),
                ),
              ),


              Row(
                children: const [
                  Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 8))),
                ],
              ),

              const SizedBox(height: 24),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: azulEscuro),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: azulEscuro),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: azulEscuro),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(color: azulEscuro),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: azulEscuro),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: azulEscuro),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: 180,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulEscuro,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : fazerLogin,
                  child: const Text(
                    "ENTRAR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      );
      },
      ),
    );
  }
}
