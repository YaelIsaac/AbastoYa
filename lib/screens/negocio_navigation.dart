import 'package:flutter/material.dart';

import '../datos.dart';
import '../navegacion.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'inventory_screen.dart';
import 'negocio_mas_screen.dart';
import 'negocio_proveedores_screen.dart';
import 'register_screen.dart';

// Navegación (barra de abajo) del NEGOCIO
class NegocioNavigation extends StatefulWidget {
  const NegocioNavigation({super.key});

  @override
  State<NegocioNavigation> createState() => _NegocioNavigationState();
}

class _NegocioNavigationState extends State<NegocioNavigation> {
  @override
  void initState() {
    super.initState();
    navTab.value = 0;
    registroModo.value = 0;
  }

  // Cada vez que se cambia de pestaña se crea la pantalla de nuevo,
  // así siempre muestra los datos más recientes.
  Widget _pantalla(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const InventoryScreen();
      case 2:
        return const RegisterScreen();
      case 3:
        return const NegocioProveedoresScreen();
      default:
        return const NegocioMasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: navTab,
      builder: (context, index, _) {
        int bajos = productosBajos().length;
        return Scaffold(
          body: _pantalla(index),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: kRojo,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 2) registroModo.value = 0;
              navTab.value = i;
            },
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Inicio'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2), label: 'Inventario'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle, size: 36, color: kRojo),
                  label: 'Registrar'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping), label: 'Proveedores'),
              BottomNavigationBarItem(
                icon: Badge(
                    label: Text('$bajos'),
                    isLabelVisible: bajos > 0,
                    child: const Icon(Icons.menu)),
                label: 'Más',
              ),
            ],
          ),
        );
      },
    );
  }
}
