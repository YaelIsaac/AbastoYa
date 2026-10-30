import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';
import 'agregar_proveedor_screen.dart';
import 'proveedor_negocio_detail_screen.dart';

// Pestaña "Proveedores" del negocio: mis proveedores y mis pedidos
class NegocioProveedoresScreen extends StatefulWidget {
  const NegocioProveedoresScreen({super.key});

  @override
  State<NegocioProveedoresScreen> createState() =>
      _NegocioProveedoresScreenState();
}

class _NegocioProveedoresScreenState extends State<NegocioProveedoresScreen> {
  bool enCurso = true; // filtro de pedidos

  Future<void> _agregar() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AgregarProveedorScreen()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AbastoYa - Proveedores'),
          actions: [
            IconButton(
                tooltip: 'Agregar proveedor',
                icon: const Icon(Icons.person_add),
                onPressed: _agregar),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Mis proveedores'), Tab(text: 'Mis pedidos')],
          ),
        ),
        body: TabBarView(
          children: [_listaProveedores(), _listaPedidos()],
        ),
      ),
    );
  }

  Widget _listaProveedores() {
    List<Vinculo> lista = vinculosDelNegocio();
    if (lista.isEmpty) {
      return EmptyState(
        icono: Icons.local_shipping_outlined,
        titulo: 'Aún no tienes proveedores',
        subtitulo:
            'Agrega uno con su código, o espera a que un proveedor te registre con tu correo.',
        textoBoton: 'Agregar proveedor',
        onPressed: _agregar,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 20),
      itemCount: lista.length,
      itemBuilder: (context, i) {
        Vinculo v = lista[i];
        bool activo = v.estado == 'activo';
        double saldo = saldoCon(v.proveedor);
        String subtitulo;
        if (!activo) {
          subtitulo = v.estado == 'pendiente'
              ? 'Esperando aprobación del proveedor'
              : etiquetaEstado(v.estado);
        } else if (saldo.abs() < 0.005) {
          subtitulo = 'Sin saldo pendiente';
        } else if (saldo > 0) {
          subtitulo = 'Por pagar: ${fmtPrecio(saldo)}';
        } else {
          subtitulo = 'Saldo a favor: ${fmtPrecio(-saldo)}';
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: activo ? Colors.red[50] : Colors.grey[200],
              child: Icon(Icons.local_shipping,
                  color: activo ? kRojo : Colors.grey),
            ),
            title: Text(nombreDe(v.proveedor),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitulo),
            trailing: v.estado == 'pendiente'
                ? TextButton(
                    onPressed: () {
                      vinculos.remove(v); // cancela la solicitud
                      setState(() {});
                    },
                    child: const Text('Cancelar'))
                : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: activo
                ? () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProveedorNegocioDetailScreen(vinculo: v)));
                    setState(() {});
                  }
                : null,
          ),
        );
      },
    );
  }

  Widget _listaPedidos() {
    List<Pedido> lista = misPedidos().where((p) => p.activo == enCurso).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('En curso'),
                selected: enCurso,
                selectedColor: kRojo,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(color: enCurso ? Colors.white : Colors.black),
                onSelected: (_) => setState(() => enCurso = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Historial'),
                selected: !enCurso,
                selectedColor: kRojo,
                checkmarkColor: Colors.white,
                labelStyle:
                    TextStyle(color: !enCurso ? Colors.white : Colors.black),
                onSelected: (_) => setState(() => enCurso = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? const EmptyState(
                  icono: Icons.receipt_long,
                  titulo: 'Sin pedidos aquí',
                  subtitulo: 'Entra a un proveedor y pulsa "Hacer pedido".')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: lista.length,
                  itemBuilder: (_, i) => PedidoTile(
                    pedido: lista[i],
                    esProveedor: false,
                    alVolver: () => setState(() {}),
                  ),
                ),
        ),
      ],
    );
  }
}
