// ignore_for_file: unused_import

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:metro_2025_2/tela_edicao_material.dart';
import 'package:metro_2025_2/tela_inicial_admin.dart';
import 'package:metro_2025_2/tela_perfil.dart';
import 'tela_comfirmacao_retirada.dart';
import 'package:metro_2025_2/tela_inicial.dart';

class TelaEstoque extends StatefulWidget{
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoque();
}

class _TelaEstoque extends State<TelaEstoque> {
  bool isMaterialSelecionado = true;
  String searchQuery = "";

  final List<Map<String, dynamic>> materiais = [
    {"nome": "Cabo HDMI", "codigo": "MAT-001", "saldo": 12, "base": "ABC"},
    {"nome": "Fonte 12V", "codigo": "MAT-002", "saldo": 8, "base": "XYZ"},
    {"nome": "Adaptador", "codigo": "MAT-003", "saldo": 5, "base": "DEF"},
  ];

  final List<Map<String, dynamic>> instrumentos = [
    {"nome": "Multímetro", "codigo": "INS-001", "saldo": 3, "base": "ABC"},
    {"nome": "Lanterna", "codigo": "INS-002", "saldo": 7, "base": "XYZ"},
    {"nome": "Alinhador Lazer", "codigo": "INS-003", "saldo": 2, "base": "DEF"},
  ];

  @override
  Widget build(BuildContext context) {
    final listaAtual = isMaterialSelecionado ? materiais : instrumentos;

    final listaFiltrada = listaAtual.where((item) {
      final nome = item['nome'].toString().toLowerCase();
      final codigo = item['codigo'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return nome.contains(query) || codigo.contains(query);
    }).toList();

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "Estoque",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMaterialSelecionado = true;
                          searchQuery = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMaterialSelecionado
                          ? const Color(0xFF1A1780)
                          : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF1A1780)),
                        ),
                      ),
                      child: AutoSizeText(
                        "Material",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isMaterialSelecionado
                            ? Colors.white
                            : const Color(0xFF1A1780),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMaterialSelecionado = false;
                          searchQuery = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isMaterialSelecionado
                          ? const Color(0xFF1A1780)
                          : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                          side: const BorderSide(color: Color(0xFF1A1780)),
                        ),
                      ),
                      child: AutoSizeText(
                        "Instrumento",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: !isMaterialSelecionado
                            ? Colors.white
                            : const Color(0xFF1A1780),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Buscar por nome ou código",
                hintStyle: const TextStyle(color: Color(0xFF1A1780)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A1780)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A1780)),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A1780)),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final item = listaFiltrada[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: Text(
                      item['nome'],
                      style: const TextStyle(
                        color: Color(0xFF1A1780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item['codigo'],
                      style: const TextStyle(color: Color(0xFF1A1780)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaEdicaoMaterial(item: item),
                        ),
                      );
                    }
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}