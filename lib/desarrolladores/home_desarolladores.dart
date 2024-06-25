// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_stock_clientes/login.dart';

class HomeDesarrolladores extends StatefulWidget {
  const HomeDesarrolladores({super.key});

  @override
  State<HomeDesarrolladores> createState() => _HomeDesarrolladores();
}

class _HomeDesarrolladores extends State<HomeDesarrolladores> {
  //Interfaz gráfica
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 246, 248),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FormButton(
                  text: "Crear admin",
                  onPressed: () {},
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                FormButton(
                  text: "Gestionar admins",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
        icon: Icon(Icons.logout),
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
