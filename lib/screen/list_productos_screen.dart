import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({Key? key}) : super(key: key);

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  late Stream<QuerySnapshot> _productosStream;

  @override
  void initState() {
    super.initState();
    _productosStream = FirebaseFirestore.instance.collection('productos').snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _searchProducts(String query) {
    String lowerCaseQuery = query.toLowerCase();
    return FirebaseFirestore.instance
        .collection('productos')
        .where('nombreBusqueda', isGreaterThanOrEqualTo: lowerCaseQuery)
        .where('nombreBusqueda', isLessThan: lowerCaseQuery + '\uf8ff')
        .snapshots();
  }

  Future<void> _agregarEditarProducto({String? docId}) async {
    if (docId != null) {
      DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('productos').doc(docId).get();
      Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
      _nombreController.text = data['nombre'] ?? '';
      _descripcionController.text = data['descripcion'] ?? '';
      _precioController.text = data['precio'].toString();
      _categoriaController.text = data['categoria'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Agregar Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _precioController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(labelText: 'Categoría'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                try {
                  String nombre = _nombreController.text;
                  String descripcion = _descripcionController.text;
                  String precio = _precioController.text;
                  String categoria = _categoriaController.text;
                  String nombreBusqueda = nombre.toLowerCase();

                  Map<String, dynamic> data = {
                    'nombre': nombre,
                    'descripcion': descripcion,
                    'precio': precio,
                    'categoria': categoria,
                    'nombreBusqueda': nombreBusqueda,
                  };

                  if (docId == null) {
                    await FirebaseFirestore.instance.collection('productos').add(data);
                  } else {
                    await FirebaseFirestore.instance.collection('productos').doc(docId).update(data);
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error al guardar producto: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar producto'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verProducto(Map<String, dynamic> producto) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(producto['nombre'] ?? 'Desconocido'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Descripción: ${producto['descripcion']}'),
                Text('Precio: ${producto['precio']}'),
                Text('Categoría: ${producto['categoria']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarProducto(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('productos').doc(docId).delete();
    } catch (e) {
      print('Error al eliminar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _productosStream = FirebaseFirestore.instance.collection('productos').snapshots();
                  } else {
                    _productosStream = _searchProducts(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _productosStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data?.docs[index];
                      var producto = doc?.data() as Map<String, dynamic>?;
                      if (producto != null) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: ListTile(
                            onTap: () => _verProducto(producto),
                            title: Text(producto['nombre'] ?? 'Desconocido'),
                            subtitle: Text('Precio: ${producto['precio']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _agregarEditarProducto(docId: doc?.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    if (doc?.id != null) _eliminarProducto(doc!.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text('Producto desconocido'),
                        );
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Ocurrió un error al cargar los productos'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarEditarProducto(),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
