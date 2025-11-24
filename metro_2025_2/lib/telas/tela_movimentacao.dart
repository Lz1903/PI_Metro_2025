import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';

class TelaMovimentacao extends StatefulWidget {
  const TelaMovimentacao({super.key});

  @override
  State<TelaMovimentacao> createState() => _TelaMovimentacaoState();
}

class _TelaMovimentacaoState extends State<TelaMovimentacao> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pesquisaController = TextEditingController();

  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000";

  final List<Map<String, String>> locaisOpcoes = [
    {"sigla": "WJA", "texto": "WJA - Jabaquara"},
    {"sigla": "PSO", "texto": "PSO - Paraiso"},
    {"sigla": "TRD", "texto": "TRD - Tiradentes"},
    {"sigla": "TUC", "texto": "TUC - Tucuruvi"},
    {"sigla": "LUM", "texto": "LUM - Luminárias"},
    {"sigla": "IMG", "texto": "IMG - Imigrantes"},
    {"sigla": "BFU", "texto": "BFU - Barra Funda"},
    {"sigla": "BAS", "texto": "BAS - Brás"},
    {"sigla": "CEC", "texto": "CEC - Cecília"},
    {"sigla": "MAT", "texto": "MAT - Matheus"},
    {"sigla": "VTD", "texto": "VTD - Vila Matilde"},
    {"sigla": "VPT", "texto": "VPT - Vila Prudente"},
    {"sigla": "PIT", "texto": "PIT - Pátio Itaquera"},
    {"sigla": "POT", "texto": "POT - Pátio Oratório"},
    {"sigla": "PAT", "texto": "PAT - Pátio Jabaquara"},
  ];

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

  Future<void> carregarInstrumentos() async {
    setState(() => isLoading = true);
    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/listar_instrumentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          listaCompleta = data.map((item) => Map<String, dynamic>.from(item)).toList();
          listaFiltrada = List.from(listaCompleta);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Erro: ${response.statusCode}";
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
          return item.values.any((val) => val.toString().toLowerCase().contains(termo));
        }).toList();
      }
    });
  }

  Future<void> realizarTransferencia(String idItem, String novoLocal) async {
    String? token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pedidos/transferir_instrumento/$idItem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"novo_local": novoLocal}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transferência realizada com sucesso!"), backgroundColor: Colors.green)
        );
        carregarInstrumentos();
      } else {
        final erro = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro['detail'] ?? "Erro ao transferir"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e"), backgroundColor: Colors.red)
      );
    }
  }

  void _abrirDialogoTransferencia(Map<String, dynamic> item) {
    String? localSelecionado;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.local_shipping, color: Color(0xFF101C8B)),
                  SizedBox(width: 10),
                  Text("Transferir Instrumento"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Item: ${item['nome']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("ID: ${item['id']}"),
                  const SizedBox(height: 10),
                  Text("Local Atual: ${item['local']}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text("Selecione o Novo Destino:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: localSelecionado,
                    hint: const Text("Selecione a nova base"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: locaisOpcoes.map((opcao) {
                      return DropdownMenuItem<String>(
                        value: opcao['sigla'],
                        enabled: opcao['sigla'] != item['local'], 
                        child: Text(
                          opcao['texto']!,
                          style: TextStyle(
                            color: opcao['sigla'] == item['local'] ? Colors.grey : Colors.black
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => localSelecionado = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101C8B)),
                  onPressed: localSelecionado == null 
                      ? null 
                      : () => realizarTransferencia(item['id'], localSelecionado!),
                  child: const Text("Confirmar Transferência", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

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
        actions: const [AlertaAppBar()],
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
                        "Movimentação entre Bases",
                        style: TextStyle(
                          color: Color(0xFF1A1780),
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 50,
                        width: isMobile ? double.infinity : 600,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: TextField(
                          controller: pesquisaController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: "Pesquisar instrumento por nome ou ID",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : errorMessage != null
                                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Center(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          width: isMobile ? 800 : 1000,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black, width: 1),
                                          ),
                                          child: DataTable(
                                            headingRowColor: MaterialStateProperty.all(const Color(0xFF1A1780)),
                                            headingTextStyle: const TextStyle(color: Colors.white),
                                            dataRowMinHeight: 48,
                                            columnSpacing: 20,
                                            columns: const [
                                              DataColumn(label: Text("ID")),
                                              DataColumn(label: Text("Nome")),
                                              DataColumn(label: Text("Local Atual")),
                                              DataColumn(label: Text("Status")),
                                              DataColumn(label: Text("Ação")),
                                            ],
                                            rows: listaFiltrada.map((item) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(item["id"].toString())),
                                                  DataCell(Text(item["nome"].toString())),
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: Colors.grey),
                                                      ),
                                                      child: Text(
                                                        item["local"].toString(),
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text(item["status"].toString())),
                                                  DataCell(
                                                    ElevatedButton.icon(
                                                      onPressed: item["status"] == "Em uso" 
                                                          ? null 
                                                          : () => _abrirDialogoTransferencia(item),
                                                      icon: const Icon(Icons.local_shipping, size: 18),
                                                      label: const Text("Transferir"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.orange,
                                                        foregroundColor: Colors.white,
                                                        disabledBackgroundColor: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ),
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