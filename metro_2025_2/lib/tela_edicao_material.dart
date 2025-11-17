import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaEdicaoMaterial extends StatefulWidget {
  final Map<String, dynamic> item;
  const TelaEdicaoMaterial({super.key, required this.item});

  @override
  State<TelaEdicaoMaterial> createState() => _TelaEdicaoMaterialState();
}

class _TelaEdicaoMaterialState extends State<TelaEdicaoMaterial> {
  late TextEditingController nomeController;
  late TextEditingController qtdController;
  late TextEditingController localController;
  late TextEditingController tipoController;
  late TextEditingController limiteController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.item["nome"]);
    qtdController = TextEditingController(text: widget.item["quantidade"].toString());
    localController = TextEditingController(text: widget.item["local"]);
    tipoController = TextEditingController(text: widget.item["tipo"]);
    limiteController = TextEditingController(text: widget.item["limite_minimo"].toString());
  }

  Future<void> atualizarMaterial() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final id = widget.item["id"];

    final body = {
      "id": id,
      "nome": nomeController.text.trim(),
      "quantidade": int.tryParse(qtdController.text.trim()) ?? 0,
      "local": localController.text.trim(),
      "tipo": tipoController.text.trim(),
      "limite_minimo": int.tryParse(limiteController.text.trim()) ?? 0,
    };

    final response = await http.put(
      Uri.parse("http://127.0.0.1:8000/pedidos/editar_material/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Material atualizado com sucesso!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["detail"] ?? "Erro ao atualizar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar ${widget.item["nome"]}"),
        backgroundColor: const Color(0xFF1A1780),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
            TextField(controller: qtdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantidade")),
            TextField(controller: localController, decoration: const InputDecoration(labelText: "Local")),
            TextField(controller: tipoController, decoration: const InputDecoration(labelText: "Tipo")),
            TextField(controller: limiteController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Limite mínimo")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1780)),
              onPressed: atualizarMaterial,
              child: const Text("Salvar Alterações"),
            ),
          ],
        ),
      ),
    );
  }
}
