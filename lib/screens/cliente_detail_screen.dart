import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';

// Un cliente visto por el proveedor: datos, estado de cuenta y pedidos
class ClienteDetailScreen extends StatefulWidget {
  final Vinculo vinculo;
  const ClienteDetailScreen({super.key, required this.vinculo});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  final _notas = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notas.text = widget.vinculo.notas;
  }

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
  }

  // Ventana para registrar un abono (pago del cliente)
  Future<void> _abonar(double saldo) async {
    final monto = TextEditingController();
    final nota = TextEditingController();
    bool? guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar abono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: monto,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Monto recibido', prefixText: '\$ '),
            ),
            if (saldo > 0.005)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () => monto.text = fmtNum(saldo),
                    child: Text('Liquidar todo (${fmtPrecio(saldo)})')),
              ),
            TextField(
              controller: nota,
              decoration: const InputDecoration(
                  labelText: 'Nota (opcional)', hintText: 'Ej. Transferencia'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (guardar == true && mounted) {
      String? error =
          registrarAbono(widget.vinculo.negocio, parseNum(monto.text) ?? 0, nota.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error ?? 'Abono registrado')));
      setState(() {});
    }
    monto.dispose();
    nota.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Vinculo v = widget.vinculo;
    Usuario? n = buscarUsuario(v.negocio);
    double saldo = saldoCon(v.negocio);
    List<Abono> susAbonos = abonosCon(v.negocio);
    List<Pedido> susPedidos = pedidosCon(v.negocio);

    return Scaffold(
      appBar: AppBar(title: Text(nombreDe(v.negocio))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(etiquetaEstado(v.estado),
                          style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: colorEstado(v.estado),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                    if (n != null && n.nombre.isNotEmpty)
                      Text('Contacto: ${n.nombre}'),
                    Text('Correo: ${v.negocio}'),
                    if (n != null && n.telefono.isNotEmpty)
                      Text('Teléfono: ${n.telefono}'),
                    if (n != null && n.direccion.isNotEmpty)
                      Text('Dirección: ${n.direccion}'),
                    const SizedBox(height: 8),
                    if (v.estado == 'activo')
                      OutlinedButton.icon(
                        icon: const Icon(Icons.block, color: Colors.red),
                        label: const Text('Desactivar cliente'),
                        onPressed: () => setState(() => v.estado = 'inactivo'),
                      ),
                    if (v.estado == 'inactivo')
                      OutlinedButton.icon(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        label: const Text('Reactivar cliente'),
                        onPressed: () => setState(() => v.estado = 'activo'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notas,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notas privadas',
                suffixIcon: IconButton(
                  tooltip: 'Guardar notas',
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    v.notas = _notas.text.trim();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notas guardadas')));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            SaldoCard(saldo: saldo, textoDeuda: 'Te debe'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: const Icon(Icons.payments),
                label: const Text('Registrar abono'),
                onPressed: () => _abonar(saldo),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Abonos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (susAbonos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child:
                    Text('Sin abonos todavía.', style: TextStyle(color: Colors.grey)),
              ),
            ...susAbonos.map((a) => Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.payments, color: Colors.green),
                    title: Text(fmtPrecio(a.monto)),
                    subtitle: Text(
                        '${fmtFecha(a.fecha)}${a.nota.isEmpty ? '' : ' • ${a.nota}'}'),
                    trailing: IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        abonos.remove(a);
                        setState(() {});
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            const Text('Pedidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (susPedidos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Aún no te ha hecho pedidos.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ...susPedidos.map((p) => PedidoTile(
                  pedido: p,
                  esProveedor: true,
                  alVolver: () => setState(() {}),
                )),
          ],
        ),
      ),
    );
  }
}
