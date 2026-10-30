import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'cobro_screen.dart';
import 'cuenta_screen.dart';
import 'login_screen.dart';
import 'proveedor_reports_screen.dart';

// Pestaña "Más" del proveedor
class ProveedorMasScreen extends StatelessWidget {
  const ProveedorMasScreen({super.key});

  void _ir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    Usuario yo = usuarioActual!;
    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Más')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: kRojo,
                  child: Icon(Icons.local_shipping, color: Colors.white)),
              title: Text(yo.titulo),
              subtitle: Text(yo.correo),
            ),
          ),
          const SizedBox(height: 8),
          _opcion(context, Icons.bar_chart, 'Reportes',
              'Ventas, clientes y productos más pedidos',
              const ProveedorReportsScreen()),
          _opcion(context, Icons.account_balance, 'Cuenta para transferencias',
              'Datos que verán tus clientes al pagar', const CobroScreen()),
          _opcion(context, Icons.manage_accounts, 'Mi empresa',
              'Datos, qué productos manejas y tu código', const CuentaScreen()),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: () => cerrarSesion(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context, IconData icono, String titulo,
      String subtitulo, Widget destino) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: kRojo),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => _ir(context, destino),
      ),
    );
  }
}
