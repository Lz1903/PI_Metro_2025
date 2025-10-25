// ignore_for_file: unused_local_variable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TelaRetirada extends StatefulWidget {
  const TelaRetirada({super.key});

  @override
  State<TelaRetirada> createState() => _TelaRetiradaState();
}

class _TelaRetiradaState extends State<TelaRetirada> {
  final TextEditingController _buscaController = TextEditingController();

  final List<Map<String, dynamic>> _itens = [
    {"nome": "Lanterna", "codigo": "LAN-020", "saldo": 32},
    {"nome": "Cabo HDMI", "codigo": "CAB-002", "saldo": 14},
    {"nome": "Multímetro", "codigo": "INS-005", "saldo": 7},
    {"nome": "Fonte 12V", "codigo": "MAT-009", "saldo": 10},
    {"nome": "Adaptador USB", "codigo": "MAT-011", "saldo": 4},
    {"nome": "Chave Philips", "codigo": "FER-004", "saldo": 25},
    {"nome": "Extensão 5m", "codigo": "CAB-008", "saldo": 12},
  ];

  // Lista filtrada
  List<Map<String, dynamic>> _itensFiltrados = [];

  @override
  void initState() {
    super.initState();
    _itensFiltrados = _itens;

    
    _buscaController.addListener(_filtrarItens);
  }

  void _filtrarItens() {
    final texto = _buscaController.text.toLowerCase();
    setState(() {
      _itensFiltrados = _itens.where((item) {
        final nome = item['nome'].toString().toLowerCase();
        final codigo = item['codigo'].toString().toLowerCase();
        return nome.contains(texto) || codigo.contains(texto);
      }).toList();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  "Retirada",
                  style: const TextStyle(
                    color: Color(0xFF1A1780),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Selecionar Base",
                  style: TextStyle(
                    color: Color(0xFF1A1780),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1780),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const AutoSizeText(
                          "Material",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1780),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const AutoSizeText(
                          "Instrumento",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                controller: _buscaController,
                decoration: const InputDecoration(
                  hintText: "Buscar por nome ou código",
                  hintStyle: TextStyle(color: Color(0xFF1A1780)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF1A1780)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1A1780)),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1A1780)),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
                style: const TextStyle(color: Color(0xFF1A1780)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _itensFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum item encontrado",
                        style: TextStyle(color: Color(0xFF1A1780)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _itensFiltrados.length,
                      itemBuilder: (context, index) {
                        final item = _itensFiltrados[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                            trailing: Text(
                              "Saldo: ${item['saldo']}",
                              style: const TextStyle(color: Color(0xFF1A1780)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}