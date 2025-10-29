import 'package:flutter/material.dart';

class TelaConfirmacaoRetirada extends StatelessWidget {
  final Map<String, dynamic> item;

  const TelaConfirmacaoRetirada({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10), 
          child: Row(
            children: const [
              Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 10))),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Retirada",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1A1780), width: 2),
                      ),
                    ),
                    child: const Text(
                      "Informações sobre sua retirada",
                      style: TextStyle(
                        color: Color(0xFF1A1780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Intrumento/Material: ${item['nome']}", style: const TextStyle(color: Color(0xFF1A1780))),
                        Text("Código: ${item['codigo']}", style: const TextStyle(color: Color(0xFF1A1780))),
                        const SizedBox(height: 10),
                        Text("Quantidade: 1", style: const TextStyle(color: Color(0xFF1A1780))),
                        Text("Código: ${item['base']}", style: const TextStyle(color: Color(0xFF1A1780))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Data de devolução: 00/00",
                style: TextStyle(
                  color: Color(0xFF1A1780),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Próxima Calibração:",
                style: TextStyle(
                  color: Color(0xFF1A1780),
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item retirado com sucesso!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1780),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Retirar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}