import 'package:flutter/material.dart';

// Pestaña activa de cada tipo de usuario.
// Son "notificadores": cuando cambian su valor, la barra de abajo se redibuja.
final ValueNotifier<int> navTab = ValueNotifier<int>(0); // negocio
final ValueNotifier<int> provTab = ValueNotifier<int>(0); // proveedor
final ValueNotifier<int> adminTab = ValueNotifier<int>(0); // administrador

// Modo de la pantalla "Registrar" del negocio (0 = movimiento, 1 = nuevo producto)
final ValueNotifier<int> registroModo = ValueNotifier<int>(0);

// Manda al negocio a la pantalla Registrar, ya en "Nuevo producto"
void irANuevoProducto() {
  registroModo.value = 1;
  navTab.value = 2;
}
