import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:metro_2025_2/widgets/AlertaAppbar.dart';
import 'package:metro_2025_2/widgets/menu_lateral.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VisaoGeral extends StatefulWidget {
  const VisaoGeral({super.key});

  @override
  State<VisaoGeral> createState() => _VisaoGeral();
}

class _VisaoGeral extends State<VisaoGeral> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List historicoPreview = [];
  
  bool isLoading = true;
  int totalMateriais = 0;
  int totalInstrumentos = 0;
  Map<String, int> estoquePorBase = {}; 

  final String baseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    carregarDadosDashboard();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  Future<void> carregarDadosDashboard() async {
    setState(() => isLoading = true);
    
    final token = await _getToken();
    if (token == null) return;

    final headers = {"Authorization": "Bearer $token"};

    try {
      final responses = await Future.wait([
        http.get(Uri.parse("$baseUrl/pedidos/historico"), headers: headers),
        http.get(Uri.parse("$baseUrl/pedidos/listar_materiais"), headers: headers),
        http.get(Uri.parse("$baseUrl/pedidos/listar_instrumentos"), headers: headers),
      ]);

      if (responses[0].statusCode == 200) {
        final List data = json.decode(responses[0].body);
        historicoPreview = data.take(7).toList(); 
      }

      List materiais = [];
      if (responses[1].statusCode == 200) {
        materiais = json.decode(responses[1].body);
        totalMateriais = materiais.length;
      }

      List instrumentos = [];
      if (responses[2].statusCode == 200) {
        instrumentos = json.decode(responses[2].body);
        totalInstrumentos = instrumentos.length;
      }

      final todosItens = [...materiais, ...instrumentos];
      Map<String, int> contagemBase = {};
      
      for (var item in todosItens) {
        String local = item['local']?.toString() ?? 'Indefinido';
        if (local.contains('-')) {
          local = local.split('-')[0].trim();
        }
        contagemBase[local] = (contagemBase[local] ?? 0) + 1;
      }
      
      var entriesOrdenadas = contagemBase.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      estoquePorBase = Map.fromEntries(entriesOrdenadas.take(6));

      setState(() => isLoading = false);

    } catch (e) {
      print("Erro ao carregar dashboard: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
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
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Image.asset(
                'assets/imagens/logo_metro_mobile.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ],
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const SizedBox(width: 250, child: MenuLateral()),
          
          Expanded(
            child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Visão Geral do Sistema",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF101C8B)),
                    ),
                    const SizedBox(height: 20),
                    isMobile 
                    ? Column(
                        children: [
                          _buildSummaryCard("Total Materiais", totalMateriais.toString(), Icons.inventory_2, Colors.blue),
                          const SizedBox(height: 10),
                          _buildSummaryCard("Total Instrumentos", totalInstrumentos.toString(), Icons.build, Colors.orange),
                          const SizedBox(height: 10),
                          _buildSummaryCard("Total Itens", (totalMateriais + totalInstrumentos).toString(), Icons.bar_chart, Colors.green),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildSummaryCard("Total Materiais", totalMateriais.toString(), Icons.inventory_2, Colors.blue)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildSummaryCard("Total Instrumentos", totalInstrumentos.toString(), Icons.build, Colors.orange)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildSummaryCard("Total Itens", (totalMateriais + totalInstrumentos).toString(), Icons.bar_chart, Colors.green)),
                        ],
                      ),
                    const SizedBox(height: 20),
                    isMobile 
                    ? Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: _buildCardContainer(
                              title: "Distribuição de Itens",
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: _getPieSections(),
                                ),
                              ),
                              legend: _buildLegend(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 300,
                            child: _buildCardContainer(
                              title: "Top Estoque por Base",
                              child: BarChart(_getBarChartData()),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 400,
                            child: _buildCardContainer(
                              title: "Últimas Movimentações",
                              padding: EdgeInsets.zero,
                              child: _buildHistoricoList(),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 500,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildCardContainer(
                                title: "Distribuição de Itens",
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections: _getPieSections(),
                                  ),
                                ),
                                legend: _buildLegend(),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: _buildCardContainer(
                                title: "Top Estoque por Base",
                                child: BarChart(_getBarChartData()),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: _buildCardContainer(
                                title: "Últimas Movimentações",
                                padding: EdgeInsets.zero,
                                child: _buildHistoricoList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<PieChartSectionData> _getPieSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: totalMateriais.toDouble(),
        title: totalMateriais > 0 ? '${((totalMateriais/(totalMateriais+totalInstrumentos))*100).toStringAsFixed(0)}%' : '0%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: totalInstrumentos.toDouble(),
        title: totalInstrumentos > 0 ? '${((totalInstrumentos/(totalMateriais+totalInstrumentos))*100).toStringAsFixed(0)}%' : '0%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  BarChartData _getBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (estoquePorBase.values.isNotEmpty ? estoquePorBase.values.first.toDouble() : 10) * 1.2,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value.toInt() >= estoquePorBase.keys.length) return const Text('');
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  estoquePorBase.keys.elementAt(value.toInt()),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: estoquePorBase.entries.map((entry) {
        int index = estoquePorBase.keys.toList().indexOf(entry.key);
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: const Color(0xFF1A1780),
              width: 20,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: (estoquePorBase.values.first.toDouble() * 1.2), color: Colors.grey[200]),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoricoList() {
    if (historicoPreview.isEmpty) return const Center(child: Text("Sem histórico recente"));
    
    return ListView.separated(
      itemCount: historicoPreview.length,
      separatorBuilder: (c, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = historicoPreview[index];
        final data = DateTime.parse(item["data_hora"]).toLocal();
        final dataFormatada = "${data.day.toString().padLeft(2, '0')}/"
                              "${data.month.toString().padLeft(2, '0')}/"
                              "${data.year} - "
                              "${data.hour.toString().padLeft(2, '0')}:"
                              "${data.minute.toString().padLeft(2, '0')}";

        String textoStatus = "";
        Color corStatus = Colors.black;

        if (item['tipo'] == 'material') {
          textoStatus = "${item['quantidade']}";
          corStatus = (item['quantidade'] ?? 0) < 0 ? Colors.red : Colors.green;
        } else {
          if (item['quantidade'] == null) {
            textoStatus = "Retirado";
            corStatus = Colors.red;
          } else {
            textoStatus = "Devolvido";
            corStatus = Colors.green;
          }
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: item['tipo'] == 'material' ? Colors.blue[100] : Colors.orange[100],
            child: Icon(
              item['tipo'] == 'material' ? Icons.inventory_2 : Icons.build,
              color: const Color(0xFF1A1780),
              size: 20,
            ),
          ),
          title: Text(item["nome_item"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(
            "${item["usuario"]} • ${dataFormatada}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: Text(
            textoStatus,
            style: TextStyle(fontWeight: FontWeight.bold, color: corStatus),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1780))),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required String title, required Widget child, Widget? legend, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1780))),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
          if (legend != null) legend,
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.blue, "Materiais"),
          const SizedBox(width: 15),
          _legendItem(Colors.orange, "Instrumentos"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}