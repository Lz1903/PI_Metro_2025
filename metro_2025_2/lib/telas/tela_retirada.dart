import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';
import 'package:intl/intl.dart';

class TelaRetirada extends StatefulWidget {
  const TelaRetirada({super.key});

  @override
  State<TelaRetirada> createState() => _TelaRetirada();
}

class _TelaRetirada extends State<TelaRetirada> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 
  
  TextEditingController pesquisaController = TextEditingController();
  String tipoSelecionado = 'materiais';
  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    carregarEstoque();
    pesquisaController.addListener(() {
      filtrar(pesquisaController.text);
    });
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

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void trocarTipo(String novoTipo) {
    if (tipoSelecionado != novoTipo) {
      setState(() {
        tipoSelecionado = novoTipo;
        isLoading = true;
        listaCompleta = [];
        listaFiltrada = [];
        pesquisaController.clear();
      });
      carregarEstoque();
    }
  }

  Future<void> carregarEstoque() async {
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

      String endpoint = (tipoSelecionado == 'materiais')
          ? '/pedidos/listar_materiais'
          : '/pedidos/listar_instrumentos';

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> dadosFormatados = data.map((item) {
          if (tipoSelecionado == 'materiais') {
            return {
              "id": item["id"].toString(),
              "nome": item["nome"].toString(),
              "local": item["local"].toString(),
              "status": item["status"].toString(),
              "quantidade": item["quantidade"],
              "unidade": item["unidade"]?.toString() ?? "UN",
              "limite_minimo": item["limite_minimo"],
              "tipo": item["tipo"].toString(),
              "vencimento": item["vencimento"]?.toString() ?? "",
            };
          } else {
            return {
              "id": item["id"].toString(),
              "nome": item["nome"].toString(),
              "local": item["local"].toString(),
              "status": item["status"].toString(),
              "calibracao": item["calibracao"]?.toString() ?? "",
            };
          }
        }).toList();

        setState(() {
          listaCompleta = dadosFormatados;
          if (tipoSelecionado == 'materiais') {
            listaFiltrada = dadosFormatados
              .where((item) => (item["quantidade"]?? 0) > 0)
              .toList();
          }
          else {
            listaFiltrada = dadosFormatados
              .where((item) => (item["status"]?? "") != "Em uso")
              .toList();
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Erro: ${response.statusCode} ${response.body}";
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

  Future<void> _onRowTap(Map<String, dynamic> item) async {
    if (tipoSelecionado == 'materiais') {
      await _showRetirarMaterialDialog(item);
    } else {
      await _showRetirarInstrumentoDialog(item);
    }
  }

  Future<void> _showRetirarMaterialDialog(Map<String, dynamic> item) async {
    final qtdController = TextEditingController();
    String? dialogError;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Retirar material: ${item["nome"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Estoque atual: ${item["quantidade"]} ${item["unidade"]}'),
                const SizedBox(height: 8),
                TextField(
                  controller: qtdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade a retirar',
                    hintText: 'Digite a quantidade',
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Text(dialogError!, style: const TextStyle(color: Colors.red)),
                ],
                if (isSubmitting) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF1A1780)),),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  final textoQtd = qtdController.text.trim();
                  if (textoQtd.isEmpty) {
                    setStateDialog(() { dialogError = "Informe a quantidade."; });
                    return;
                  }
                  int? qtd = int.tryParse(textoQtd);
                  if (qtd == null || qtd <= 0) {
                    setStateDialog(() { dialogError = "Quantidade inválida."; });
                    return;
                  }
                  final estoqueAtual = (item["quantidade"] is int) ? item["quantidade"] as int : int.tryParse(item["quantidade"].toString()) ?? 0;
                  if (qtd > estoqueAtual) {
                    setStateDialog(() { dialogError = "Quantidade maior que o estoque disponível."; });
                    return;
                  }
                  setStateDialog(() { isSubmitting = true; dialogError = null; });
                  try {
                    final resultado = await _retirarMaterial(item["id"], qtd);
                    Navigator.of(context).pop();
                    await _showSucessoRetiradaMaterial(resultado, item, qtd);
                    await carregarEstoque();
                  } catch (e) {
                    setStateDialog(() {
                      isSubmitting = false;
                      dialogError = e.toString();
                    });
                  }
                },
                child: const Text('Confirmar', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1780),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showSucessoRetiradaMaterial(Map<String, dynamic> resultado, Map<String, dynamic> item, int qtdRetirada) async {
    final mensagem = resultado['mensagem'] ?? 'Retirada realizada';
    final novoSaldo = resultado['novo_saldo']?.toString() ?? item['quantidade'].toString();
    final local = item['local'] ?? 'Desconhecido';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Retirada realizada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$mensagem'),
              const SizedBox(height: 8),
              Text('Material: ${item["nome"]}'),
              Text('Quantidade retirada: $qtdRetirada ${item["unidade"]}'),
              Text('Novo saldo: $novoSaldo ${item["unidade"]}'),
              const SizedBox(height: 12),
              Text('Retirar material: $local'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ok')),
          ],
        );
      },
    );
  }

  Future<void> _showRetirarInstrumentoDialog(Map<String, dynamic> item) async {
    bool isSubmitting = false;
    String? dialogError;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Retirar instrumento: ${item["nome"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Local: ${item["local"]}'),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Text(dialogError!, style: const TextStyle(color: Colors.red)),
                ],
                if (isSubmitting) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: isSubmitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Color(0xFF1A1780)),),),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  setStateDialog(() { isSubmitting = true; dialogError = null; });
                  try {
                    final resultado = await _retirarInstrumento(item["id"]);
                    Navigator.of(context).pop();
                    await _showSucessoRetiradaInstrumento(resultado, item);
                    await carregarEstoque();
                  } catch (e) {
                    setStateDialog(() {
                      isSubmitting = false;
                      dialogError = e.toString();
                    });
                  }
                },
                child: const Text('Confirmar', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1780),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showSucessoRetiradaInstrumento(Map<String, dynamic> resultado, Map<String, dynamic> item) async {
    final mensagem = resultado['mensagem'] ?? 'Instrumento retirado';
    final local = item['local'] ?? 'Desconhecido';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solitação de retirada realizada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensagem),
              const SizedBox(height: 8),
              Text('Instrumento: ${item["nome"]}'),
              Text('ID: ${item["id"]}'),
              const SizedBox(height: 12),
              Text('Retirar material em: $local'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ok')),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _retirarMaterial(String id, int quantidade) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('$baseUrl/pedidos/retirar_material/$id/$quantidade');
    final resp = await http.put(uri, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'});
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 401) {
      throw Exception('Token expirado ou inválido (401). Faça login novamente.');
    } else {
      throw Exception('Erro ao retirar material: ${resp.statusCode} - ${resp.body}');
    }
  }

  Future<Map<String, dynamic>> _retirarInstrumento(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('$baseUrl/pedidos/retirar_instrumento/$id');
    final resp = await http.put(uri, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'});
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 401) {
      throw Exception('Token expirado ou inválido (401). Faça login novamente.');
    } else {
      throw Exception('Erro ao retirar instrumento: ${resp.statusCode} - ${resp.body}');
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
          child: Image.asset('assets/imagens/logo_metro_mobile.png', height: 80, fit: BoxFit.contain),
        ),
        actions: const [
          AlertaAppBar(),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Row(children: [
            Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 10))),
            Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 10))),
            Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 10))),
            Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 10))),
            Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 10))),
          ]),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (!isMobile) const SizedBox(width: 250, child: MenuLateral()),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Center(
                        child: Text("Retirada", style: TextStyle(color: Color(0xFF1A1780), fontWeight: FontWeight.bold, fontSize: 28)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => trocarTipo('materiais'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tipoSelecionado == 'materiais' ?
                                const Color(0xFF101C8B) : Colors.grey[300],
                              foregroundColor: tipoSelecionado == 'materiais' ?
                                Colors.white : Colors.black,
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
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 190),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: TextField(
                                        controller: pesquisaController,
                                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Pesquisar no estoque", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
                                      ),
                                    ),
                                  ),
                                ],
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
                                  ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            width: isMobile ? 800 : 900,
                                            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                                            child: DataTable(
                                              headingRowColor: MaterialStateProperty.all(const Color(0xFF1A1780)),
                                              headingTextStyle: const TextStyle(color: Colors.white),
                                              columnSpacing: 20,
                                              dataRowMinHeight: 48,
                                              showCheckboxColumn: false,
                                              columns: tipoSelecionado == 'materiais'
                                                  ? const [
                                                      DataColumn(label: Text("ID")),
                                                      DataColumn(label: Text("Nome")),
                                                      DataColumn(label: Text("Qtd")),
                                                      DataColumn(label: Text("Un.Medida")),
                                                      DataColumn(label: Text("Base")),
                                                      DataColumn(label: Text("Status")),
                                                      DataColumn(label: Text("Tipo")),
                                                      DataColumn(label: Text("Vencimento")),
                                                    ]
                                                  : const [
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
                                                  cells: tipoSelecionado == 'materiais'
                                                      ? [
                                                          DataCell(Text(item["id"])),
                                                          DataCell(Text(item["nome"])),
                                                          DataCell(Text(item["quantidade"].toString())),
                                                          DataCell(Text(item["unidade"].toString())),
                                                          DataCell(Text(item["local"])),
                                                          DataCell(Text(item["status"])),
                                                          DataCell(Text(item["tipo"])),
                                                          DataCell(Text(_formatarDataParaBR(item["vencimento"]))),
                                                        ]
                                                      : [
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
              ),
            ],
          );
        },
      ),
    );
  }
}