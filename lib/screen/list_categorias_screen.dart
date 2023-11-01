import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListCategoriasScreen extends StatefulWidget {
  @override
  _ListCategoriasScreenState createState() => _ListCategoriasScreenState();
}

class _ListCategoriasScreenState extends State<ListCategoriasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  Stream<QuerySnapshot>? _categoriasStream;
  String? _selectedCategoriaId;

  @override
  void initState() {
    super.initState();
    _updateCategoriasStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  void _updateCategoriasStream({String? query}) {
    if (query != null && query.isNotEmpty) {
      _categoriasStream = FirebaseFirestore.instance
          .collection('categorias')
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThan: query + '\uf8ff')
          .snapshots();
    } else {
      _categoriasStream = FirebaseFirestore.instance.collection('categorias').snapshots();
    }
  }

  Stream<QuerySnapshot> _getProductos(String categoriaId) {
    return FirebaseFirestore.instance
        .collection('productos')
        .where('categoriaId', isEqualTo: categoriaId)
        .snapshots();
  }

  Future<void> _showEditCategoryDialog({String? docId, String? nombreCategoria}) async {
    _categoriaController.text = nombreCategoria ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Agregar Categoría' : 'Editar Categoría'),
          content: TextField(
            controller: _categoriaController,
            decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (_categoriaController.text.trim().isEmpty) {
                  // Mostrar un error o hacer algo si el campo está vacío
                  return;
                }
                
                if (docId == null) {
                  await FirebaseFirestore.instance.collection('categorias').add({
                    'nombre': _categoriaController.text.trim(),
                  });
                } else {
                  await FirebaseFirestore.instance.collection('categorias').doc(docId).update({
                    'nombre': _categoriaController.text.trim(),
                  });
                }
                Navigator.of(context).pop();
                _categoriaController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarCategoria(String docId) async {
    await FirebaseFirestore.instance.collection('categorias').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar categoría',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _updateCategoriasStream();
                  },
                ),
              ),
              onChanged: (value) {
                _updateCategoriasStream(query: value);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _categoriasStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Ocurrió un error al cargar las categorías'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No se encontraron categorías'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      Map<String, dynamic> categoria = doc.data() as Map<String, dynamic>;
                      String docId = doc.id;

                      return Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(categoria['nombre']),
                          trailing: Wrap(
                            spacing: 12, // Espacio entre botones
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _showEditCategoryDialog(docId: docId, nombreCategoria: categoria['nombre']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarCategoria(docId),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCategoriaId = docId;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedCategoriaId != null)
              Expanded(
                child: StreamBuilder(
                  stream: _getProductos(_selectedCategoriaId!),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Ocurrió un error al cargar los productos'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No se encontraron productos'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        Map<String, dynamic> producto = doc.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(producto['nombre']),
                          subtitle: Text('Precio: \$${producto['precio']}'),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () => _showEditCategoryDialog(),
      ),
    );
  }
}
