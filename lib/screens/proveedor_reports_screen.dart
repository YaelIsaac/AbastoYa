import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// Reportes del proveedor: ventas, clientes y productos más vendidos
class ProveedorReportsScreen extends StatefulWidget {
  const ProveedorReportsScreen({super.key});

  @override
  State<ProveedorReportsScreen> createState() => _ProveedorReportsScreenState();
}

class _ProveedorReportsScreenState extends State<ProveedorReportsScreen> {
  int dias = 30; // 0 = todo el tiempo

  @override
  Widget build(BuildContext context) {
    DateTime? desde =
        dias == 0 ? null : DateTime.now().subtract(Duration(days: dias));

    // Pedidos entregados en el periodo
    List<Pedido> entregados = misPedidos()
        .where((p) =>
            p.estado == 'entregado' && (desde == null || p.fecha.isAfter(desde)))
        .toList();
    double ventas = 0;
    for (var p in entregados) {
      ventas += p.total;
    }
    double cobrado = 0;
    for (var a in abonos) {
      if (a.proveedor == usuarioActual!.correo &&
          (desde == null || a.fecha.isAfter(desde))) {
        cobrado += a.monto;
      }
    }

    // Ventas por cliente
    Map<String, double> porCliente = {};
    for (var p in entregados) {
      porCliente[nombreDe(p.negocio)] =
          (porCliente[nombreDe(p.negocio)] ?? 0) + p.total;
    }
    List<MapEntry<String, double>> topClientes = porCliente.entries.toList();
    topClientes.sort((a, b) => b.value.compareTo(a.value));

    // Productos más vendidos
    Map<String, double> porProducto = {};
    Map<String, String> unidades = {};
    for (var p in entregados) {
      for (var i in p.items) {
        porProducto[i.nombre] = (porProducto[i.nombre] ?? 0) + i.cantidad;
        unidades[i.nombre] = i.unidad;
      }
    }
    List<MapEntry<String, double>> topProductos = porProducto.entries.toList();
    topProductos.sort((a, b) => b.value.compareTo(a.value));

    // Clientes activos que llevan más de 30 días sin pedir
    DateTime limite = DateTime.now().subtract(const Duration(days: 30));
    List<Vinculo> inactivos = vinculosDelProveedor().where((v) {
      if (v.estado != 'activo') return false;
      List<Pedido> suyos = pedidosCon(v.negocio)
          .where((p) => p.estado != 'cancelado' && p.estado != 'rechazado')
          .toList();
      if (suyos.isEmpty) return true;
      return suyos.every((p) => p.fecha.isBefore(limite));
    }).toList();

    double porCobrar = saldoTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                _chipPeriodo(7, '7 días'),
                _chipPeriodo(30, '30 días'),
                _chipPeriodo(0, 'Todo'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _tarjeta(fmtPrecio(ventas), 'Ventas entregadas', Colors.green[50]!,
                    Colors.green),
                const SizedBox(width: 10),
                _tarjeta('${entregados.length}', 'Pedidos entregados',
                    Colors.blue[50]!, Colors.blue),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _tarjeta(fmtPrecio(cobrado), 'Cobrado (abonos)', Colors.amber[50]!,
                    Colors.orange),
                const SizedBox(width: 10),
                _tarjeta(fmtPrecio(porCobrar > 0 ? porCobrar : 0),
                    'Por cobrar (total)', Colors.red[50]!, kRojo),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Ventas por cliente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (topClientes.isEmpty)
              const Text('Aún no hay ventas en este periodo.',
                  style: TextStyle(color: Colors.grey)),
            ...topClientes.take(6).map((e) => _barra(
                e.key, e.value / topClientes.first.value, fmtPrecio(e.value))),
            const SizedBox(height: 20),
            const Text('Productos más vendidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (topProductos.isEmpty)
              const Text('Aún no hay productos vendidos.',
                  style: TextStyle(color: Colors.grey)),
            ...topProductos.take(6).map((e) => _barra(
                e.key,
                e.value / topProductos.first.value,
                '${fmtNum(e.value)} ${unidades[e.key] ?? ''}')),
            const SizedBox(height: 20),
            const Text('Clientes sin pedir en 30 días',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (inactivos.isEmpty)
              const Text('Todos tus clientes activos han pedido recientemente.',
                  style: TextStyle(color: Colors.grey)),
            ...inactivos.map((v) => Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.schedule, color: Colors.orange),
                    title: Text(nombreDe(v.negocio)),
                    subtitle: Text(v.negocio),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _chipPeriodo(int valor, String texto) {
    return ChoiceChip(
      label: Text(texto),
      selected: dias == valor,
      selectedColor: kRojo,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: dias == valor ? Colors.white : Colors.black),
      onSelected: (_) => setState(() => dias = valor),
    );
  }

  Widget _tarjeta(String valor, String texto, Color fondo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(texto,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _barra(String nombre, double progreso, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(nombre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
              value: progreso.clamp(0.0, 1.0),
              color: kRojo,
              backgroundColor: Colors.grey[200]),
        ],
      ),
    );
  }
}
