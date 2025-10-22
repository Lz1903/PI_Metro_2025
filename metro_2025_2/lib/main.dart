// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:metro_2025_2/tela_inicial.dart';
import 'package:metro_2025_2/tela_login.dart';
import 'package:metro_2025_2/tela_inicial_admin.dart';
import 'package:metro_2025_2/tela_login_mobile.dart';
void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  bool isMobilePlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobilePlatform();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: mobile ? const TelaLoginMobile() : const TelaLogin(),
    );
  }
}