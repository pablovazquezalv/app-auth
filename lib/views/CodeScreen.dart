import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ip.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({Key? key}) : super(key: key);

  @override
  _CodeScreenState createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

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
      child: ListView(
        children: [
          //texto de login
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                'Código de verificación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Center(
              child: Text(
                'Ingresa el codigo que enviamos a tu correo',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Form(
            key: _formKey,
            child: Column(
              children: [
                //label de usuario a la izquierda
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Código',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                //input de usuario
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: TextFormField(
                    controller: _codeController,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Establece el color del texto

                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(12, 15, 12,
                          15), // Ajusta los valores según sea necesario
                      // Ajusta el valor de vertical según el tamaño deseado
                      hintText: '',
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    scrollPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    validator: (value) {
                      if (value.toString().trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                //botón de login
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity,
                          60), // Ajusta el valor de 60 según el tamaño deseado
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        loginCodeApp();
                      }
                    },
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> loginCodeApp() async {
    final String code = _codeController.text;
    print('Código ingresado: $code'); // Verifica el valor del código

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print(code);
    print(token);
    final Map<String, dynamic> requestBody = {
      'code': code,
    };
    final response = await http.post(
      Uri.https('danielypablo.tech', '/api/loginCodeApp'),
      // Uri.parse('http://${Constants.ip}/api/loginCodeApp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody), // Convierte el cuerpo a JSON
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve una respuesta OK, parseamos el JSON
      print(response.body);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código incorrecto')),
      );
    }
  }
}
