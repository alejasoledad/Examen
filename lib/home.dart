import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MENU PRINCIPAL'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildModuleCard(
              context,
              'Módulo de Proveedores',
              Icons.business_center,
              'list_proveedores',
              Colors.lightBlue,
            ),
            _buildModuleCard(
              context,
              'Módulo de Categorías',
              Icons.label,
              'list_categorias',
              Colors.green,
            ),
            _buildModuleCard(
              context,
              'Módulo de Productos',
              Icons.shopping_cart,
              'list_productos',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
      BuildContext context, String title, IconData icon, String routeName, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 30,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
