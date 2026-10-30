import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos.dart';
import '../screens/pedido_detail_screen.dart';
import '../theme.dart';

// Etiqueta de color con el estado de un pedido
class EstadoPedidoChip extends StatelessWidget {
  final String estado;
  const EstadoPedidoChip(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(etiquetaEstado(estado),
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: colorEstado(estado),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}

// Una fila de la lista de pedidos
class PedidoTile extends StatelessWidget {
  final Pedido pedido;
  final bool esProveedor;
  final VoidCallback alVolver; // se llama al regresar del detalle

  const PedidoTile({
    super.key,
    required this.pedido,
    required this.esProveedor,
    required this.alVolver,
  });

  @override
  Widget build(BuildContext context) {
    // si soy proveedor veo al negocio; si soy negocio veo al proveedor
    String otro = nombreDe(esProveedor ? pedido.negocio : pedido.proveedor);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[50],
          child: const Icon(Icons.local_shipping, color: kRojo),
        ),
        title: Text('#${pedido.numero} • $otro',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${fmtFecha(pedido.fecha)}\n${pedido.items.length} producto(s) • ${fmtPrecio(pedido.total)}'),
        isThreeLine: true,
        trailing: EstadoPedidoChip(pedido.estado),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    PedidoDetailScreen(pedido: pedido, esProveedor: esProveedor)),
          );
          alVolver();
        },
      ),
    );
  }
}

// Tarjeta con el saldo (lo que se debe)
class SaldoCard extends StatelessWidget {
  final double saldo;
  final String textoDeuda; // "Por pagar" o "Te debe"

  const SaldoCard({super.key, required this.saldo, required this.textoDeuda});

  @override
  Widget build(BuildContext context) {
    bool enCero = saldo.abs() < 0.005;
    bool aFavor = saldo < 0;
    Color color = enCero ? Colors.green : (aFavor ? Colors.blue : Colors.orange);
    String titulo = enCero
        ? 'Sin saldo pendiente'
        : (aFavor ? 'Saldo a favor' : textoDeuda);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(fmtPrecio(saldo.abs()),
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// Datos de la cuenta del proveedor para transferencias (solo texto)
class CuentaPagoCard extends StatelessWidget {
  final Usuario proveedor;
  const CuentaPagoCard({super.key, required this.proveedor});

  @override
  Widget build(BuildContext context) {
    if (proveedor.cuenta.trim().isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Sin cuenta para transferencias'),
          subtitle: Text('El proveedor aún no registra sus datos de pago.'),
        ),
      );
    }
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Datos para transferencia',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (proveedor.titular.isNotEmpty) Text('Titular: ${proveedor.titular}'),
            if (proveedor.banco.isNotEmpty) Text('Banco: ${proveedor.banco}'),
            Row(
              children: [
                Expanded(
                  child: Text('Cuenta: ${proveedor.cuenta}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  tooltip: 'Copiar',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: proveedor.cuenta));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cuenta copiada')));
                  },
                ),
              ],
            ),
            if (proveedor.instrucciones.isNotEmpty)
              Text(proveedor.instrucciones,
                  style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
