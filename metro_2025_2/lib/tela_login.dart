import 'package:flutter/material.dart';

class TelaLogin extends StatelessWidget{
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final azulEscuro = const Color(0xFF1A1A8F);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A8F),
      body: Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8), 
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
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

              // Faixa colorida
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

              // Campo Usuário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Usuário",
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

              // Campo Senha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
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

              // Botão Entrar
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
                  onPressed: () {},
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
  }
}