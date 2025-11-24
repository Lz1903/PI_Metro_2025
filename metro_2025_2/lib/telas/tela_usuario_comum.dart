import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/telas/tela_devolucao_comum.dart'; 
import 'package:metro_2025_2/telas/tela_retirada_comum.dart';
import 'package:metro_2025_2/telas/tela_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TelaUsuarioComum extends StatefulWidget {
  const TelaUsuarioComum({super.key});

  @override
  State<TelaUsuarioComum> createState() => _TelaUsuarioComumState();
}

class _TelaUsuarioComumState extends State<TelaUsuarioComum> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Map<String, dynamic>> meusItens = [];
  bool isLoading = true;
  String nomeUsuario = "Usuário";

  final String baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    
    setState(() {
      nomeUsuario = prefs.getString("user_name") ?? "Colaborador"; 
    });

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/pedidos/listar_instrumentos_usuario"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          meusItens = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        print("Erro ao carregar itens: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Erro de conexão: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fazerLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const TelaLogin()), 
      (route) => false
    );
  }

  void _irParaRetirada() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaRetiradaComum()));
    _carregarDadosIniciais();
  }

  void _irParaDevolucao() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaDevolucaoComum()));
    _carregarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF101C8B),
        toolbarHeight: 100,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/imagens/logo_metro_mobile.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 10),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 30),
              onPressed: _fazerLogout,
              tooltip: "Sair do Sistema",
            ),
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, $nomeUsuario",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101C8B)),
            ),
            const Text(
              "O que você deseja fazer agora?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                bool empilhar = constraints.maxWidth < 500;
                
                Widget cardRetirar = _buildActionCard(
                  title: "Nova Retirada",
                  subtitle: "Buscar material ou instrumento",
                  icon: Icons.add_shopping_cart,
                  color: Colors.blue,
                  onTap: _irParaRetirada,
                );

                Widget cardDevolver = _buildActionCard(
                  title: "Realizar Devolução",
                  subtitle: "Devolver item em minha posse",
                  icon: Icons.assignment_return,
                  color: Colors.orange,
                  onTap: _irParaDevolucao,
                );

                if (empilhar) {
                  return Column(children: [
                    SizedBox(width: double.infinity, height: 120, child: cardRetirar),
                    const SizedBox(height: 15),
                    SizedBox(width: double.infinity, height: 120, child: cardDevolver),
                  ]);
                } else {
                  return Row(children: [
                    Expanded(child: SizedBox(height: 140, child: cardRetirar)),
                    const SizedBox(width: 20),
                    Expanded(child: SizedBox(height: 140, child: cardDevolver)),
                  ]);
                }
              },
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Meus Itens em Posse",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF101C8B)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF101C8B)),
                  onPressed: _carregarDadosIniciais,
                  tooltip: "Atualizar lista",
                )
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : meusItens.isEmpty
                  ? _buildEmptyState()
                  : _buildItemsList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionCard({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
            borderRadius: BorderRadius.circular(15)
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 60, color: Colors.green.withOpacity(0.5)),
          const SizedBox(height: 15),
          const Text(
            "Tudo certo por aqui!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Text(
            "Você não possui nenhum instrumento pendente de devolução.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      itemCount: meusItens.length,
      itemBuilder: (context, index) {
        final item = meusItens[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build, color: Colors.orange),
            ),
            title: Text(
              item['nome'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1780)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text("ID: ${item['id']}"),
                Text("Local de Origem: ${item['local']}"),
                if (item['calibracao'] != null)
                  Text("Calibração: ${_formatDate(item['calibracao'])}", style: const TextStyle(fontSize: 12, color: Colors.red)),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _irParaDevolucao, 
              child: const Text("Devolver", style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dataIso) {
    try {
      final date = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dataIso;
    }
  }
}