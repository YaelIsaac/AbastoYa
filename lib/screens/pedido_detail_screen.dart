import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';

// Detalle de un pedido. Lo ven el proveedor y el negocio.
class PedidoDetailScreen extends StatefulWidget {
  final Pedido pedido;
  final bool esProveedor;
  const PedidoDetailScreen(
      {super.key, required this.pedido, required this.esProveedor});

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  // Ventana de confirmación; devuelve true si el usuario acepta
  Future<bool> _confirmar(String titulo, String texto, String si) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(si, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    return ok == true;
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Pedido p = widget.pedido;
    bool esProveedor = widget.esProveedor;
    String? siguiente = p.siguienteEstado;
    Usuario? proveedor = buscarUsuario(p.proveedor);
    Usuario? negocio = buscarUsuario(p.negocio);

    bool puedeRechazar = esProveedor && p.estado == 'nuevo';
    bool puedeCancelar = !esProveedor && p.estado == 'nuevo';
    bool puedeRecibir =
        !esProveedor && p.estado == 'entregado' && !p.inventarioActualizado;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${p.numero}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EstadoPedidoChip(p.estado),
                const SizedBox(width: 8),
                Text(fmtFecha(p.fecha), style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // Productos y total
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Productos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...p.items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(children: [
                            Expanded(
                                child: Text(
                                    '${fmtNum(i.cantidad)} ${i.unidad} × ${i.nombre}')),
                            Text(fmtPrecio(i.subtotal)),
                          ]),
                        )),
                    const Divider(),
                    Row(children: [
                      const Expanded(
                          child: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Text(fmtPrecio(p.total),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                  ],
                ),
              ),
            ),

            // Datos de la otra parte
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(esProveedor ? 'Cliente' : 'Proveedor',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _fila(Icons.business,
                        nombreDe(esProveedor ? p.negocio : p.proveedor)),
                    if (esProveedor && negocio != null && negocio.telefono.isNotEmpty)
                      _fila(Icons.phone, negocio.telefono),
                    if (!esProveedor && proveedor != null && proveedor.telefono.isNotEmpty)
                      _fila(Icons.phone, proveedor.telefono),
                    if (p.direccion.isNotEmpty) _fila(Icons.home, p.direccion),
                    if (p.fechaDeseada.isNotEmpty)
                      _fila(Icons.event, 'Para: ${p.fechaDeseada}'),
                    if (p.notas.isNotEmpty) _fila(Icons.notes, p.notas),
                  ],
                ),
              ),
            ),

            // El negocio ve los datos para pagar
            if (!esProveedor && p.activo && proveedor != null)
              CuentaPagoCard(proveedor: proveedor),
            const SizedBox(height: 8),

            // ---- Botones ----
            if (esProveedor && siguiente != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(siguiente == 'aceptado'
                      ? 'Aceptar pedido'
                      : 'Marcar como: ${etiquetaEstado(siguiente)}'),
                  onPressed: () => setState(() => p.estado = siguiente),
                ),
              ),
            if (puedeRecibir)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Recibí el pedido: sumar al inventario'),
                  onPressed: () async {
                    bool ok = await _confirmar(
                        'Sumar al inventario',
                        'Se agregarán estas cantidades a tu inventario '
                            '(y se crearán los productos que no existan).',
                        'Sí, sumar');
                    if (ok) {
                      recibirPedido(p);
                      setState(() {});
                    }
                  },
                ),
              ),
            if (!esProveedor && p.inventarioActualizado)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text('Ya sumado a tu inventario'),
                ]),
              ),
            if (puedeRechazar)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Rechazar pedido',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    if (await _confirmar('Rechazar pedido',
                        '¿Rechazar el pedido #${p.numero}?', 'Sí, rechazar')) {
                      setState(() => p.estado = 'rechazado');
                    }
                  },
                ),
              ),
            if (puedeCancelar)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Cancelar pedido',
                      style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    if (await _confirmar('Cancelar pedido',
                        '¿Cancelar el pedido #${p.numero}?', 'Sí, cancelar')) {
                      setState(() => p.estado = 'cancelado');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
