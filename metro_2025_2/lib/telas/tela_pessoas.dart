import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';

class TelaPessoas extends StatefulWidget {
  const TelaPessoas({super.key});

  @override
  State<TelaPessoas> createState() => _TelaPessoas();
}

class _TelaPessoas extends State<TelaPessoas> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController pesquisaController = TextEditingController();
  List<Map<String, dynamic>> listaCompleta = [];
  List<Map<String, dynamic>> listaFiltrada = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
    pesquisaController.addListener(() {
      filtrar(pesquisaController.text);
    });
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> carregarUsuarios() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        setState(() { isLoading = false; errorMessage = "Não autenticado."; });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/listar_usuarios'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        List<Map<String, dynamic>> dadosFormatados = data.map((item) {
          return {
            "db_id": item["id"],
            "vis_id": item["codigo"].toString(),
            "nome": item["nome"].toString(),
            "email": item["email"].toString(),
            "time": item["time"]?.toString() ?? "",
            "admin": item["admin"],
            "tipo_texto": (item["admin"] == true) ? "Administrador" : "Comum", 
          };
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

  Future<void> cadastrarUsuario(Map<String, dynamic> dadosNovoUsuario) async {
    _enviarRequisicao('$baseUrl/auth/criar_conta', 'POST', dadosNovoUsuario, "Usuário criado!");
  }

  Future<void> editarUsuario(int dbId, Map<String, dynamic> dadosAtualizados) async {
    await _enviarRequisicao('$baseUrl/auth/editar_usuario/$dbId', 'PUT', dadosAtualizados, "Usuário atualizado!");
  }

  Future<void> excluirUsuario(int dbId) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: const Text("Tem certeza que deseja apagar este usuário?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      String? token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/excluir_usuario/$dbId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuário excluído!"), backgroundColor: Colors.green));
        carregarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao excluir"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _enviarRequisicao(String url, String method, Map body, String successMsg) async {
    try {
      String? token = await _getToken();
      final uri = Uri.parse(url);
      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      final bodyJson = json.encode(body);

      http.Response response;
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: bodyJson);
      } else {
        response = await http.put(uri, headers: headers, body: bodyJson);
      }

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg), backgroundColor: Colors.green));
        carregarUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: ${response.body}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  void _abrirModalUsuario({Map<String, dynamic>? usuarioExistente}) {
    bool isEditando = usuarioExistente != null;
    
    final TextEditingController nomeCtrl = TextEditingController(text: isEditando ? usuarioExistente['nome'] : '');
    final TextEditingController emailCtrl = TextEditingController(text: isEditando ? usuarioExistente['email'] : '');
    final TextEditingController senhaCtrl = TextEditingController(); 
    final TextEditingController codigoCtrl = TextEditingController(text: isEditando ? usuarioExistente['vis_id'] : '');
    final TextEditingController timeCtrl = TextEditingController(text: isEditando ? usuarioExistente['time'] : '');
    bool isAdmin = isEditando ? usuarioExistente['admin'] : false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(isEditando ? "Editar Usuário" : "Cadastrar Usuário", style: const TextStyle(color: Color(0xFF101C8B))),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: "Nome")),
                      TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "E-mail")),
                      TextField(
                        controller: senhaCtrl, 
                        obscureText: true, 
                        decoration: InputDecoration(labelText: isEditando ? "Nova Senha (deixe vazio para manter)" : "Senha")
                      ),
                      TextField(controller: codigoCtrl, decoration: const InputDecoration(labelText: "Código (ex: 123456)")),
                      TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Equipe")),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: isAdmin,
                            activeColor: const Color(0xFF101C8B),
                            onChanged: (val) => setStateModal(() => isAdmin = val!),
                          ),
                          const Text("É Administrador?"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (isEditando)
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: TextButton.icon(
                      onPressed: () => excluirUsuario(usuarioExistente['db_id']),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                    ),
                  ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101C8B)),
                  onPressed: () {
                    if (nomeCtrl.text.isEmpty || emailCtrl.text.isEmpty || codigoCtrl.text.isEmpty) return;
                    if (!isEditando && senhaCtrl.text.isEmpty) return;

                    Map<String, dynamic> dados = {
                      "nome": nomeCtrl.text,
                      "email": emailCtrl.text,
                      "senha": senhaCtrl.text,
                      "admin": isAdmin,
                      "codigo": codigoCtrl.text,
                      "time": timeCtrl.text.isEmpty ? null : timeCtrl.text,
                    };

                    if (isEditando) {
                      editarUsuario(usuarioExistente['db_id'], dados);
                    } else {
                      _enviarRequisicao('$baseUrl/auth/criar_conta', 'POST', dados, "Criado com sucesso!");
                    }
                  },
                  child: Text(isEditando ? "Atualizar" : "Salvar", style: const TextStyle(color: Colors.white)),
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
          return item["nome"]!.toLowerCase().contains(termo) ||
                 item["vis_id"]!.toLowerCase().contains(termo);
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
              
              Expanded(child: 
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Center(
                        child: Text("Gerenciar Pessoas", style: TextStyle(color: Color(0xFF101C8B), fontWeight: FontWeight.bold, fontSize: 28)),
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
                                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Pesquisar", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  SizedBox(
                                    width: 50, height: 50,
                                    child: ElevatedButton(
                                      onPressed: () => _abrirModalUsuario(),
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
                                      width: isMobile ? 800 : 900, 
                                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)), 
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty.all(const Color(0xFF101C8B)),
                                        headingTextStyle: const TextStyle(color: Colors.white),
                                        columnSpacing: 40,
                                        dataRowMinHeight: 48,
                                        showCheckboxColumn: false,
                                        columns: const [
                                          DataColumn(label: Text("ID")),
                                          DataColumn(label: Text("Nome")),
                                          DataColumn(label: Text("Equipe")),
                                          DataColumn(label: Text("Tipo")),
                                        ],
                                        rows: listaFiltrada.map((item) {
                                          return DataRow(
                                            onSelectChanged: (selected) {
                                              if (selected == true) {
                                                _abrirModalUsuario(usuarioExistente: item);
                                              }
                                            },
                                            cells: [
                                              DataCell(Text(item["vis_id"])),
                                              DataCell(Text(item["nome"])),
                                              DataCell(Text(item["time"])),
                                              DataCell(Text(item["tipo_texto"])),
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