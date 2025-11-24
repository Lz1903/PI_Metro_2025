import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';
import 'package:intl/intl.dart';

class TelaDevolucao extends StatefulWidget {
  const TelaDevolucao({super.key});

  @override
  State<TelaDevolucao> createState() => _TelaDevolucaoState();
}

class _TelaDevolucaoState extends State<TelaDevolucao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pesquisaController = TextEditingController();
  
  final String tipoSelecionado = 'instrumentos';

  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    carregarInstrumentos();
    pesquisaController.addListener(() {
      filtrar(pesquisaController.text);
    });
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  String _formatarDataParaBR(String? dataISO) {
    if (dataISO == null || dataISO.isEmpty) return "";
    try {
      DateTime data = DateTime.parse(dataISO);
      return DateFormat('dd/MM/yyyy').format(data);
    } catch (e) {
      return dataISO;
    }
  }

  Future<void> carregarInstrumentos() async {
    try {
      setState(() {
        errorMessage = null;
      });
      String? token = await _getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = "Não autenticado.";
        });
        return;
      }
      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/listar_instrumentos_usuario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> dadosFormatados = data.map((item) {
          return {
            "id": item["id"].toString(),
            "nome": item["nome"].toString(),
            "local": item["local"].toString(),
            "status": item["status"].toString(),
            "calibracao": item["calibracao"]?.toString() ?? "",
          };
        }).toList();

        setState(() {
          listaCompleta = dadosFormatados;
          listaFiltrada = List.from(listaCompleta);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Erro: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erro: $e";
      });
    }
  }

  void filtrar(String texto) {
    setState(() {
      if (texto.isEmpty) {
        listaFiltrada = List.from(listaCompleta);
      } else {
        listaFiltrada = listaCompleta.where((item) {
          final termo = texto.toLowerCase();
          return item.values.any(
            (val) => val.toString().toLowerCase().contains(termo),
          );
        }).toList();
      }
    });
  }

  Future<void> _onRowTap(Map<String, dynamic> item) async {
    await _showDevolverInstrumentoDialog(item);
  }

  Future<void> _showDevolverInstrumentoDialog(Map<String, dynamic> item) async {
    bool isSubmitting = false;
    String? dialogError;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Devolver instrumento: ${item["nome"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Local atual: ${item["local"]}'),
                const SizedBox(height: 8),
                if (dialogError != null)
                  Text(dialogError!, style: const TextStyle(color: Colors.red)),
                if (isSubmitting) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF1A1780))),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  setStateDialog(() {
                    isSubmitting = true;
                    dialogError = null;
                  });
                  try {
                    final resultado = await _devolverInstrumento(item["id"]);
                    Navigator.of(context).pop();
                    await _showSucessoDevolucao(resultado, item);
                    await carregarInstrumentos();
                  } catch (e) {
                    setStateDialog(() {
                      isSubmitting = false;
                      String erroMsg = e.toString();
                      if (e.toString().contains("Erro: 403")) {
                          erroMsg = "Erro: Você só pode devolver instrumentos que você retirou.";
                      } else if (e.toString().contains("Erro:")) {
                          try {
                              String body = e.toString().split(" - ")[1].trim();
                              Map<String, dynamic> errorJson = json.decode(body);
                              erroMsg = "Erro: ${errorJson['detail'] ?? errorJson['message'] ?? body}";
                          } catch (_) {
                          }
                      }
                      dialogError = erroMsg;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1780)),
                child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showSucessoDevolucao(Map<String, dynamic> resultado, Map<String, dynamic> item) async {
    final mensagem = resultado['mensagem'] ?? 'Instrumento devolvido';
    final local = item['local'] ?? 'Desconhecido';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Devolução realizada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensagem),
              const SizedBox(height: 8),
              Text('Instrumento: ${item["nome"]}'),
              Text('ID: ${item["id"]}'),
              const SizedBox(height: 12),
              Text('Local devolvido: $local'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _devolverInstrumento(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('$baseUrl/pedidos/devolver_instrumento/$id');
    final resp = await http.put(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) {
      return json.decode(resp.body);
    } else {
      throw Exception("Erro: ${resp.statusCode} - ${resp.body}");
    }
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile ? const Drawer(child: MenuLateral()) : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isMobile 
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        backgroundColor: const Color(0xFF101C8B),
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/imagens/logo_metro_mobile.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        actions: const [
          AlertaAppBar(),
        ],
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (!isMobile) const SizedBox(width: 250, child: MenuLateral()),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        "Devolução",
                        style: TextStyle(
                          color: Color(0xFF1A1780),
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 190),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextField(
                                controller: pesquisaController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: "Pesquisar instrumento",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : errorMessage != null
                                ? Center(
                                      child: Text(
                                        errorMessage!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    )
                                : listaFiltrada.isEmpty && pesquisaController.text.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "Nenhum instrumento retirado por você encontrado.",
                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Center(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Container(
                                                width: isMobile ? 800 : 900,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black, width: 1),
                                                ),
                                                child: DataTable(
                                                  headingRowColor: MaterialStateProperty.all(const Color(0xFF1A1780)),
                                                  headingTextStyle: const TextStyle(color: Colors.white),
                                                  columnSpacing: 20,
                                                  showCheckboxColumn: false,
                                                  columns: const [
                                                    DataColumn(label: Text("ID")),
                                                    DataColumn(label: Text("Nome")),
                                                    DataColumn(label: Text("Base")),
                                                    DataColumn(label: Text("Status")),
                                                    DataColumn(label: Text("Calibração")),
                                                  ],
                                                  rows: listaFiltrada.map((item) {
                                                    return DataRow(
                                                      onSelectChanged: (selected) {
                                                        if (selected == true) _onRowTap(item);
                                                      },
                                                      cells: [
                                                        DataCell(Text(item["id"])),
                                                        DataCell(Text(item["nome"])),
                                                        DataCell(Text(item["local"])),
                                                        DataCell(Text(item["status"])),
                                                        DataCell(Text(_formatarDataParaBR(item["calibracao"]))),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}