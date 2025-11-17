// ignore_for_file: unused_import

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tela_edicao_material.dart';
import 'tela_inicial_admin.dart';
import 'tela_perfil.dart';

class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoqueState();
}

class _TelaEstoqueState extends State<TelaEstoque> {
  bool isMaterialSelecionado = true;
  String searchQuery = "";
  bool carregando = true;
  List<dynamic> materiais = [];
  List<dynamic> instrumentos = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = isMaterialSelecionado
        ? Uri.parse("http://127.0.0.1:8000/pedidos/listar_materiais")
        : Uri.parse("http://127.0.0.1:8000/pedidos/listar_instrumentos");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);
      setState(() {
        if (isMaterialSelecionado) {
          materiais = dados;
        } else {
          instrumentos = dados;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados: ${response.body}")),
      );
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    final listaAtual = isMaterialSelecionado ? materiais : instrumentos;
    final listaFiltrada = listaAtual.where((item) {
      final nome = item['nome'].toString().toLowerCase();
      final id = item['id'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return nome.contains(query) || id.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: carregarDados,
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
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 15),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text(
                "Estoque",
                style: TextStyle(
                  color: Color(0xFF1A1780),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                ),
                ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isMaterialSelecionado = true;
                            });
                            carregarDados();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMaterialSelecionado ? const Color(0xFF1A1780) : Colors.white,
                            side: const BorderSide(color: Color(0xFF1A1780)),
                          ),
                          child: Text(
                            "Materiais",
                            style: TextStyle(
                                color: isMaterialSelecionado ? Colors.white : const Color(0xFF1A1780)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isMaterialSelecionado = false;
                            });
                            carregarDados();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isMaterialSelecionado ? const Color(0xFF1A1780) : Colors.white,
                            side: const BorderSide(color: Color(0xFF1A1780)),
                          ),
                          child: Text(
                            "Instrumentos",
                            style: TextStyle(
                                color: !isMaterialSelecionado ? Colors.white : const Color(0xFF1A1780)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Buscar por nome ou Código",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1A1780)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1A1780)),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      focusedBorder: const OutlineInputBorder(
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
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            item['nome'],
                            style: const TextStyle(
                                color: Color(0xFF1A1780), fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Código: ${item['id']}  •  Status: ${item['status'] ?? '—'}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TelaEdicaoMaterial(item: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
