import 'package:flutter/material.dart';
import 'tela_inicial.dart';

class TelaPerfil extends StatefulWidget{
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfil();
}
class _TelaPerfil extends State<TelaPerfil> {
  
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
              leading: const Icon(Icons.house_rounded, color: Colors.white,),
              title: const Text('Tela Inicial', style: TextStyle(color: Colors.white),),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TelaInicial()));
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Perfil",
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF1A1780),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}