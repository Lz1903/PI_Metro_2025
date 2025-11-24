import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://localhost:8000"; 

class AlertaAppBar extends StatefulWidget {
  const AlertaAppBar({super.key});

  @override
  State<AlertaAppBar> createState() => _AlertaAppBarState();
}

class _AlertaAppBarState extends State<AlertaAppBar> {
  int _totalAlertas = 0;
  Map<String, int> _detalhesAlertas = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAlertas();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _carregarAlertas() async {
    setState(() {
      _isLoading = true;
    });

    String? token = await _getToken();
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pedidos/alertas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalAlertas = data['total'] ?? 0;
          _detalhesAlertas = Map<String, int>.from(data['detalhes'] ?? {});
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarListaAlertas() {
    const Map<String, String> labels = {
      "em_falta": "itens com Falta de estoque",
      "pouco_estoque": "itens com Pouco estoque",
      "validade_vencida": "itens com Validade vencida",
      "validade_expirar": "itens perto da Validade",
      "calibracao_vencida": "instrumentos com Calibração vencida",
      "calibracao_expirar": "instrumentos perto da Calibração",
    };

    if (_totalAlertas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum alerta pendente!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final listaWidgets = _detalhesAlertas.entries
            .where((entry) => entry.value > 0 && labels.containsKey(entry.key))
            .map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "• Há ${entry.value} ${labels[entry.key]}",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            })
            .toList();

        return AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text("Alerta:",style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listaWidgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool temAlerta = _totalAlertas > 0;
    
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 30),
            onPressed: _isLoading ? null : _mostrarListaAlertas,
            tooltip: 'Alertas',
          ),
          
          if (temAlerta && !_isLoading)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    _totalAlertas > 99 ? '99+' : '$_totalAlertas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
          if (_isLoading)
            const Positioned(
              right: 10,
              top: 10,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}