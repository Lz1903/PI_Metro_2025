import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaDevolucao extends StatefulWidget {
  const TelaDevolucao({super.key});

  @override
  State<TelaDevolucao> createState() => _TelaDevolucaoState();
}

class _TelaDevolucaoState extends State<TelaDevolucao> {
  List instrumentos = [];

  @override
  void initState() {
    super.initState();
    carregarInstrumentos();
  }

Future<void> carregarInstrumentos() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  final url = Uri.parse("http://127.0.0.1:8000/pedidos/listar_instrumentos");

  final response = await http.get(url, headers: {
    "Authorization": "Bearer $token",
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;

    setState(() {
      instrumentos = data.where((i) => i["status"] == "Em uso").toList();
    });
  } else {
    print("Erro ao carregar instrumentos: ${response.statusCode}");
  }
}


  Future<void> devolver(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final url = Uri.parse("http://127.0.0.1:8000/pedidos/devolver_instrumento/$id");

    final response = await http.put(url, headers: {
      "Authorization": "Bearer $token",
    });

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Instrumento devolvido!")),
      );
      carregarInstrumentos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["detail"] ?? "Erro ao devolver")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devolução"),
        backgroundColor: const Color(0xFF1A1780),
      ),
      body: instrumentos.isEmpty
          ? const Center(child: Text("Nenhum instrumento em uso"))
          : ListView.builder(
              itemCount: instrumentos.length,
              itemBuilder: (_, index) {
                final item = instrumentos[index];
                return ListTile(
                  title: Text(item["nome"]),
                  subtitle: Text("ID: ${item['id']} | Status: ${item['status']}"),
                  trailing: ElevatedButton(
                    onPressed: () => devolver(item["id"]),
                    child: const Text("Devolver"),
                  ),
                );
              },
            ),
    );
  }
}
