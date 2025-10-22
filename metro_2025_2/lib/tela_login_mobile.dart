import 'package:flutter/material.dart';
import 'package:metro_2025_2/tela_inicial.dart';

class TelaLoginMobile extends StatelessWidget{
  const TelaLoginMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
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
            child: Text("Usuário",
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TelaInicial()),
                    );
                  },
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
        );
      }
      ),
    );
  }
}