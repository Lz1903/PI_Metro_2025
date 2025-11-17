import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  bool isMaterial = true;
  bool isLoading = false;

  // Controllers para Material
  final idMaterialController = TextEditingController();
  final nomeMaterialController = TextEditingController();
  final qtdController = TextEditingController();
  final limiteMinimoController = TextEditingController();
  final localMaterialController = TextEditingController();
  final tipoController = TextEditingController();
  final vencimentoController = TextEditingController();

  // Controllers para Instrumento
  final idInstrumentoController = TextEditingController();
  final nomeInstrumentoController = TextEditingController();
  final localInstrumentoController = TextEditingController();
  final calibracaoController = TextEditingController();

  Future<void> enviarCadastro() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }

    try {
      final url = Uri.parse(
        isMaterial
            ? "http://127.0.0.1:8000/pedidos/criar_material"// use 10.0.2.2 no Android
            : "http://127.0.0.1:8000/pedidos/criar_instrumento",// use 10.0.2.2 no Android
      );

      final body = isMaterial
          ? {
              "id": idMaterialController.text.trim(),
              "nome": nomeMaterialController.text.trim(),
              "quantidade": int.tryParse(qtdController.text.trim()) ?? 0,
              "limite_minimo": int.tryParse(limiteMinimoController.text.trim()) ?? 0,
              "local": localMaterialController.text.trim(),
              "tipo": tipoController.text.trim(),
              "vencimento": vencimentoController.text.isEmpty
                  ? null
                  : vencimentoController.text, // yyyy-MM-dd
            }
          : {
              "id": idInstrumentoController.text.trim(),
              "nome": nomeInstrumentoController.text.trim(),
              "local": localInstrumentoController.text.trim(),
              "calibracao": calibracaoController.text.isEmpty
                  ? null
                  : calibracaoController.text, // yyyy-MM-dd
            };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["mensagem"] ?? "Cadastro realizado!")),
        );
        limparCampos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["detail"] ?? "Erro no cadastro")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  void limparCampos() {
    idMaterialController.clear();
    nomeMaterialController.clear();
    qtdController.clear();
    limiteMinimoController.clear();
    localMaterialController.clear();
    tipoController.clear();
    vencimentoController.clear();
    idInstrumentoController.clear();
    nomeInstrumentoController.clear();
    localInstrumentoController.clear();
    calibracaoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Row(
            children: const [
              Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 10))),
              Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 10))),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text(
              isMaterial ? "Cadastro de Material" : "Cadastro de Instrumento",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            ),
            ),
            // alternador entre material e instrumento
            ToggleButtons(
              isSelected: [isMaterial, !isMaterial],
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: const Color(0xFF1A1780),
              onPressed: (index) {
                setState(() => isMaterial = (index == 0));
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Material"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Instrumento"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: isMaterial
                    ? _camposMaterial()
                    : _camposInstrumento(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1780),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: isLoading ? null : enviarCadastro,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Cadastrar",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _camposMaterial() {
    return [
      TextField(controller: idMaterialController, 
      decoration: InputDecoration(
        labelText: "Código", 
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: nomeMaterialController, 
      decoration: InputDecoration(
        labelText: "Nome",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: qtdController, keyboardType: TextInputType.number, 
      decoration: InputDecoration(
        labelText: "Quantidade",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(
      controller: limiteMinimoController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Limite mínimo (para pouco estoque)",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: localMaterialController, 
      decoration: InputDecoration(
        labelText: "Local",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: tipoController, 
      decoration: InputDecoration(
        labelText: "Tipo",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: vencimentoController, 
      decoration: InputDecoration(
        labelText: "Vencimento (yyyy-MM-dd)",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
    ];
  }

  List<Widget> _camposInstrumento() {
    return [
      TextField(controller: idInstrumentoController, 
      decoration: InputDecoration(
        labelText: "Código",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: nomeInstrumentoController, 
      decoration: InputDecoration(
        labelText: "Nome",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: localInstrumentoController, 
      decoration: InputDecoration(
        labelText: "Local",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
      const SizedBox(height: 10),
      TextField(controller: calibracaoController, 
      decoration: InputDecoration(
        labelText: "Calibração (yyyy-MM-dd)",
        labelStyle: TextStyle(color: Color(0xFF1A1780)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xF1A1780)),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
    ];
  }
}