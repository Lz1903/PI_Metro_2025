import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:metro_2025_2/tela_inicial_admin.dart';
import 'package:metro_2025_2/tela_perfil.dart';



class TelaCadastroMaterial extends StatefulWidget{
  const TelaCadastroMaterial({super.key});

  @override
  State<TelaCadastroMaterial> createState() => _TelaCadastroMaterialState();
}
class _TelaCadastroMaterialState extends State<TelaCadastroMaterial> {
  bool isMaterialSelecionado = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1780),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
          ),
        ],
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
      drawer: Drawer(
        backgroundColor: Color(0xFF1A1780),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white,),
              title: const Text('Perfil', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaPerfil()));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.house_rounded, color: Colors.white,),
              title: const Text('Tela Inicial', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaInicialAdmin()));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white,),
              title: const Text('Configurações', style: TextStyle(color: Colors.white),),
              onTap: () {
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: const Text(
              "Cadastro de Material",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isMaterialSelecionado = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMaterialSelecionado 
                          ? Color(0xFF1A1780)
                          : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: AutoSizeText(
                          "Material",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isMaterialSelecionado
                              ? Colors.white
                              : Color(0xFF1A1780),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isMaterialSelecionado = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isMaterialSelecionado
                          ? const Color(0xFF1A1780)
                          : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: AutoSizeText(
                          "Instrumento",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: !isMaterialSelecionado
                            ? Colors.white
                            : Color(0xFF1A1780),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Nome:",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: TextStyle(color: Color(0xFF1A1780)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Código:",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: TextStyle(color: Color(0xFF1A1780)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text("Saldo:",
              style: TextStyle(
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  decoration: InputDecoration(
                    labelText: "",
                    labelStyle: TextStyle(color: Color(0xFF1A1780)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1A1780)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 40),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
      ),
    );
  }
}