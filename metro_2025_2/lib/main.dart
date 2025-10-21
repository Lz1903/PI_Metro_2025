// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:metro_2025_2/tela_inicial.dart';
import 'package:metro_2025_2/tela_login.dart';
import 'package:metro_2025_2/tela_inicial_admin.dart';
void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicial(),
    );
  }
}