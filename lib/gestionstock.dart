// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_cast, prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_stock_clientes/login.dart';

class GestionStock extends StatefulWidget {
  const GestionStock({super.key});

  @override
  State<GestionStock> createState() => _GestionStock();
}

class _GestionStock extends State<GestionStock> {
  //Controller para la barra de búsqueda
  late TextEditingController _searchController;
  //Lista para almacenar las categorías
  List<String> categorias = [];
  //Categorias seleccionada, por defecto: "Todas"
  var categoriaSeleccionada = "Todas";

  // En el método initState o en cualquier otro lugar apropiado
  void recuperarCategorias() async {
    //Recuperamos los documentos de la colección productos
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('productos').get();

    //Declaramos un set para guardar las categorias recuperadas
    Set<String> categoriasSet = {};

    //Añadimos la opción todas
    categoriasSet.add("Todas");

    //Para cada documento recuperado
    snapshot.docs.forEach((DocumentSnapshot document) {
      //Se obtienen los datos del documento
      Map<String, dynamic> dataDocumento =
          document.data() as Map<String, dynamic>;

      //Se recupera la categoría del documento
      String category = dataDocumento['categoria'];

      //Se agrega la categoria al set
      categoriasSet.add(category);
    });

    //Una vez agregadas todas las categorías al Set, seteamos categorias
    setState(() {
      categorias = categoriasSet.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarCategorias();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 246, 248),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 178, 232, 222),
        title: Text("Gestión de Stock"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.009)
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color.fromARGB(255, 244, 224, 147),
                  ),
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: DropdownButton<String>(
                    //Valor inicial = 'Todas'
                    value: categoriaSeleccionada,
                    //Al seleccionar una categoría, seteamos categoriaSeleccionada
                    onChanged: (String? newValue) {
                      setState(() {
                        categoriaSeleccionada = newValue!;
                      });
                    },
                    //Los items están en la lista 'categorias'
                    items: categorias
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    dropdownColor: Color.fromARGB(255, 212, 193, 117),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre de producto',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Llama a setState para reconstruir la lista con los resultados filtrados
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    agregarProducto();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 244, 224, 147),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Agregar producto",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              //Suscribimos a la colección productos
              stream: categoriaSeleccionada == "Todas"
                  ? FirebaseFirestore.instance
                      .collection('productos')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('productos')
                      .where('categoria', isEqualTo: categoriaSeleccionada)
                      .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay productos agregados.'));
                }

                // Filtra los resultados basados en el texto ingresado en el TextField de búsqueda
                var filteredProducts = snapshot.data!.docs.where((document) {
                  final Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  final nombre = data['nombre'] as String;
                  return nombre
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();

                return Container(
                  padding: EdgeInsets.only(top: 10.0, left: 10, right: 10),
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> productoData =
                          filteredProducts[index].data()
                              as Map<String, dynamic>;
                      var productoId = filteredProducts[index].id;
                      var nombre = productoData["nombre"];
                      var precio = productoData["precio"];
                      var cantidad = productoData["cantidad"];
                      var categoria = productoData["categoria"];

                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(255, 225, 201, 179),
                          ),
                          child: ListTile(
                            title: Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Precio: \$$precio | Cantidad: $cantidad | Categoría: $categoria",
                              style: const TextStyle(color: Colors.black87),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('productos')
                                        .doc(productoId)
                                        .delete();
                                    recuperarCategorias();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 244, 224, 147)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Eliminar",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                ElevatedButton(
                                  onPressed: () {
                                    editarProduto(nombre, precio, cantidad,
                                        categoria, productoId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 244, 224, 147)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Editar",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  agregarProducto() {
    //Controladores
    TextEditingController nombre = TextEditingController();
    TextEditingController precio = TextEditingController();
    TextEditingController cantidad = TextEditingController();
    TextEditingController categoria = TextEditingController();

    //showDialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 225, 201, 179),
            title: Text("Agregar producto", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: precio,
                  decoration: InputDecoration(
                    labelText: "Precio",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: cantidad,
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: categoria,
                  decoration: InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        if (nombre.text.isNotEmpty &&
                            precio.text.isNotEmpty &&
                            cantidad.text.isNotEmpty &&
                            categoria.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('productos')
                              .add({
                            'nombre': nombre.text,
                            'precio': precio.text,
                            'cantidad': cantidad.text,
                            'categoria': categoria.text
                          });
                          recuperarCategorias();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '¡Debe completar todos los campos!',
                                    textAlign: TextAlign.center),
                                duration: Duration(seconds: 2)),
                          );
                        }
                      },
                      child: Text("Agregar",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                ],
              )
            ],
          );
        });
  }

  editarProduto(nombreini, precioini, cantidadini, categoriaini, productoid) {
    //Controladores
    TextEditingController nombre = TextEditingController(text: nombreini);
    TextEditingController precio = TextEditingController(text: precioini);
    TextEditingController cantidad = TextEditingController(text: cantidadini);
    TextEditingController categoria = TextEditingController(text: categoriaini);

    //showDialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 225, 201, 179),
            title: Text("Editar producto", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: precio,
                  decoration: InputDecoration(
                    labelText: "Precio",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: cantidad,
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: categoria,
                  decoration: InputDecoration(
                    labelText: "Categoría",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        if (nombre.text.isNotEmpty &&
                            precio.text.isNotEmpty &&
                            cantidad.text.isNotEmpty &&
                            categoria.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('productos')
                              .doc(productoid)
                              .update({
                            'nombre': nombre.text,
                            'precio': precio.text,
                            'cantidad': cantidad.text,
                            'categoria': categoria.text
                          });
                          recuperarCategorias();
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '¡Debe completar todos los campos!',
                                    textAlign: TextAlign.center),
                                duration: Duration(seconds: 2)),
                          );
                        }
                      },
                      child: Text("Actualizar",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                ],
              )
            ],
          );
        });
  }
}
