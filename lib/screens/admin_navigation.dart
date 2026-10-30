import 'package:flutter/material.dart';

import '../navegacion.dart';
import '../theme.dart';
import 'admin_cuentas_screen.dart';
import 'admin_resumen_screen.dart';

// Navegación (barra de abajo) del ADMINISTRADOR
class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  @override
  void initState() {
    super.initState();
    adminTab.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: adminTab,
      builder: (context, index, _) {
        return Scaffold(
          body: index == 0 ? const AdminResumenScreen() : const AdminCuentasScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: kRojo,
            unselectedItemColor: Colors.grey,
            onTap: (i) => adminTab.value = i,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Resumen'),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Cuentas'),
            ],
          ),
        );
      },
    );
  }
}
