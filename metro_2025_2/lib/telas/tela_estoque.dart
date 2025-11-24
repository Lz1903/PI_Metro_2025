import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:intl/intl.dart';

class TelaEstoque extends StatefulWidget {
  const TelaEstoque({super.key});

  @override
  State<TelaEstoque> createState() => _TelaEstoque();
}

class _TelaEstoque extends State<TelaEstoque> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  TextEditingController pesquisaController = TextEditingController();
  String tipoSelecionado = 'materiais';
  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000"; 

  final List<Map<String, String>> unidadesOpcoes = [
    {"sigla": "UN", "texto": "UN - Unidade"},
    {"sigla": "CJ", "texto": "CJ - Conjunto"},
    {"sigla": "MT", "texto": "MT - Metro"},
    {"sigla": "KG", "texto": "KG - Quilograma"},
    {"sigla": "L", "texto": "L - Litro"},
    {"sigla": "PÇ", "texto": "PÇ - Peça"},
    {"sigla": "RO", "texto": "RO - Rolo"},
    {"sigla": "CX", "texto": "CX - Caixa"},
    {"sigla": "SC", "texto": "SC - Saco"},
    {"sigla": "PAR", "texto": "PAR - Par"},
    {"sigla": "JG", "texto": "JG - Jogo"},
  ];

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

  final List<String> tiposMateriaisOpcoes = [
    "Consumo",
    "Giro",
    "Patrimoniado",
  ];

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

  String? _formatarDataParaISO(String dataBR) {
    if (dataBR.isEmpty) return null;
    try {
      List<String> partes = dataBR.split('/');
      if (partes.length != 3) return null;
      return "${partes[2]}-${partes[1]}-${partes[0]}"; 
    } catch (e) {
      return null;
    }
  }


  Widget _formatarDataVencimentoAlerta(String? dataISO) {
    if (dataISO == null || dataISO.isEmpty) {
      return const Text("N/A", style: TextStyle(color: Colors.black));
    }
    
    try {
      DateTime dataVencimento = DateTime.parse(dataISO);
      String dataFormatada = DateFormat('dd/MM/yyyy').format(dataVencimento);
      
      final DateTime hoje = DateTime.now();
      final Duration diferenca = dataVencimento.difference(hoje); 
      
      Color corFundo = Colors.transparent;
      String textoAlerta = dataFormatada;
      Color corTexto = Colors.black;
      FontWeight pesoFonte = FontWeight.normal;

      if (diferenca.inDays < 0) { 
        corFundo = Colors.red.withOpacity(0.7);
        textoAlerta = "$dataFormatada (VENCIDA)";
        corTexto = Colors.white;
        pesoFonte = FontWeight.bold;
      } else if (diferenca.inDays <= 30) {
        corFundo = Colors.yellow.withOpacity(0.8);
        textoAlerta = "$dataFormatada (${diferenca.inDays} dias)";
        corTexto = Colors.black;
        pesoFonte = FontWeight.bold;
      }
      
      return Container(
        color: corFundo,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          textoAlerta,
          style: TextStyle(color: corTexto, fontWeight: pesoFonte),
        ),
      );

    } catch (e) {
      return Text(dataISO, style: const TextStyle(color: Colors.red));
    }
  }

  Widget _formatarDataCalibracaoAlerta(String? dataISO) {
    if (dataISO == null || dataISO.isEmpty) {
      return const Text("N/A", style: TextStyle(color: Colors.black));
    }
    
    try {
      DateTime dataCalibracao = DateTime.parse(dataISO);
      String dataFormatada = DateFormat('dd/MM/yyyy').format(dataCalibracao);
      
      final DateTime hoje = DateTime.now();
      final Duration diferenca = dataCalibracao.difference(hoje);
      
      Color corFundo = Colors.transparent;
      String textoAlerta = dataFormatada;
      Color corTexto = Colors.black;
      FontWeight pesoFonte = FontWeight.normal;

      if (diferenca.inDays < 0) {
        corFundo = Colors.red.withOpacity(0.7);
        textoAlerta = "$dataFormatada (VENCIDA)";
        corTexto = Colors.white;
        pesoFonte = FontWeight.bold;
      } else if (diferenca.inDays <= 30) {
        corFundo = Colors.yellow.withOpacity(0.8);
        textoAlerta = "$dataFormatada (${diferenca.inDays} dias)";
        corTexto = Colors.black;
        pesoFonte = FontWeight.bold;
      }
      
      return Container(
        color: corFundo,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          textoAlerta,
          style: TextStyle(color: corTexto, fontWeight: pesoFonte),
        ),
      );

    } catch (e) {
      return Text(dataISO, style: const TextStyle(color: Colors.red));
    }
  }

  Color _obterCorStatusMaterial(int quantidade, int limiteMinimo) {
    if (limiteMinimo > 0) {
      if (quantidade == 0) {
        return Colors.red;
      } else if (quantidade <= limiteMinimo) {
        return Colors.yellow.shade800;
      }
    }
    return Colors.green;
  }

  Widget _buildStatusCell(String status, Color corBorda) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: corBorda, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: corBorda,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
      String? token = await _getToken();
      if (token == null) {
        setState(() { isLoading = false; errorMessage = "Não autenticado."; });
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
            String statusMaterial = "Disponível";
            int qtd = item["quantidade"] ?? 0;
            int limite = item["limite_minimo"] ?? 0;

            if (limite > 0) {
                if (qtd == 0) {
                    statusMaterial = "Em Falta";
                } else if (qtd <= limite) {
                    statusMaterial = "Alerta Mínimo";
                }
            }


            return {
              "id": item["id"].toString(),
              "nome": item["nome"].toString(),
              "local": item["local"].toString(),
              "status": statusMaterial,
              "quantidade": qtd,
              "unidade": item["unidade"]?.toString() ?? "UN",
              "limite_minimo": limite,
              "tipo": item["tipo"]?.toString() ?? "Consumo",
              "vencimento": item["vencimento"]?.toString() ?? "", 
            };
          } else {
            return {
              "id": item["id"].toString(),
              "nome": item["nome"].toString(),
              "local": item["local"].toString(),
              "status": item["status"]?.toString() ?? "Disponível",
              "calibracao": item["calibracao"]?.toString() ?? "", 
            };
          }
        }).toList();

        setState(() {
          listaCompleta = dadosFormatados;
          listaFiltrada = dadosFormatados;
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; errorMessage = "Erro: ${response.statusCode}"; });
      }
    } catch (e) {
      setState(() { isLoading = false; errorMessage = "Erro: $e"; });
    }
  }

  Future<void> excluirItem(String id) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text("Tem certeza que deseja apagar o item $id?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      String? token = await _getToken();
      String endpoint = tipoSelecionado == 'materiais' 
          ? '/pedidos/excluir_material/$id'
          : '/pedidos/excluir_instrumento/$id';

      try {
        final response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item excluído!"), backgroundColor: Colors.green));
          carregarEstoque();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao excluir"), backgroundColor: Colors.red));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> salvarItem(Map<String, dynamic> dados, bool isEditando) async {
    String? token = await _getToken();
    String endpoint;
    String method;

    if (tipoSelecionado == 'materiais') {
      if (isEditando) {
        endpoint = '/pedidos/editar_material/${dados['id']}';
        method = 'PUT';
      } else {
        endpoint = '/pedidos/criar_material';
        method = 'POST';
      }
    } else {
      if (isEditando) {
        endpoint = '/pedidos/editar_instrumento/${dados['id']}';
        method = 'PUT';
      } else {
        endpoint = '/pedidos/criar_instrumento';
        method = 'POST';
      }
    }

    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      final bodyJson = json.encode(dados);

      http.Response response;
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: bodyJson);
      } else {
        response = await http.put(uri, headers: headers, body: bodyJson);
      }

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvo com sucesso!"), backgroundColor: Colors.green));
        carregarEstoque();
      } else {
        String msg = "Erro ao salvar";
        try { msg = json.decode(response.body)['detail']; } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  void _abrirModalItem({Map<String, dynamic>? itemExistente}) {
    bool isEditando = itemExistente != null;
    
    final idCtrl = TextEditingController(text: isEditando ? itemExistente['id'] : '');
    final nomeCtrl = TextEditingController(text: isEditando ? itemExistente['nome'] : '');
    
    String? unidadeSelecionada = isEditando ? itemExistente['unidade'] : 'UN';
    String? localSelecionado = isEditando ? itemExistente['local'] : 'WJA';
    String? tipoMatSelecionado = isEditando ? itemExistente['tipo'] : 'Consumo';

    if (!unidadesOpcoes.any((e) => e['sigla'] == unidadeSelecionada)) unidadeSelecionada = null;
    if (!locaisOpcoes.any((e) => e['sigla'] == localSelecionado)) localSelecionado = null;
    if (tipoSelecionado == 'materiais' && !tiposMateriaisOpcoes.contains(tipoMatSelecionado)) tipoMatSelecionado = null;

    final qtdCtrl = TextEditingController(text: isEditando ? itemExistente['quantidade'].toString() : '');
    final limiteCtrl = TextEditingController(text: isEditando ? itemExistente['limite_minimo'].toString() : '');
    final vencimentoCtrl = TextEditingController(text: isEditando ? _formatarDataParaBR(itemExistente['vencimento']) : '');
    final calibracaoCtrl = TextEditingController(text: isEditando ? _formatarDataParaBR(itemExistente['calibracao']) : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(
                "${isEditando ? 'Editar' : 'Cadastrar'} ${tipoSelecionado == 'materiais' ? 'Material' : 'Instrumento'}",
                style: const TextStyle(color: Color(0xFF101C8B)),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: idCtrl, enabled: !isEditando, decoration: const InputDecoration(labelText: "ID")),
                      TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome do Item")),
                      
                      DropdownButtonFormField<String>(
                        value: localSelecionado,
                        decoration: const InputDecoration(labelText: "Base"),
                        items: locaisOpcoes.map((opcao) {
                          return DropdownMenuItem<String>(
                            value: opcao['sigla'],
                            child: Text(
                              opcao['texto']!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setStateModal(() => localSelecionado = val),
                      ),

                      if (tipoSelecionado == 'materiais') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: qtdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantidade"))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unidadeSelecionada,
                                decoration: const InputDecoration(labelText: "Unidade de medida"),
                                items: unidadesOpcoes.map((opcao) {
                                  return DropdownMenuItem<String>(
                                    value: opcao['sigla'],
                                    child: Text(opcao['texto']!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) => setStateModal(() => unidadeSelecionada = val),
                              ),
                            ),
                          ],
                        ),
                        TextField(controller: limiteCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Limite Mínimo")),
                        
                        DropdownButtonFormField<String>(
                          value: tipoMatSelecionado,
                          decoration: const InputDecoration(labelText: "Tipo de Material"),
                          items: tiposMateriaisOpcoes.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo, 
                              child: Text(tipo),
                            );
                          }).toList(),
                          onChanged: (val) => setStateModal(() => tipoMatSelecionado = val),
                        ),

                        TextField(
                          controller: vencimentoCtrl, 
                          decoration: const InputDecoration(labelText: "Vencimento"),
                          readOnly: true,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context, 
                              initialDate: DateTime.now(), 
                              firstDate: DateTime(2000), 
                              lastDate: DateTime(2100),
                              locale: const Locale('pt', 'BR'),
                            );
                            if(picked != null) {
                              vencimentoCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                            }
                          },
                        ),
                      ],

                      if (tipoSelecionado == 'instrumentos') ...[
                          TextField(
                          controller: calibracaoCtrl, 
                          decoration: const InputDecoration(labelText: "Data Calibração"),
                          readOnly: true,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context, 
                              initialDate: DateTime.now(), 
                              firstDate: DateTime(2000), 
                              lastDate: DateTime(2100),
                              locale: const Locale('pt', 'BR'),
                            );
                            if(picked != null) {
                              calibracaoCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                            }
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                if (isEditando)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: TextButton.icon(
                      onPressed: () => excluirItem(idCtrl.text),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                    ),
                  ),

                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101C8B)),
                  onPressed: () {
                    if(idCtrl.text.isEmpty || nomeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha ID e Nome!")));
                      return;
                    }
                    if(localSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione um Local!")));
                      return;
                    }

                    Map<String, dynamic> dados = {
                      "id": idCtrl.text,
                      "nome": nomeCtrl.text,
                      "local": localSelecionado,
                    };

                    if (tipoSelecionado == 'materiais') {
                      if(unidadeSelecionada == null || tipoMatSelecionado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione Unidade de medida e Tipo!")));
                        return;
                      }
                      
                      dados.addAll({
                        "quantidade": int.tryParse(qtdCtrl.text) ?? 0,
                        "unidade": unidadeSelecionada,
                        "limite_minimo": int.tryParse(limiteCtrl.text) ?? 0,
                        "tipo": tipoMatSelecionado,
                        "vencimento": _formatarDataParaISO(vencimentoCtrl.text),
                      });
                    } else {
                      dados.addAll({
                        "status": isEditando ? itemExistente['status'] : "Disponível",
                        "calibracao": _formatarDataParaISO(calibracaoCtrl.text),
                      });
                    }

                    salvarItem(dados, isEditando);
                  },
                  child: const Text("Salvar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
              Expanded(child: 
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Center(
                        child: Text("Estoque", style: TextStyle(color: Color(0xFF1A1780), fontWeight: FontWeight.bold, fontSize: 28)),
                      ),
                      const SizedBox(height: 10),
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
                                  const SizedBox(width: 15),
                                  SizedBox(
                                    width: 50, height: 50,
                                    child: ElevatedButton(
                                      onPressed: () => _abrirModalItem(),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: const CircleBorder(), padding: EdgeInsets.zero),
                                      child: const Icon(Icons.add, color: Colors.white, size: 30),
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
                                        width: tipoSelecionado == 'materiais' ? 1000 : 900, 
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
                                              DataColumn(label: Text("Limite Mín.")), 
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
                                                if (selected == true) _abrirModalItem(itemExistente: item);
                                              },
                                              cells: tipoSelecionado == 'materiais' 
                                              ? [
                                                  DataCell(Text(item["id"])),
                                                  DataCell(Text(item["nome"])),
                                                  DataCell(Text(item["quantidade"].toString())),
                                                  DataCell(Text(item["limite_minimo"].toString())),
                                                  DataCell(Text(item["unidade"].toString())),
                                                  DataCell(Text(item["local"])), 
                                                  DataCell(_buildStatusCell(
                                                      item["status"], 
                                                      _obterCorStatusMaterial(item["quantidade"], item["limite_minimo"])
                                                  )),
                                                  DataCell(Text(item["tipo"])),
                                                  DataCell(_formatarDataVencimentoAlerta(item["vencimento"])),
                                                ]
                                              : [
                                                  DataCell(Text(item["id"])),
                                                  DataCell(Text(item["nome"])),
                                                  DataCell(Text(item["local"])), 
                                                  DataCell(Text(item["status"])),
                                                  DataCell(_formatarDataCalibracaoAlerta(item["calibracao"])),
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