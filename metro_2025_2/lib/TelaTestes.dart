// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class Telatestes extends StatelessWidget {
  const Telatestes({super.key});

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
                const SizedBox(height: 15),
                Padding(padding: EdgeInsets.symmetric(horizontal:16),
                  child: Container(
                  height: constraints.maxHeight * 0.2,
                  width: constraints.maxWidth,
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
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:16),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.09,
                    width: constraints.maxWidth,
                    child: ElevatedButton(
                    onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1780),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const AutoSizeText(
                        'Visualizar estoque',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                          maxLines: 2,
                          minFontSize: 5,
                          stepGranularity: 0.1,
                          wrapWords: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:16),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.15,
                        width: constraints.maxWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1780),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const AutoSizeText(
                          'Edição de Materiais',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                            maxLines: 3,
                            minFontSize: 5,
                            stepGranularity: 0.1,
                            wrapWords: false,
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:10),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.15,
                        width: constraints.maxWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1780),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const AutoSizeText(
                          'Cadastro de materiais',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                            maxLines: 2,
                            minFontSize: 5,
                            stepGranularity: 0.1,
                            wrapWords: false,
                        ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        height: constraints.maxHeight * 0.4,
                        width: constraints.maxWidth * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: EdgeInsets.all(8),
                        child: AutoSizeText("Retiradas Recentes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1A1780),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        minFontSize: 5,
                        stepGranularity: 0.1,
                        wrapWords: false,
                        ),
                      ),
                      const SizedBox(width: 37),
                      Container(
                        height: constraints.maxHeight * 0.4,
                        width: constraints.maxWidth * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: EdgeInsets.all(8),
                        child: AutoSizeText("Relatórios e Gráficos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1A1780),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 3,
                        minFontSize: 5,
                        stepGranularity: 0.1,
                        wrapWords: false,
                        ),
                      ),
                    ],
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