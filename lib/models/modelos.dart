import 'package:flutter/material.dart';

// Aquí están todas las clases (modelos) de la app.
// Cada una guarda los datos de algo: un usuario, un producto, un pedido...

// Los usuarios se identifican por su correo (no se repite).
class Usuario {
  String nombre;
  String empresa;
  String correo;
  String password;
  String rol; // 'admin', 'proveedor' o 'negocio'
  String telefono;
  String direccion;
  String giro; // qué productos maneja (proveedor)
  String codigo; // código del proveedor
  // Datos para transferencias (proveedor)
  String titular;
  String banco;
  String cuenta;
  String instrucciones;
  bool verificado;
  bool activo;

  Usuario({
    required this.nombre,
    required this.empresa,
    required this.correo,
    required this.password,
    required this.rol,
    this.telefono = '',
    this.direccion = '',
    this.giro = '',
    this.codigo = '',
    this.titular = '',
    this.banco = '',
    this.cuenta = '',
    this.instrucciones = '',
    this.verificado = false,
    this.activo = true,
  });

  String get titulo => empresa.isNotEmpty ? empresa : nombre;

  String get etiquetaRol {
    if (rol == 'admin') return 'Administrador';
    if (rol == 'proveedor') return 'Proveedor';
    return 'Negocio';
  }
}

// Producto del inventario de un negocio
class Producto {
  String id;
  String dueno; // correo del negocio dueño
  String nombre;
  String categoria;
  String unidad;
  String descripcion;
  String proveedor; // correo del proveedor (vacío si no tiene)
  double cantidad;
  double stockMinimo;

  Producto({
    required this.id,
    required this.dueno,
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.cantidad,
    required this.stockMinimo,
    this.descripcion = '',
    this.proveedor = '',
  });

  bool get agotado => cantidad <= 0;
  bool get stockBajo => cantidad <= stockMinimo;

  String get estado {
    if (agotado) return 'Agotado';
    if (stockBajo) return 'Stock bajo';
    return 'En stock';
  }
}

// Una entrada o salida de inventario
class Movimiento {
  String dueno;
  String productoNombre;
  String unidad;
  bool esEntrada;
  bool inicial; // true si es el stock con el que se creó el producto
  double cantidad;
  String nota;
  DateTime fecha;

  Movimiento({
    required this.dueno,
    required this.productoNombre,
    required this.unidad,
    required this.esEntrada,
    required this.cantidad,
    required this.nota,
    required this.fecha,
    this.inicial = false,
  });
}

// Producto que ofrece un proveedor en su catálogo
class ItemCatalogo {
  String id;
  String proveedor; // correo del proveedor
  String nombre;
  String descripcion;
  String categoria;
  String unidad;
  double precio;
  bool disponible;

  ItemCatalogo({
    required this.id,
    required this.proveedor,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.unidad,
    required this.precio,
    required this.disponible,
  });
}

// Relación entre un proveedor y un negocio
class Vinculo {
  String proveedor; // correo
  String negocio; // correo
  String estado; // pendiente, activo, inactivo o rechazado
  String notas; // notas privadas del proveedor

  Vinculo({
    required this.proveedor,
    required this.negocio,
    required this.estado,
    this.notas = '',
  });
}

// Negocio que un proveedor registró por correo pero que aún no tiene cuenta
class Invitacion {
  String proveedor; // correo del proveedor
  String correo; // correo del negocio
  String nombre;
  String telefono;
  String direccion;
  String notas;

  Invitacion({
    required this.proveedor,
    required this.correo,
    required this.nombre,
    this.telefono = '',
    this.direccion = '',
    this.notas = '',
  });
}

class ItemPedido {
  String nombre;
  String unidad;
  String categoria;
  double precio;
  double cantidad;

  ItemPedido({
    required this.nombre,
    required this.unidad,
    required this.categoria,
    required this.precio,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;
}

class Pedido {
  int numero;
  String proveedor; // correo
  String negocio; // correo
  List<ItemPedido> items;
  double total;
  String estado; // nuevo, aceptado, enviado, entregado, rechazado, cancelado
  String direccion;
  String fechaDeseada;
  String notas;
  DateTime fecha;
  bool inventarioActualizado;

  Pedido({
    required this.numero,
    required this.proveedor,
    required this.negocio,
    required this.items,
    required this.total,
    required this.direccion,
    required this.fechaDeseada,
    required this.notas,
    required this.fecha,
    this.estado = 'nuevo',
    this.inventarioActualizado = false,
  });

  // Un pedido está "activo" mientras no termine
  bool get activo =>
      estado == 'nuevo' || estado == 'aceptado' || estado == 'enviado';

  // El siguiente estado que le toca (lo cambia el proveedor)
  String? get siguienteEstado {
    if (estado == 'nuevo') return 'aceptado';
    if (estado == 'aceptado') return 'enviado';
    if (estado == 'enviado') return 'entregado';
    return null;
  }
}

// Pago que un negocio hizo a un proveedor
class Abono {
  String proveedor;
  String negocio;
  double monto;
  String nota;
  DateTime fecha;

  Abono({
    required this.proveedor,
    required this.negocio,
    required this.monto,
    required this.nota,
    required this.fecha,
  });
}

String etiquetaEstado(String e) {
  switch (e) {
    case 'nuevo':
      return 'Nuevo';
    case 'aceptado':
      return 'Aceptado';
    case 'enviado':
      return 'Enviado';
    case 'entregado':
      return 'Entregado';
    case 'rechazado':
      return 'Rechazado';
    case 'cancelado':
      return 'Cancelado';
    case 'activo':
      return 'Activo';
    case 'pendiente':
      return 'Pendiente';
    case 'inactivo':
      return 'Inactivo';
    default:
      return e;
  }
}

Color colorEstado(String e) {
  switch (e) {
    case 'nuevo':
      return Colors.blue;
    case 'aceptado':
      return Colors.orange;
    case 'enviado':
      return Colors.purple;
    case 'entregado':
    case 'activo':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
