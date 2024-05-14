import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_stock_clientes/firebase_options.dart';
import 'package:gestion_stock_clientes/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Stock y Clientes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 148, 224, 230)),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
