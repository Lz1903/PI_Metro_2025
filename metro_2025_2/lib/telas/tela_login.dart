import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metro_2025_2/telas/visao_geral.dart';
import 'package:metro_2025_2/telas/tela_usuario_comum.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TelaLogin extends StatefulWidget{
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  
  bool isLoading = false;
  bool _isObscure = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("http://localhost:8000/auth/login"); 
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data["access_token"]);
        await prefs.setBool('is_admin', data["admin"]);
        await prefs.setString('refresh_token', data["refresh_token"]);
        await prefs.setString('user_name', data["nome"] ?? "Usuário"); 

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bem-vindo, ${data["nome"] ?? "usuário"}!"),
            backgroundColor: Colors.green,
          ),
        );

        if (data["admin"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VisaoGeral()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaUsuarioComum()),
          );
        }
      } else {
        if (!mounted) return;
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error["detail"] ?? "Erro no login"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de conexão: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulEscuro = const Color(0xFF1A1780);
    
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;
        bool isMobile = width < 450;
        
        Widget formContent = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8)
                ),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Image.asset(
                    'assets/imagens/logo_metro.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 80, color: Color(0xFF1A1780)),
                  ),
                ),
              ),
              
              Row(
                children: const [
                  Expanded(child: ColoredBox(color: Colors.blue, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.green, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.red, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.yellow, child: SizedBox(height: 8))),
                  Expanded(child: ColoredBox(color: Colors.purple, child: SizedBox(height: 8))),
                ],
              ),
              const SizedBox(height: 24),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("E-mail",
                  style: TextStyle(
                    color: azulEscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: azulEscuro),
                  hintText: "exemplo@metro.sp.gov.br",
                  labelStyle: TextStyle(color: azulEscuro),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: azulEscuro, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: azulEscuro.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Senha",
                  style: TextStyle(
                    color: azulEscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: senhaController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: azulEscuro),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: azulEscuro,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  labelStyle: TextStyle(color: azulEscuro),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: azulEscuro, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: azulEscuro.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => fazerLogin(),
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulEscuro,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isLoading ? null : fazerLogin,
                child: isLoading 
                  ? const SizedBox(
                      height: 24, width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
              ),
            ),
            
            if (!isMobile) ...[
              const SizedBox(height: 12),
              const SizedBox(height: 20),
            ]
          ],
        );

        if (isMobile) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: constraints.maxHeight * 0.35,
                    width: constraints.maxWidth,
                    color: azulEscuro,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Image.asset(
                        'assets/imagens/logo_metro_mobile.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                
                SlideTransition(
                  position: _slideAnimation,
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
                
                const SizedBox(height: 50),
                
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: formContent
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          );
        } 
        
        else {
          return Container(
            color: azulEscuro,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    ),
                    child: formContent,
                  ),
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}