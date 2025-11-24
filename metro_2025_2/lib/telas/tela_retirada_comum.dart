import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaRetiradaComum extends StatefulWidget {
  const TelaRetiradaComum({super.key});

  @override
  State<TelaRetiradaComum> createState() => _TelaRetiradaComumState();
}

class _TelaRetiradaComumState extends State<TelaRetiradaComum> {
  TextEditingController pesquisaController = TextEditingController();
  String tipoSelecionado = 'materiais';
  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    carregarItens();
    pesquisaController.addListener(() => filtrar(pesquisaController.text));
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void trocarTipo(String novoTipo) {
    if (tipoSelecionado != novoTipo) {
      setState(() {
        tipoSelecionado = novoTipo;
        isLoading = true;
        pesquisaController.clear();
      });
      carregarItens();
    }
  }

  Future<void> carregarItens() async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      String endpoint = (tipoSelecionado == 'materiais') 
          ? '/pedidos/listar_materiais' 
          : '/pedidos/listar_instrumentos';

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        List<Map<String, dynamic>> dadosFormatados = data.where((item) {
          if (tipoSelecionado == 'materiais') {
            return (item["quantidade"] ?? 0) > 0;
          } else {
            return item["status"] == "Disponível";
          }
        }).map((item) => Map<String, dynamic>.from(item)).toList();

        setState(() {
          listaCompleta = dadosFormatados;
          listaFiltrada = dadosFormatados;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> realizarRetirada(String id, int? quantidade) async {
    String? token = await _getToken();
    String endpoint = tipoSelecionado == 'materiais' 
        ? '/pedidos/retirar_material/$id/$quantidade'
        : '/pedidos/retirar_instrumento/$id';

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Retirada realizada com sucesso!"), backgroundColor: Colors.green));
        carregarItens();
      } else {
        String msg = "Erro na retirada";
        try { msg = json.decode(response.body)['detail']; } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  void _abrirDialogoRetirada(Map<String, dynamic> item) {
    final qtdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Retirar ${item['nome']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ID: ${item['id']}"),
            Text("Local: ${item['local']}"),
            const SizedBox(height: 10),
            if (tipoSelecionado == 'materiais') ...[
              Text("Disponível: ${item['quantidade']} ${item['unidade'] ?? ''}"),
              const SizedBox(height: 10),
              TextField(
                controller: qtdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantidade a retirar", border: OutlineInputBorder()),
              ),
            ] else
              const Text("Confirma a retirada deste instrumento?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101C8B)),
            onPressed: () {
              if (tipoSelecionado == 'materiais') {
                int? qtd = int.tryParse(qtdController.text);
                if (qtd == null || qtd <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantidade inválida")));
                  return;
                }
                realizarRetirada(item['id'], qtd);
              } else {
                realizarRetirada(item['id'], null);
              }
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        listaFiltrada = List.from(listaCompleta);
      } else {
        listaFiltrada = listaCompleta.where((item) {
          return item['nome'].toString().toLowerCase().contains(texto.toLowerCase()) ||
                 item['id'].toString().toLowerCase().contains(texto.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C8B),
        toolbarHeight: 80,
        title: const Text("Nova Retirada", style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => trocarTipo('materiais'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoSelecionado == 'materiais' ? const Color(0xFF101C8B) : Colors.grey[300],
                  foregroundColor: tipoSelecionado == 'materiais' ? Colors.white : Colors.black,
                ),
                child: const Text("Materiais"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => trocarTipo('instrumentos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoSelecionado == 'instrumentos' ? const Color(0xFF101C8B) : Colors.grey[300],
                  foregroundColor: tipoSelecionado == 'instrumentos' ? Colors.white : Colors.black,
                ),
                child: const Text("Instrumentos"),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: pesquisaController,
                decoration: const InputDecoration(
                  hintText: "Pesquisar item...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    final item = listaFiltrada[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          tipoSelecionado == 'materiais' ? Icons.inventory_2 : Icons.build,
                          color: const Color(0xFF101C8B),
                        ),
                        title: Text(item['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("ID: ${item['id']} | Local: ${item['local']}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _abrirDialogoRetirada(item),
                          child: const Text("Retirar", style: TextStyle(color: Colors.white)),
                        ),
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