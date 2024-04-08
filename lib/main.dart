import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_auth/views/CodeScreen.dart';
import 'package:app_auth/views/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/ip.dart';
import 'views/LoginScreen.dart';

void main() {
//   HttpClient httpClient = HttpClient()
//     ..badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/code': (context) => const CodeScreen(),
        '/home': (context) => const HomeScreen(), // Cambiar a 'HomeScreen()
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simular un proceso de inicialización, por ejemplo, cargar datos
    // Puedes sustituir este Future.delayed por una operación asíncrona real
    Timer(const Duration(seconds: 3), () {
      // Después de 3 segundos, navegar a la siguiente pantalla
      validateToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 33, 48, 73),
            Color.fromARGB(255, 25, 25, 25),
          ],
        )),
        child: Center(
          child: Image.asset(
            'assets/laravelIcon.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }

  Future<void> validateToken() async {
    // Simular un proceso de inicialización, por ejemplo, cargar datos
    // Puedes sustituir este Future.delayed por una operación asíncrona real
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response =
        await http.get(Uri.https('danielypablo.tech', '/api/validateToken'),
            //Uri.parse('http://${Constants.ip}/api/validateToken'),
            headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON
      print(response.body);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu sesion ha caducado2')),
      );
    }
  }
}
