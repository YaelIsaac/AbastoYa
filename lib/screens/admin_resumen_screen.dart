import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'login_screen.dart';

// Estadísticas generales de la plataforma
class AdminResumenScreen extends StatelessWidget {
  const AdminResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cada dato es: texto, cantidad
    Map<String, int> datos = {
      'Proveedores': usuarios.where((u) => u.rol == 'proveedor').length,
      'Negocios': usuarios.where((u) => u.rol == 'negocio').length,
      'Administradores': usuarios.where((u) => u.rol == 'admin').length,
      'Proveedores por verificar':
          usuarios.where((u) => u.rol == 'proveedor' && !u.verificado).length,
      'Cuentas suspendidas': usuarios.where((u) => !u.activo).length,
      'Relaciones activas': vinculos.where((v) => v.estado == 'activo').length,
      'Pedidos totales': pedidos.length,
      'Pedidos entregados': pedidos.where((p) => p.estado == 'entregado').length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('AbastoYa - Plataforma'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => cerrarSesion(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: datos.entries.map((e) {
          bool alerta = (e.key == 'Proveedores por verificar' ||
                  e.key == 'Cuentas suspendidas') &&
              e.value > 0;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: alerta ? Colors.amber[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.value}',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: alerta ? Colors.orange : kRojo)),
                Text(e.key,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
