import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/movimiento_dialog.dart';
import '../widgets/producto_form.dart';
import 'nuevo_pedido_screen.dart';

// Detalle de un producto del inventario
class DetailScreen extends StatefulWidget {
  final Producto producto;
  const DetailScreen({super.key, required this.producto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<void> _eliminar() async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${widget.producto.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      eliminarProducto(widget.producto);
      Navigator.pop(context);
    }
  }

  Future<void> _editar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Editar producto')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ProductoForm(
              producto: widget.producto,
              alGuardar: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _movimiento(bool entrada) async {
    await mostrarMovimiento(context, widget.producto, entrada);
    setState(() {});
  }

  Future<void> _pedir(Vinculo v) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => NuevoPedidoScreen(vinculo: v)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Producto p = widget.producto;
    List<Movimiento> historial =
        misMovimientos().where((m) => m.productoNombre == p.nombre).take(10).toList();
    Vinculo? vinculo =
        p.proveedor.isEmpty ? null : buscarVinculo(p.proveedor, p.dueno);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nombre),
        actions: [
          IconButton(
              tooltip: 'Editar', icon: const Icon(Icons.edit), onPressed: _editar),
          IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete),
              onPressed: _eliminar),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red[50],
                  child: Icon(iconoCategoria(p.categoria), color: kRojo, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nombre,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      EstadoChip(p.estado),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Categoría: ${p.categoria}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Cantidad actual: ${fmtNum(p.cantidad)} ${p.unidad}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Stock mínimo requerido: ${fmtNum(p.stockMinimo)} ${p.unidad}',
                style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
            if (p.proveedor.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Proveedor: ${nombreDe(p.proveedor)}',
                  style: const TextStyle(fontSize: 16)),
            ],
            if (p.descripcion.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Descripción:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(p.descripcion, style: const TextStyle(fontSize: 15)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Entrada',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => _movimiento(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kRojo,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.remove, color: Colors.white),
                    label: const Text('Salida',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => _movimiento(false),
                  ),
                ),
              ],
            ),
            if (vinculo != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.local_shipping),
                  label: Text('Pedir a ${nombreDe(p.proveedor)}'),
                  onPressed: vinculo.estado == 'activo' ? () => _pedir(vinculo) : null,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Movimientos recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (historial.isEmpty)
              const Text('Todavía no hay movimientos.',
                  style: TextStyle(color: Colors.grey)),
            ...historial.map((m) => Card(
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                        m.esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                        color: m.esEntrada ? Colors.green : Colors.red),
                    title: Text(
                        '${m.esEntrada ? '+' : '-'}${fmtNum(m.cantidad)} ${m.unidad}'
                        '${m.nota.isEmpty ? '' : ' • ${m.nota}'}'),
                    subtitle: Text(fmtFecha(m.fecha)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
