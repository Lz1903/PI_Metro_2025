// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

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
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 450;
      return SingleChildScrollView(
      child:Column(
        children:[ 
          Padding(
            padding: EdgeInsetsGeometry.all(8),
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200, width: 2.0)
                ),
                padding: EdgeInsets.all(8),
                child: AutoSizeText("Bem-vindo usuário",
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
          ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: constraints.maxHeight * 0.42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const AutoSizeText('Histórico de retiradas',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  Column(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        width: isMobile ? constraints.maxWidth * 0.4 : constraints.maxWidth * 0.2,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const AutoSizeText(
                            'Retirada',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            minFontSize: 5,
                            stepGranularity: 0.1,
                            wrapWords: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        width: isMobile ? constraints.maxWidth * 0.4 : constraints.maxWidth * 0.2,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const AutoSizeText(
                            'Devolução',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            minFontSize: 5,
                            stepGranularity: 0.1,
                            wrapWords: false,
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
      },
    ),
    );
  }
}