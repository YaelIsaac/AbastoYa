import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// Reportes del negocio: movimientos de inventario y compras
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int dias = 30; // 0 = todo el tiempo

  @override
  Widget build(BuildContext context) {
    DateTime? desde =
        dias == 0 ? null : DateTime.now().subtract(Duration(days: dias));

    // Movimientos del periodo (el stock inicial no cuenta como compra ni consumo)
    List<Movimiento> movs = misMovimientos()
        .where((m) => !m.inicial && (desde == null || m.fecha.isAfter(desde)))
        .toList();
    int entradas = movs.where((m) => m.esEntrada).length;
    int salidas = movs.where((m) => !m.esEntrada).length;

    // Compras: pedidos entregados en el periodo
    List<Pedido> entregados = misPedidos()
        .where((p) =>
            p.estado == 'entregado' && (desde == null || p.fecha.isAfter(desde)))
        .toList();
    double compras = 0;
    for (var p in entregados) {
      compras += p.total;
    }

    // Consumo por producto (suma de las salidas)
    Map<String, double> consumo = {};
    Map<String, String> unidades = {};
    for (var m in movs.where((m) => !m.esEntrada)) {
      consumo[m.productoNombre] = (consumo[m.productoNombre] ?? 0) + m.cantidad;
      unidades[m.productoNombre] = m.unidad;
    }
    List<MapEntry<String, double>> top = consumo.entries.toList();
    top.sort((a, b) => b.value.compareTo(a.value));
    double maximo = top.isEmpty ? 1 : top.first.value;

    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Reportes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                _tarjeta('$entradas', 'Total entradas', Colors.green[50]!,
                    Colors.green),
                const SizedBox(width: 10),
                _tarjeta('$salidas', 'Total salidas', Colors.red[50]!, Colors.red),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _tarjeta(fmtPrecio(compras), 'Compras a proveedores',
                    Colors.amber[50]!, Colors.orange),
                const SizedBox(width: 10),
                _tarjeta('${entregados.length}', 'Pedidos recibidos',
                    Colors.blue[50]!, Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Productos más consumidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (top.isEmpty)
              const Text('Aún no hay salidas en este periodo.',
                  style: TextStyle(color: Colors.grey)),
            ...top.take(5).map((e) => _barra(e.key, e.value / maximo,
                '${fmtNum(e.value)} ${unidades[e.key] ?? ''}')),
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
            const SizedBox(height: 5),
            Text(texto,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _barra(String nombre, double progreso, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
              value: progreso.clamp(0.0, 1.0),
              color: kRojo,
              backgroundColor: Colors.grey[200]),
        ],
      ),
    );
  }
}
