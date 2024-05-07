// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_stock_clientes/gestionstock.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  //Controladores de correo electrónico y contraseña
  late String email;
  late String password;

  //Interfaz gráfica
  @override
  Widget build(BuildContext context) {
    //Obtenemos el alto de la pantalla
    double screenHeight = MediaQuery.of(context).size.height;

    //Scaffold
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 246, 248),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .12),

            //TITULO: ¡Bienvenido a Gestión de Stock
            Center(
              child: Text(
                '¡Bienvenido a Gestión de Stock!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //SUBTITULO: Iniciá sesión para continuar
            Center(
              child: Text(
                'Iniciá sesión para continuar',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(.6),
                ),
              ),
            ),

            //ESPACIO
            SizedBox(height: screenHeight * .12),

            //CAJA DE TEXTO PARA EL CORREO
            InputField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              labelText: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),

            //ESPACIO
            SizedBox(height: screenHeight * .025),

            //CAJA DE TEXTO PARA LA CONTRASEÑA
            InputField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              labelText: 'Contraseña',
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),

            //ESPACIO
            SizedBox(
              height: screenHeight * .075,
            ),

            //BOTÓN INICIAR SESIÓN
            FormButton(
              text: 'Iniciar sesión',
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GestionStock()),
                  );
                } catch (error) {
                  mostrarCuadro(error.toString());
                }
              },
            ),

            SizedBox(height: screenHeight * .0075),

            //ESPACIO
            SizedBox(height: screenHeight * .15),

            //REGISTRARSE
            TextButton(
                onPressed: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registrarse()),
                  );*/
                },
                child: RichText(
                  text: const TextSpan(
                    text: "¿No tenés una cuenta? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '¡Registrate!',
                        style: TextStyle(
                          color: Color.fromARGB(255, 120, 101, 27),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  //Mostrar cuadros de alerta
  mostrarCuadro(text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
                child: Text(
              text,
              style: TextStyle(fontSize: 18),
            )),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Center(child: Text('Aceptar'))),
            ],
          );
        });
  }
}

//Clase del InputField
class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool obscureText;
  const InputField(
      {this.labelText,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.autoFocus = false,
      this.obscureText = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: MediaQuery.of(context).size.width > 600 ? 0.3 : 0.8,
      child: TextField(
        autofocus: autoFocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

//Clase del FormButton
class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  const FormButton({this.text = '', this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return FractionallySizedBox(
      widthFactor: MediaQuery.of(context).size.width > 600 ? 0.15 : 0.8,
      child: ElevatedButton(
        onPressed: onPressed as void Function()?,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color.fromARGB(255, 250, 215, 75),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
