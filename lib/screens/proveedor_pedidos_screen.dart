import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';

// Pedidos que le hacen los negocios al proveedor
class ProveedorPedidosScreen extends StatefulWidget {
  const ProveedorPedidosScreen({super.key});

  @override
  State<ProveedorPedidosScreen> createState() => _ProveedorPedidosScreenState();
}

class _ProveedorPedidosScreenState extends State<ProveedorPedidosScreen> {
  String filtro = 'nuevos';

  bool _coincide(String estado) {
    if (filtro == 'nuevos') return estado == 'nuevo';
    if (filtro == 'curso') return estado == 'aceptado' || estado == 'enviado';
    if (filtro == 'entregados') return estado == 'entregado';
    return estado == 'cancelado' || estado == 'rechazado';
  }

  Widget _chip(String valor, String texto) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: filtro == valor,
        selectedColor: kRojo,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: filtro == valor ? Colors.white : Colors.black),
        onSelected: (_) => setState(() => filtro = valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Pedido> lista = misPedidos().where((p) => _coincide(p.estado)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Pedidos')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _chip('nuevos', 'Nuevos'),
                _chip('curso', 'En curso'),
                _chip('entregados', 'Entregados'),
                _chip('otros', 'Cancelados'),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const EmptyState(
                    icono: Icons.receipt_long,
                    titulo: 'Sin pedidos aquí',
                    subtitulo:
                        'Los pedidos de tus negocios aparecerán en esta lista.')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: lista.length,
                    itemBuilder: (_, i) => PedidoTile(
                      pedido: lista[i],
                      esProveedor: true,
                      alVolver: () => setState(() {}),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
