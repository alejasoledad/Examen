import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProveedoresScreen extends StatefulWidget {
  @override
  _ProveedoresScreenState createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot> _proveedoresStream = FirebaseFirestore.instance.collection('proveedores').snapshots();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    setState(() {});
  }

  Stream<QuerySnapshot> _searchProveedores(String query) {
    if (query.trim().isEmpty) return _proveedoresStream;

    return FirebaseFirestore.instance
        .collection('proveedores')
        .where('nombre_lower',
            isGreaterThanOrEqualTo: query.toLowerCase(),
            isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
        .snapshots();
  }

  Future<void> _verProveedor(Map<String, dynamic> proveedor) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(proveedor['nombre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Correo: ${proveedor['correo']}'),
            Text('Dirección: ${proveedor['direccion']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editarProveedor(
      {String? docId,
      String? nombreInit,
      String? correoInit,
      String? direccionInit}) async {
    String nombre = nombreInit ?? '';
    String correo = correoInit ?? '';
    String direccion = direccionInit ?? '';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Agregar Proveedor' : 'Editar Proveedor'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                onChanged: (value) => nombre = value,
                decoration: InputDecoration(labelText: 'Nombre'),
                controller: TextEditingController(text: nombreInit),
              ),
              TextField(
                onChanged: (value) => correo = value,
                decoration: InputDecoration(labelText: 'Correo'),
                controller: TextEditingController(text: correoInit),
              ),
              TextField(
                onChanged: (value) => direccion = value,
                decoration: InputDecoration(labelText: 'Dirección'),
                controller: TextEditingController(text: direccionInit),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombre.isNotEmpty) {
                if (docId == null) {
                  FirebaseFirestore.instance.collection('proveedores').add({
                    'nombre': nombre,
                    'nombre_lower': nombre.toLowerCase(),
                    'correo': correo,
                    'direccion': direccion,
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('proveedores')
                      .doc(docId)
                      .update({
                    'nombre': nombre,
                    'nombre_lower': nombre.toLowerCase(),
                    'correo': correo,
                    'direccion': direccion,
                  });
                }
                Navigator.of(context).pop();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarProveedor(String docId) async {
    await FirebaseFirestore.instance
        .collection('proveedores')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proveedores'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                border: OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _searchProveedores(_searchController.text),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No se encontraron resultados'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data?.docs[index];
                      var proveedor = doc?.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(proveedor['nombre'] ?? 'Desconocido'),
                          subtitle: Text(
                              'Correo: ${proveedor['correo']}\nDirección: ${proveedor['direccion']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editarProveedor(
                                    docId: doc?.id,
                                    nombreInit: proveedor['nombre'],
                                    correoInit: proveedor['correo'],
                                    direccionInit: proveedor['direccion'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarProveedor(doc!.id),
                              ),
                            ],
                          ),
                          onTap: () => _verProveedor(proveedor),
                        ),
                      );
                    },
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los proveedores'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editarProveedor(),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
