import 'package:flutter/material.dart';

import '../datos.dart';
import '../navegacion.dart';
import '../theme.dart';
import 'catalogo_screen.dart';
import 'clientes_screen.dart';
import 'proveedor_home_screen.dart';
import 'proveedor_mas_screen.dart';
import 'proveedor_pedidos_screen.dart';

// Navegación (barra de abajo) del PROVEEDOR
class ProveedorNavigation extends StatefulWidget {
  const ProveedorNavigation({super.key});

  @override
  State<ProveedorNavigation> createState() => _ProveedorNavigationState();
}

class _ProveedorNavigationState extends State<ProveedorNavigation> {
  @override
  void initState() {
    super.initState();
    provTab.value = 0;
  }

  Widget _pantalla(int index) {
    switch (index) {
      case 0:
        return const ProveedorHomeScreen();
      case 1:
        return const ProveedorPedidosScreen();
      case 2:
        return const ClientesScreen();
      case 3:
        return const CatalogoScreen();
      default:
        return const ProveedorMasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: provTab,
      builder: (context, index, _) {
        int nuevos = misPedidos().where((p) => p.estado == 'nuevo').length;
        int solicitudes =
            vinculosDelProveedor().where((v) => v.estado == 'pendiente').length;
        return Scaffold(
          body: _pantalla(index),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: kRojo,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => provTab.value = i,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Badge(
                    label: Text('$nuevos'),
                    isLabelVisible: nuevos > 0,
                    child: const Icon(Icons.receipt_long)),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                    label: Text('$solicitudes'),
                    isLabelVisible: solicitudes > 0,
                    child: const Icon(Icons.groups)),
                label: 'Clientes',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2), label: 'Catálogo'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.menu), label: 'Más'),
            ],
          ),
        );
      },
    );
  }
}
