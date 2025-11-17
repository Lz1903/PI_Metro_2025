import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_inicial.dart';
import 'tela_perfil.dart';

class TelaRetirada extends StatefulWidget {
  const TelaRetirada({super.key});

  @override
  State<TelaRetirada> createState() => _TelaRetiradaState();
}

class _TelaRetiradaState extends State<TelaRetirada> {
  bool isMaterialSelecionado = true;
  String searchQuery = "";

  List<Map<String, dynamic>> materiais = [];
  List<Map<String, dynamic>> instrumentos = [];

  @override
  void initState() {
    super.initState();
    fetchItens();
  }

  Future<void> fetchItens() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse(
      isMaterialSelecionado
          ? "http://127.0.0.1:8000/pedidos/listar_materiais"
          : "http://127.0.0.1:8000/pedidos/listar_instrumentos",
    );

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          if (isMaterialSelecionado) {
            materiais = List<Map<String, dynamic>>.from(data);
          } else {
            instrumentos = List<Map<String, dynamic>>.from(data);
          }
        });
      } else {
        print('Erro ao carregar itens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }

  // ==========================================================
  // RETIRADA DE MATERIAL
  // ==========================================================

  void abrirDialogRetirada(Map<String, dynamic> item) {
    final TextEditingController qtdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Retirar ${item['nome']}"),
          content: TextField(
            controller: qtdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantidade a retirar",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                retirarMaterial(item, qtdController.text.trim());
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> retirarMaterial(Map<String, dynamic> item, String qtdStr) async {
    Navigator.pop(context); // fecha o dialog

    final quantidade = int.tryParse(qtdStr);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantidade inválida")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final id = item["id"]; 

    final url = Uri.parse(
      "http://127.0.0.1:8000/pedidos/retirar_material/$id/$quantidade",
    );

    final response = await http.put(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Retirada concluída! Novo saldo: ${data["novo_saldo"]}",
          ),
        ),
      );
      fetchItens();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["detail"] ?? "Erro ao retirar")),
      );
    }
  }

  // ==========================================================
  // RETIRADA DE INSTRUMENTO (ALTERADO)
  // ==========================================================

  Future<void> retirarInstrumento(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final id = item["id"];

    final url = Uri.parse(
      "http://127.0.0.1:8000/pedidos/retirar_instrumento/$id",
    );

    final response = await http.put(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Instrumento retirado com sucesso!")),
      );
      fetchItens();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["detail"] ?? "Erro ao retirar instrumento")),
      );
    }
  }

  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final listaItens =
        isMaterialSelecionado ? materiais : instrumentos;

    final itensFiltrados = listaItens
        .where((item) =>
            item['nome'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            item['id'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1780),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white),
              title: const Text('Perfil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaPerfil()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.house_rounded, color: Colors.white),
              title: const Text('Tela Inicial', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaInicial()));
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          const Text(
            "Retirada",
            style: TextStyle(
              color: Color(0xFF1A1780),
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 25),

          // Material / Instrumento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMaterialSelecionado = true;
                        searchQuery = "";
                      });
                      fetchItens();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMaterialSelecionado
                          ? const Color(0xFF1A1780)
                          : Colors.grey.shade400,
                    ),
                    child: const Text("Material"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMaterialSelecionado = false;
                        searchQuery = "";
                      });
                      fetchItens();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isMaterialSelecionado
                          ? const Color(0xFF1A1780)
                          : Colors.grey.shade400,
                    ),
                    child: const Text("Instrumento"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Buscar por nome ou ID",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A1780)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF1A1780)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF1A1780)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: itensFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum item encontrado",
                      style: TextStyle(
                        color: Color(0xFF1A1780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: itensFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = itensFiltrados[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(
                            item["nome"],
                            style: const TextStyle(
                              color: Color(0xFF1A1780),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // =====================================================
                          // SUBTITLE (alterado apenas aqui)
                          // =====================================================
                          subtitle: Text(
                            isMaterialSelecionado
                                ? "ID: ${item['id']}  |  Saldo: ${item['quantidade']}"
                                : "ID: ${item['id']}  |  Status: ${item['status']}",
                          ),

                          // =====================================================
                          // ONTAP (alterado aqui)
                          // =====================================================
                          onTap: () {
                            if (isMaterialSelecionado) {
                              abrirDialogRetirada(item);
                            } else {
                              if (item["status"] == "Em uso") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Este instrumento já está em uso."),
                                  ),
                                );
                              } else {
                                retirarInstrumento(item);
                              }
                            }
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

