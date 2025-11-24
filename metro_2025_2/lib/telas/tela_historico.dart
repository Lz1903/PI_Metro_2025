import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';
import 'package:intl/intl.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  TextEditingController pesquisaController = TextEditingController();

  String filtroMovimento = 'Todos';
  String filtroTipoItem = 'Todos';
  DateTime? filtroDataInicial;
  DateTime? filtroDataFinal;

  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    carregarHistorico();
    pesquisaController.addListener(() {
      _aplicarFiltros();
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  String _formatarDataHora(String? dataString) {
    if (dataString == null || dataString.isEmpty) return "";
    try {
      final isoString = dataString.replaceAll(' ', 'T');
      final dataLocal = DateTime.parse(isoString).toLocal(); 
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dataLocal);
    } catch (e) {
      print("Erro ao formatar data: $e para o valor: $dataString");
      return dataString;
    }
  }

  Future<void> carregarHistorico() async {
    setState(() {
      isLoading = true;
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

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/historico'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> dadosFormatados = data.map((item) {
          final quantidade = item["quantidade"] != null ? (item["quantidade"] as num).toInt() : 0;
          
          String movimento;
          if (item["tipo"]?.toString() == 'material') {
              movimento = quantidade < 0 ? 'Retirada' : 'Devolução';
          } else {
              movimento = quantidade != 0 ? 'Retirada' : 'Devolução';
          }

          final timestampStr = item["data_hora"]?.toString() ?? DateTime.now().toIso8601String();

          DateTime parsedDate;
          try {
            final isoString = timestampStr.replaceAll(' ', 'T');
            parsedDate = DateTime.parse(isoString).toLocal();
          } catch (e) {
            parsedDate = DateTime.now(); 
          }
          
          return {
            "id_movimentacao": item["id"]?.toString() ?? 'N/A', 
            "item_id": item["item_id"]?.toString() ?? 'N/A',
            "nome_item": item["nome_item"]?.toString() ?? 'N/A',
            "quantidade": quantidade,
            "usuario": item["usuario"]?.toString() ?? 'N/A', 
            "tipo": item["tipo"]?.toString() ?? 'N/A', 
            "local": item["local"]?.toString() ?? 'N/A',
            "data_hora": item["data_hora"]?.toString() ?? '', 
            "movimento": movimento,
            "timestamp_ms": parsedDate.millisecondsSinceEpoch,
          };
        }).toList();

        dadosFormatados.sort((a, b) => b["timestamp_ms"].compareTo(a["timestamp_ms"]));

        setState(() {
          listaCompleta = dadosFormatados;
          _aplicarFiltros(); 
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
        errorMessage = "Erro de conexão: $e";
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      listaFiltrada = (listaCompleta).where((item) {
        final termoPesquisa = pesquisaController.text.toLowerCase();
        
        final bool matchPesquisa = item["nome_item"].toLowerCase().contains(termoPesquisa) || 
                                   item["item_id"].toLowerCase().contains(termoPesquisa) ||
                                   item["id_movimentacao"].toLowerCase().contains(termoPesquisa);

        final bool matchTipoItem = filtroTipoItem == 'Todos' || item["tipo"] == filtroTipoItem.toLowerCase();

        final bool matchMovimento = filtroMovimento == 'Todos' || item["movimento"] == filtroMovimento;

        bool matchData = true;
        if (filtroDataInicial != null) {
          final dataRegistro = DateTime.fromMillisecondsSinceEpoch(item["timestamp_ms"]);
          final inicioDia = DateTime(filtroDataInicial!.year, filtroDataInicial!.month, filtroDataInicial!.day);
          if (dataRegistro.isBefore(inicioDia)) {
            matchData = false;
          }
        }
        if (filtroDataFinal != null) {
          final dataRegistro = DateTime.fromMillisecondsSinceEpoch(item["timestamp_ms"]);
          final fimDia = DateTime(filtroDataFinal!.year, filtroDataFinal!.month, filtroDataFinal!.day, 23, 59, 59);
          if (dataRegistro.isAfter(fimDia)) {
            matchData = false;
          }
        }

        return matchPesquisa && matchTipoItem && matchMovimento && matchData;

      }).toList();
    });
  }

  Future<void> _selecionarData(BuildContext context, bool isInicial) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dataSelecionada != null) {
      setState(() {
        if (isInicial) {
          filtroDataInicial = dataSelecionada;
        } else {
          filtroDataFinal = dataSelecionada;
        }
        _aplicarFiltros();
      });
    }
  }

  Future<void> excluirMovimentacao(String idMovimentacao) async {
    String? token = await _getToken();
    if (token == null) {
      _showSnackbar("Erro de autenticação. Tente fazer login novamente.", Colors.red);
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pedidos/movimentacao/$idMovimentacao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackbar("Movimentação ID $idMovimentacao excluída com sucesso.", Colors.green);
        await carregarHistorico();
      } else {
        _showSnackbar("Erro ao excluir. Status: ${response.statusCode}. Detalhe: ${response.body}", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Erro de conexão ao excluir: $e", Colors.red);
    }
  }

  void showConfirmationDialog(Map<String, dynamic> item, BuildContext detailsDialogContext) {
    showDialog(
      context: context,
      builder: (BuildContext confirmationContext) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: Text("Tem certeza que deseja excluir a movimentação ${item["id_movimentacao"]}? Esta ação é irreversível."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(confirmationContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(confirmationContext).pop();
                Navigator.of(detailsDialogContext).pop(); 
                await excluirMovimentacao(item["id_movimentacao"]);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Detalhes da Movimentação (${item["id_movimentacao"]})"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Nome do Item:', item["nome_item"].toString()),
                _buildDetailRow('ID do Item:', item["item_id"].toString()),
                _buildDetailRow('Tipo:', item["tipo"].toString()),
                _buildDetailRow('Movimento:', item["movimento"].toString()),
                _buildDetailRow('Quantidade:', item["quantidade"].abs().toString()),
                _buildDetailRow('Usuário:', item["usuario"].toString()),
                _buildDetailRow('Data/Hora:', _formatarDataHora(item["data_hora"].toString())),
                _buildDetailRow('Local:', item["local"]?.toString() ?? 'N/A'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Excluir', style: TextStyle(color: Colors.white)),
              onPressed: () {
                showConfirmationDialog(item, dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: <TextSpan>[
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
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
                        "Histórico de Movimentações",
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
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3, 
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
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
                                    hintText: "Pesquisar item ou ID",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 10),
                          
                          Expanded(
                            flex: 1, 
                            child: DropdownButtonFormField<String>(
                              value: filtroMovimento,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                labelText: "Movimento",
                              ),
                              items: ['Todos', 'Retirada', 'Devolução'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  filtroMovimento = newValue!;
                                  _aplicarFiltros();
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 10),
                          
                          Expanded(
                            flex: 1, 
                            child: DropdownButtonFormField<String>(
                              value: filtroTipoItem,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                labelText: "Tipo",
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                                DropdownMenuItem(value: 'material', child: Text('Material')),
                                DropdownMenuItem(value: 'instrumento', child: Text('Instrumento')),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  filtroTipoItem = newValue!;
                                  _aplicarFiltros();
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 10),
                          
                          Expanded(
                            flex: 1, 
                            child: OutlinedButton.icon(
                              onPressed: () => _selecionarData(context, true),
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                filtroDataInicial == null
                                    ? 'Data Inic.'
                                    : DateFormat('dd/MM/yy').format(filtroDataInicial!),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 5),
                          
                          Expanded(
                            flex: 1, 
                            child: OutlinedButton.icon(
                              onPressed: () => _selecionarData(context, false),
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                filtroDataFinal == null
                                    ? 'Data Final'
                                    : DateFormat('dd/MM/yy').format(filtroDataFinal!),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 5),
                          
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                pesquisaController.clear();
                                filtroMovimento = 'Todos';
                                filtroTipoItem = 'Todos';
                                filtroDataInicial = null;
                                filtroDataFinal = null;
                                _aplicarFiltros();
                              });
                            },
                          ),
                        ],
                      ),
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
                                : listaFiltrada.isEmpty
                                    ? const Center(child: Text("Nenhuma movimentação encontrada com os filtros aplicados."))
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Center(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              width: isMobile ? 1000 : 1100, 
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black, width: 1),
                                              ),
                                              child: DataTable(
                                                headingRowColor: MaterialStateProperty.all(const Color(0xFF1A1780)),
                                                headingTextStyle: const TextStyle(color: Colors.white),
                                                columnSpacing: 15,
                                                showCheckboxColumn: false,
                                                columns: const [
                                                  DataColumn(label: Text("ID Mov.")),
                                                  DataColumn(label: Text("ID Item")),
                                                  DataColumn(label: Text("Item")),
                                                  DataColumn(label: Text("Tipo")),
                                                  DataColumn(label: Text("Movimento")),
                                                  DataColumn(label: Text("Qtd")),
                                                  DataColumn(label: Text("Usuário")),
                                                  DataColumn(label: Text("Data/Hora")),
                                                ],
                                                rows: listaFiltrada.map((item) {
                                                  return DataRow(
                                                    onSelectChanged: (isSelected) {
                                                      if (isSelected != null && isSelected) {
                                                        showDetailsDialog(item);
                                                      }
                                                    },
                                                    cells: [
                                                      DataCell(Text(item["id_movimentacao"].toString())),
                                                      DataCell(Text(item["item_id"].toString())),
                                                      DataCell(Text(item["nome_item"].toString())),
                                                      DataCell(Text(item["tipo"].toString())),
                                                      DataCell(Text(item["movimento"].toString())),
                                                      DataCell(
                                                        Text(
                                                          item["quantidade"] != null && item["quantidade"] != 0 
                                                              ? item["quantidade"].abs().toString()
                                                              : "-",
                                                          style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                          ),
                                                        )
                                                      ),
                                                      DataCell(Text(item["usuario"].toString())), 
                                                      DataCell(Text(_formatarDataHora(item["data_hora"].toString()))),
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