import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'detail_screen.dart';
import 'notifications_screen.dart';
import '../navegacion.dart';

// Pantalla de inicio del NEGOCIO: resumen y alertas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Usuario yo = usuarioActual!;
    List<Producto> bajos = productosBajos();
    int pedidosEnCurso = misPedidos().where((p) => p.activo).length;
    double porPagar = saldoTotal();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera roja
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: kRojo,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.storefront, color: Colors.amber, size: 36),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AbastoYa',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      Text('Negocios y proveedores conectados',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola, ${yo.nombre.split(' ').first}!',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Resumen del inventario de ${yo.titulo}.',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),

                  // Tarjetas resumen
                  Row(
                    children: [
                      _tarjeta('${misProductos().length}', 'Productos registrados',
                          Colors.green[50]!, Colors.green),
                      const SizedBox(width: 10),
                      _tarjeta('${bajos.length}', 'En stock mínimo',
                          Colors.amber[50]!, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _tarjeta('$pedidosEnCurso', 'Pedidos en curso',
                          Colors.blue[50]!, Colors.blue),
                      const SizedBox(width: 10),
                      _tarjeta(fmtPrecio(porPagar > 0 ? porPagar : 0),
                          'Por pagar a proveedores', Colors.red[50]!, kRojo),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (misProductos().isEmpty)
                    SizedBox(
                      height: 300,
                      child: EmptyState(
                        icono: Icons.inventory_2_outlined,
                        titulo: 'Aún no tienes productos',
                        subtitulo: 'Registra el primero: queso, cajas, fresas, '
                            'vasitos... lo que quieras controlar.',
                        textoBoton: 'Registrar producto',
                        onPressed: irANuevoProducto,
                      ),
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Alertas de reabastecimiento',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        if (bajos.isNotEmpty)
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen())),
                            child: const Text('Ver todas',
                                style: TextStyle(
                                    color: kRojo, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (bajos.isEmpty)
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.check_circle, color: Colors.green),
                          title: Text('Todo en orden'),
                          subtitle: Text('Ningún producto está bajo su mínimo.'),
                        ),
                      ),
                    ...bajos.map((p) => Card(
                          child: ListTile(
                            leading: Icon(Icons.warning,
                                color: p.agotado ? Colors.grey[700] : Colors.red),
                            title: Text(p.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${fmtNum(p.cantidad)} ${p.unidad}  (mín. ${fmtNum(p.stockMinimo)} ${p.unidad})'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DetailScreen(producto: p)));
                              setState(() {});
                            },
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(String numero, String texto, Color fondo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(numero,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(texto,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
