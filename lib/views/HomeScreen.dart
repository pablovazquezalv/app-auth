import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:app_auth/models/Code.dart';
import '../models/ip.dart'; // Asegúrate de importar tus modelos y dependencias necesarias

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late Timer _timer2;
  int seconds = 15;
  List<Code> listaTarjetas = [];

  @override
  void initState() {
    super.initState();
    // Ejecutar getAllCodes al iniciar y luego cada 15 segundos
    getAllCodes();
    seconds = 15;
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      getAllCodes();
      seconds = 15;
    });
    _timer2 = Timer.periodic(const Duration(seconds: 10), (timer) {
      validateToken();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    seconds = 15;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 33, 48, 73),
              Color.fromARGB(255, 25, 25, 25),
            ],
          ),
        ),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Generador de códigos de logeo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    logout();
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  'Códigos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: ListView.builder(
                itemCount: listaTarjetas.length,
                itemBuilder: (BuildContext context, int index) {
                  Code code = listaTarjetas[index];

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Contenido del contenedor
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Código: ${code.code}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // TimerCountdown(
                                  //   format: CountDownTimerFormat.secondsOnly,
                                  //   endTime: DateTime.now().add(
                                  //     Duration(
                                  //       seconds: seconds,
                                  //     ),
                                  //   ),
                                  //   colonsTextStyle: const TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 16,
                                  //   ),
                                  // ),
                                  Icon(
                                    code.status
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        code.status ? Colors.green : Colors.red,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getAllCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    final response = await http.get(
      Uri.https('danielypablo.tech', '/api/getCodesAccess'),
      //Uri.parse('http://${Constants.ip}/api/getCodesAccess'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<Code> listaRestaurantes = [];
      print(jsonData);

      if (jsonData is List) {
        listaRestaurantes =
            jsonData.map<Code>((data) => Code.fromJson(data)).toList();
      }

      setState(() {
        listaTarjetas = listaRestaurantes;
      });
    } else {
      print("Error en la solicitud: ${response.body}");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    final response = await http.get(
      Uri.https('danielypablo.tech', '/api/logout'),
      //Uri.parse('http://${Constants.ip}/api/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      prefs.remove('token');
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al cerrar sesión'),
        ),
      );
    }
  }

  Future<void> validateToken() async {
    // Simular un proceso de inicialización, por ejemplo, cargar datos
    // Puedes sustituir este Future.delayed por una operación asíncrona real
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response =
        await http.get(Uri.https('danielypablo.tech', '/api/accessApp'),
            // Uri.parse('http://${Constants.ip}/api/accessApp'),
            headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON
    } else {
      //si la ruta actual es login no redirigir ni mostrar mensaje
      if (ModalRoute.of(context)!.settings.name != '/login') {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu sesión ha caducado')),
        );
      }
    }
  }
}
