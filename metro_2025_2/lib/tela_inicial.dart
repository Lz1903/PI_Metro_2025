import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar azul superior
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(onPressed: () {}, 
          icon: Icon(Icons.account_circle_rounded, color: Colors.white,),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1780),
      ),
      // Corpo da tela
      body: Column(
          children: [
            // Faixa colorida abaixo do AppBar
            Row(
              children: [
                Expanded(child: Container(height: 10, color: Colors.blue)),
                Expanded(child: Container(height: 10, color: Colors.green)),
                Expanded(child: Container(height: 10, color: Colors.red)),
                Expanded(child: Container(height: 10, color: Colors.yellow)),
                Expanded(child: Container(height: 10, color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Bem-vindo usuário',
                    style: TextStyle(
                      color: Color(0xFF1A1780),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child:Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(0x331A1780),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                        ),
                        const SizedBox(width: 70),
                        Expanded(
                          child:Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(0x331A1780),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Text('Histórico de retiradas',
                          style: TextStyle(
                            color: Color(0xFF1A1780),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  Column(
                    children: [
                      SizedBox(
                        width: 600,
                        height: 165,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Retirada',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 600,
                        height: 165,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Devolução',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    ); 
  }
}