// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:metro_2025_2/tela_cadastro_material.dart';
import 'package:metro_2025_2/tela_estoque.dart';
import 'tela_perfil.dart';

class TelaInicialAdmin extends StatefulWidget {
  const TelaInicialAdmin({super.key});

  @override
  State<TelaInicialAdmin> createState() => _TelaInicialAdmin();
}

class _TelaInicialAdmin extends State<TelaInicialAdmin> {

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
      drawer: Drawer(
        backgroundColor: Color(0xFF1A1780),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white,),
              title: const Text('Perfil', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaPerfil()));
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          bool isMobile = width < 450;
          return isMobile ? 
            SingleChildScrollView(
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
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TelaEstoque()));
                    },
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:16),
                      child: SizedBox(
                        height: constraints.maxHeight * 0.1,
                        width: constraints.maxWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaCadastroMaterial()));
                          },
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
          ) :        
          SingleChildScrollView(
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
                        height: constraints.maxHeight * 0.3,
                        width: constraints.maxWidth * 0.3,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaEstoque()));
                          },
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
                        height: constraints.maxHeight * 0.3,
                        width: constraints.maxWidth * 0.2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaCadastroMaterial()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1780),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const AutoSizeText(
                            'Cadastro de Materiais',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            minFontSize: 5,
                            stepGranularity: 0.1,
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