import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaDevolucaoComum extends StatefulWidget {
  const TelaDevolucaoComum({super.key});

  @override
  State<TelaDevolucaoComum> createState() => _TelaDevolucaoComumState();
}

class _TelaDevolucaoComumState extends State<TelaDevolucaoComum> {
  List<Map<String, dynamic>> meusItens = [];
  bool isLoading = true;
  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    carregarMeusItens();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> carregarMeusItens() async {
    setState(() => isLoading = true);
    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/listar_instrumentos_usuario'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          meusItens = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> devolverItem(String id) async {
    String? token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pedidos/devolver_instrumento/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item devolvido com sucesso!"), backgroundColor: Colors.green));
        carregarMeusItens();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao devolver"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  void _confirmarDevolucao(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Devolução"),
        content: Text("Deseja devolver o item '${item['nome']}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => devolverItem(item['id']),
            child: const Text("Devolver", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C8B),
        toolbarHeight: 80,
        title: const Text("Minhas Devoluções", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Row(
            children: [
              Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 10))),
            ],
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : meusItens.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("Nenhum item pendente para devolução.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: meusItens.length,
              itemBuilder: (context, index) {
                final item = meusItens[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment_return, color: Colors.orange),
                    ),
                    title: Text(item['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ID: ${item['id']}"),
                          Text("Local Original: ${item['local']}"),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => _confirmarDevolucao(item),
                      child: const Text("Devolver", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}