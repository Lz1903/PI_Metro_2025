import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  List historico = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("http://127.0.0.1:8000/pedidos/historico");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        historico = data;
      });
    } else {
      print("Erro ao carregar histórico: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Retiradas"),
        backgroundColor: const Color(0xFF1A1780),
      ),
      body: historico.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma retirada registrada",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final item = historico[index];

               final dataLocal = DateTime.parse(item["data_hora"]);
               
                final dataFormatada =
                    "${dataLocal.day.toString().padLeft(2, '0')}/"
                    "${dataLocal.month.toString().padLeft(2, '0')}/"
                    "${dataLocal.year} "
                    "${dataLocal.hour.toString().padLeft(2, '0')}:"
                    "${dataLocal.minute.toString().padLeft(2, '0')}";

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      item["nome_item"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1780),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tipo: ${item["tipo"]}"),

                          // Quantidade só aparece para materiais
                          if (item["tipo"] == "material")
                            Text("Quantidade: ${item["quantidade"]}"),

                          Text("Usuário: ${item["usuario"]}"),
                          Text("Data: $dataFormatada"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

