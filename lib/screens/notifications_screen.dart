import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'detail_screen.dart';

// Alertas de stock bajo y actividad reciente del negocio
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    List<Producto> bajos = productosBajos();
    List<Movimiento> recientes = misMovimientos().take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Notificaciones')),
      body: (bajos.isEmpty && recientes.isEmpty)
          ? const EmptyState(
              icono: Icons.notifications_none,
              titulo: 'Sin notificaciones',
              subtitulo: 'Aquí verás las alertas de stock bajo y tu actividad.',
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (bajos.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Alertas activas',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...bajos.map((p) => ListTile(
                        leading: Icon(Icons.warning,
                            color: p.agotado ? Colors.grey[700] : Colors.red),
                        title: Text(
                            '${p.agotado ? 'Agotado' : 'Stock bajo'}: ${p.nombre}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Quedan ${fmtNum(p.cantidad)} ${p.unidad} (mín. ${fmtNum(p.stockMinimo)} ${p.unidad})'),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailScreen(producto: p)));
                          setState(() {});
                        },
                      )),
                  const Divider(),
                ],
                if (recientes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Actividad reciente',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...recientes.map((m) => ListTile(
                        leading: Icon(
                            m.esEntrada ? Icons.check_circle : Icons.remove_circle,
                            color: m.esEntrada ? Colors.green : Colors.red),
                        title: Text(
                            m.inicial
                                ? 'Producto registrado'
                                : (m.esEntrada
                                    ? 'Entrada registrada'
                                    : 'Salida registrada'),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${m.productoNombre} (${m.esEntrada ? '+' : '-'}${fmtNum(m.cantidad)} ${m.unidad}) • ${fmtFecha(m.fecha)}'),
                      )),
                ],
              ],
            ),
    );
  }
}
