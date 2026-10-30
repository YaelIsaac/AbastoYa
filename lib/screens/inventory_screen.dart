import 'package:flutter/material.dart';

import '../datos.dart';
import '../navegacion.dart';
import '../theme.dart';
import 'detail_screen.dart';

// Lista de productos del inventario del negocio
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String categoriaFiltro = 'Todos';
  String busqueda = '';

  @override
  Widget build(BuildContext context) {
    List<String> categorias = ['Todos', ...categoriasDeInventario()];
    if (!categorias.contains(categoriaFiltro)) categoriaFiltro = 'Todos';

    List<Producto> filtrados = misProductos().where((p) {
      bool okCategoria =
          categoriaFiltro == 'Todos' || p.categoria == categoriaFiltro;
      bool okBusqueda = p.nombre.toLowerCase().contains(busqueda.toLowerCase());
      return okCategoria && okBusqueda;
    }).toList();
    filtrados.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Inventario')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: irANuevoProducto,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (texto) => setState(() => busqueda = texto),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categorias.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: categoriaFiltro == cat,
                    selectedColor: kRojo,
                    labelStyle: TextStyle(
                        color: categoriaFiltro == cat
                            ? Colors.white
                            : Colors.black),
                    checkmarkColor: Colors.white,
                    onSelected: (_) => setState(() => categoriaFiltro = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: misProductos().isEmpty
                ? EmptyState(
                    icono: Icons.inventory_2_outlined,
                    titulo: 'Tu inventario está vacío',
                    subtitulo: 'Agrega tu primer producto para empezar.',
                    textoBoton: 'Registrar producto',
                    onPressed: irANuevoProducto,
                  )
                : filtrados.isEmpty
                    ? const EmptyState(
                        icono: Icons.search_off,
                        titulo: 'Sin resultados',
                        subtitulo: 'Prueba con otro nombre o categoría.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          Producto p = filtrados[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red[50],
                                child: Icon(iconoCategoria(p.categoria),
                                    color: kRojo),
                              ),
                              title: Text(p.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${fmtNum(p.cantidad)} ${p.unidad} • ${p.categoria}'),
                              trailing: EstadoChip(p.estado),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            DetailScreen(producto: p)));
                                setState(() {});
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
}
