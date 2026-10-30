import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// El negocio agrega un proveedor: con su código o buscándolo en la lista
class AgregarProveedorScreen extends StatefulWidget {
  const AgregarProveedorScreen({super.key});

  @override
  State<AgregarProveedorScreen> createState() => _AgregarProveedorScreenState();
}

class _AgregarProveedorScreenState extends State<AgregarProveedorScreen> {
  final _codigo = TextEditingController();
  String busqueda = '';

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _porCodigo() {
    String? error = solicitarPorCodigo(_codigo.text);
    if (error != null) {
      _aviso(error);
      return;
    }
    _aviso('Solicitud enviada. El proveedor debe aprobarla.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // proveedores activos que coinciden con la búsqueda
    List<Usuario> lista = usuarios.where((u) {
      if (u.rol != 'proveedor' || !u.activo) return false;
      String q = busqueda.toLowerCase();
      return u.titulo.toLowerCase().contains(q) || u.giro.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar proveedor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('¿Tu proveedor te dio un código?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codigo,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(hintText: 'Ej. PROV01'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kRojo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16)),
                          onPressed: _porCodigo,
                          child: const Text('Solicitar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (texto) => setState(() => busqueda = texto),
              decoration: InputDecoration(
                hintText: 'O busca un proveedor por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lista.isEmpty
                ? const EmptyState(
                    icono: Icons.search_off,
                    titulo: 'Sin resultados',
                    subtitulo: 'Aún no hay proveedores con esa búsqueda.')
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      Usuario prov = lista[i];
                      Vinculo? v =
                          buscarVinculo(prov.correo, usuarioActual!.correo);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.red[50],
                              child:
                                  const Icon(Icons.local_shipping, color: kRojo)),
                          title: Row(
                            children: [
                              Flexible(
                                  child: Text(prov.titulo,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              if (prov.verificado)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.verified,
                                      size: 16, color: Colors.blue),
                                ),
                            ],
                          ),
                          subtitle:
                              Text(prov.giro.isEmpty ? 'Sin descripción' : prov.giro),
                          trailing: v != null
                              ? Text(etiquetaEstado(v.estado),
                                  style: const TextStyle(color: Colors.grey))
                              : TextButton(
                                  onPressed: () {
                                    String? error = solicitarProveedor(prov);
                                    _aviso(error ??
                                        'Solicitud enviada a ${prov.titulo}.');
                                    setState(() {});
                                  },
                                  child: const Text('Solicitar')),
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
