import 'package:flutter/material.dart';

class TelaInicialAdmin extends StatelessWidget {
  const TelaInicialAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
          ),
        ],
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
      drawer: const Drawer(backgroundColor: Color(0xFF1A1780)),
      body: LayoutBuilder(
        builder: (context, constraints) {

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:Container(
                          height: constraints.maxHeight * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text("Bem-vindo Admin",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                            color: Color(0xFF1A1780),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            ),
                          ),
                        ), 
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        width: constraints.maxWidth * 0.3,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Visualizar estoque',
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
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Container(
                        height: constraints.maxHeight * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text("Relatórios e gráficos",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                            color: Color(0xFF1A1780),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            ),
                          ),
                      ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        width: constraints.maxWidth * 0.2,
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
                      const SizedBox(width: 10),
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        width: constraints.maxWidth * 0.2,
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
                ),
                Padding(padding: const EdgeInsets.all(16),
                  child:Container(
                    height: constraints.maxHeight * 0.25,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Text("Retiradas Recentes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1A1780),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}