// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:metro_2025_2/tela_devolucao.dart';
import 'package:metro_2025_2/tela_perfil.dart';
import 'package:metro_2025_2/tela_retirada.dart';

import 'tela_inicial_admin.dart';


class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicial();
}
class _TelaInicial extends State<TelaInicial> {
  

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
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaPerfil()));
            },
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
      drawer: Drawer(
        backgroundColor: Color(0xFF1A1780),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white,),
              title: const Text('Perfil', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaPerfil()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.house_rounded, color: Colors.white,),
              title: const Text('Tela Inicial', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaInicial()));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.house_rounded, color: Colors.white,),
              title: const Text('Tela Inicial', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaInicialAdmin()));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white,),
              title: const Text('Configurações', style: TextStyle(color: Colors.white),),
              onTap: () {
              },
            ),
          ],
        ),
      ),
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
                  border: Border.all(color: Colors.grey.shade200, width: 2.0),
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
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaRetirada()));
                          },
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
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaDevolucao()));
                          },
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