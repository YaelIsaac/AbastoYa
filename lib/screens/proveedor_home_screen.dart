import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos.dart';
import '../navegacion.dart';
import '../theme.dart';
import '../widgets/pedido_widgets.dart';

// Inicio del PROVEEDOR: resumen y pedidos por atender
class ProveedorHomeScreen extends StatefulWidget {
  const ProveedorHomeScreen({super.key});

  @override
  State<ProveedorHomeScreen> createState() => _ProveedorHomeScreenState();
}

class _ProveedorHomeScreenState extends State<ProveedorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    Usuario yo = usuarioActual!;
    List<Pedido> nuevos = misPedidos().where((p) => p.estado == 'nuevo').toList();
    int enCurso = misPedidos()
        .where((p) => p.estado == 'aceptado' || p.estado == 'enviado')
        .length;
    List<Vinculo> clientes = vinculosDelProveedor();
    int activos = clientes.where((v) => v.estado == 'activo').length;
    int pendientes = clientes.where((v) => v.estado == 'pendiente').length;
    double porCobrar = saldoTotal();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: kRojo,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.amber, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(yo.titulo,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                            if (yo.verificado)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified,
                                    color: Colors.lightBlueAccent, size: 20),
                              ),
                          ],
                        ),
                        const Text('Panel de proveedor',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tarjeta('${nuevos.length}', 'Pedidos nuevos',
                          Colors.blue[50]!, Colors.blue),
                      const SizedBox(width: 10),
                      _tarjeta('$enCurso', 'En curso', Colors.amber[50]!,
                          Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _tarjeta('$activos', 'Clientes activos', Colors.green[50]!,
                          Colors.green),
                      const SizedBox(width: 10),
                      _tarjeta(fmtPrecio(porCobrar > 0 ? porCobrar : 0),
                          'Por cobrar', Colors.red[50]!, kRojo),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (pendientes > 0)
                    Card(
                      color: Colors.amber[50],
                      child: ListTile(
                        leading:
                            const Icon(Icons.person_add, color: Colors.orange),
                        title: Text('$pendientes solicitud(es) de clientes'),
                        subtitle: const Text('Toca para revisarlas'),
                        onTap: () => provTab.value = 2,
                      ),
                    ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.qr_code, color: kRojo),
                      title: const Text('Tu código de proveedor'),
                      subtitle:
                          const Text('Dáselo a tus negocios para que te agreguen'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(yo.codigo,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: yo.codigo));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Código copiado')));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pedidos por atender',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (nuevos.isEmpty)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Todo al día'),
                        subtitle: Text('No hay pedidos nuevos.'),
                      ),
                    ),
                ],
              ),
            ),
            ...nuevos.take(5).map((p) => PedidoTile(
                  pedido: p,
                  esProveedor: true,
                  alVolver: () => setState(() {}),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(texto,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
