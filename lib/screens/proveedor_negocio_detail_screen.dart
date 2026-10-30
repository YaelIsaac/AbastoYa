import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';
import 'nuevo_pedido_screen.dart';

// Un proveedor visto por el negocio: pedir, saldo, pagos y pedidos
class ProveedorNegocioDetailScreen extends StatefulWidget {
  final Vinculo vinculo;
  const ProveedorNegocioDetailScreen({super.key, required this.vinculo});

  @override
  State<ProveedorNegocioDetailScreen> createState() =>
      _ProveedorNegocioDetailScreenState();
}

class _ProveedorNegocioDetailScreenState
    extends State<ProveedorNegocioDetailScreen> {
  Future<void> _hacerPedido() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NuevoPedidoScreen(vinculo: widget.vinculo)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Vinculo v = widget.vinculo;
    Usuario? prov = buscarUsuario(v.proveedor);
    List<Pedido> susPedidos = pedidosCon(v.proveedor);
    List<Abono> susAbonos = abonosCon(v.proveedor);

    return Scaffold(
      appBar: AppBar(title: Text(nombreDe(v.proveedor))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kRojo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Hacer pedido', style: TextStyle(fontSize: 16)),
                onPressed: v.estado == 'activo' ? _hacerPedido : null,
              ),
            ),
            const SizedBox(height: 16),
            SaldoCard(saldo: saldoCon(v.proveedor), textoDeuda: 'Por pagar'),
            const SizedBox(height: 8),
            if (prov != null) CuentaPagoCard(proveedor: prov),
            const SizedBox(height: 8),
            const Text('Pagos registrados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (susAbonos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('El proveedor aún no registra pagos.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...susAbonos.map((a) => Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.payments, color: Colors.green),
                    title: Text(fmtPrecio(a.monto)),
                    subtitle: Text(
                        '${fmtFecha(a.fecha)}${a.nota.isEmpty ? '' : ' • ${a.nota}'}'),
                  ),
                )),
            const SizedBox(height: 16),
            const Text('Pedidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (susPedidos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Todavía no le has hecho pedidos.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...susPedidos.map((p) => PedidoTile(
                  pedido: p,
                  esProveedor: false,
                  alVolver: () => setState(() {}),
                )),
          ],
        ),
      ),
    );
  }
}
