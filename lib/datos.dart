import 'models/modelos.dart';
import 'theme.dart';

// Con esta línea, las pantallas solo importan datos.dart y ya tienen los modelos.
export 'models/modelos.dart';

// ============================================================
//  DATOS DE LA APP
//  Todo se guarda en listas en memoria: al cerrar la app se pierde.
// ============================================================

// Tres usuarios de ejemplo para poder probar (contraseña: 123456)
List<Usuario> usuarios = [
  Usuario(
      nombre: 'Administrador',
      empresa: 'AbastoYa',
      correo: 'admin@abasto.com',
      password: '123456',
      rol: 'admin'),
  Usuario(
      nombre: 'Juan Pérez',
      empresa: 'Lácteos del Bajío',
      correo: 'proveedor@abasto.com',
      password: '123456',
      rol: 'proveedor',
      telefono: '4611234567',
      giro: 'Lácteos y abarrotes',
      codigo: 'PROV01',
      verificado: true),
  Usuario(
      nombre: 'María López',
      empresa: 'Mi Negocio',
      correo: 'negocio@abasto.com',
      password: '123456',
      rol: 'negocio',
      telefono: '4617654321',
      direccion: 'Calle Hidalgo 123, Centro'),
];

List<Producto> productos = [];
List<Movimiento> movimientos = [];
List<ItemCatalogo> catalogo = [];
List<Vinculo> vinculos = [];
List<Invitacion> invitaciones = [];
List<Pedido> pedidos = [];
List<Abono> abonos = [];

// Usuario que inició sesión (null si nadie)
Usuario? usuarioActual;

int _contadorId = 0;
int _contadorPedido = 0;

String nuevoId() {
  _contadorId++;
  return 'id$_contadorId';
}

// ============================================================
//  USUARIOS Y SESIÓN
// ============================================================

Usuario? buscarUsuario(String correo) {
  for (var u in usuarios) {
    if (u.correo == correo.trim().toLowerCase()) return u;
  }
  return null;
}

// Devuelve un mensaje de error, o null si todo salió bien
String? iniciarSesion(String correo, String password) {
  Usuario? u = buscarUsuario(correo);
  if (u == null || u.password != password) {
    return 'Correo o contraseña incorrectos.';
  }
  if (!u.activo) return 'Tu cuenta está suspendida.';
  usuarioActual = u;
  return null;
}

String _nuevoCodigo() {
  int n = usuarios.where((u) => u.rol == 'proveedor').length + 1;
  String codigo = 'PROV${n.toString().padLeft(2, '0')}';
  // si ya existe, se sigue subiendo el número
  while (usuarios.any((u) => u.codigo == codigo)) {
    n++;
    codigo = 'PROV${n.toString().padLeft(2, '0')}';
  }
  return codigo;
}

String? registrarUsuario({
  required String rol,
  required String nombre,
  required String empresa,
  required String telefono,
  required String correo,
  required String password,
}) {
  correo = correo.trim().toLowerCase();
  if (buscarUsuario(correo) != null) {
    return 'Ya existe una cuenta con ese correo.';
  }
  Usuario u = Usuario(
    nombre: nombre.trim(),
    empresa: empresa.trim(),
    correo: correo,
    password: password,
    rol: rol,
    telefono: telefono.trim(),
  );
  if (rol == 'proveedor') u.codigo = _nuevoCodigo();
  usuarios.add(u);

  // Si algún proveedor ya había registrado este correo, se vinculan solos
  if (rol == 'negocio') {
    for (var inv in invitaciones.where((i) => i.correo == correo)) {
      vinculos.add(Vinculo(
          proveedor: inv.proveedor,
          negocio: correo,
          estado: 'activo',
          notas: inv.notas));
    }
    invitaciones.removeWhere((i) => i.correo == correo);
  }

  usuarioActual = u;
  return null;
}

// Nombre bonito de un usuario a partir de su correo
String nombreDe(String correo) {
  Usuario? u = buscarUsuario(correo);
  return u == null ? correo : u.titulo;
}

// ============================================================
//  INVENTARIO (del negocio que inició sesión)
// ============================================================

List<Producto> misProductos() {
  return productos.where((p) => p.dueno == usuarioActual!.correo).toList();
}

List<Producto> productosBajos() {
  return misProductos().where((p) => p.stockBajo).toList();
}

// Más recientes primero
List<Movimiento> misMovimientos() {
  return movimientos
      .where((m) => m.dueno == usuarioActual!.correo)
      .toList()
      .reversed
      .toList();
}

List<String> categoriasDeInventario() {
  List<String> lista = misProductos().map((p) => p.categoria).toSet().toList();
  lista.sort();
  return lista;
}

bool _nombreRepetido(String nombre, Producto? excepto) {
  for (var p in misProductos()) {
    if (p != excepto && p.nombre.toLowerCase() == nombre.toLowerCase()) {
      return true;
    }
  }
  return false;
}

String? agregarProducto({
  required String nombre,
  required String categoria,
  required String unidad,
  required double cantidad,
  required double stockMinimo,
  String descripcion = '',
  String proveedor = '',
}) {
  nombre = nombre.trim();
  if (nombre.isEmpty) return 'Escribe el nombre del producto.';
  if (_nombreRepetido(nombre, null)) {
    return 'Ya existe un producto llamado "$nombre".';
  }
  productos.add(Producto(
    id: nuevoId(),
    dueno: usuarioActual!.correo,
    nombre: nombre,
    categoria: categoria.trim(),
    unidad: unidad.trim(),
    cantidad: cantidad,
    stockMinimo: stockMinimo,
    descripcion: descripcion.trim(),
    proveedor: proveedor,
  ));
  if (cantidad > 0) {
    movimientos.add(Movimiento(
      dueno: usuarioActual!.correo,
      productoNombre: nombre,
      unidad: unidad.trim(),
      esEntrada: true,
      cantidad: cantidad,
      nota: 'Stock inicial',
      fecha: DateTime.now(),
      inicial: true,
    ));
  }
  return null;
}

String? actualizarProducto(
  Producto p, {
  required String nombre,
  required String categoria,
  required String unidad,
  required double stockMinimo,
  String descripcion = '',
  String proveedor = '',
}) {
  nombre = nombre.trim();
  if (nombre.isEmpty) return 'Escribe el nombre del producto.';
  if (_nombreRepetido(nombre, p)) {
    return 'Ya existe un producto llamado "$nombre".';
  }
  p.nombre = nombre;
  p.categoria = categoria.trim();
  p.unidad = unidad.trim();
  p.stockMinimo = stockMinimo;
  p.descripcion = descripcion.trim();
  p.proveedor = proveedor;
  return null;
}

void eliminarProducto(Producto p) {
  productos.remove(p);
}

String? registrarMovimiento(
    Producto p, bool entrada, double cantidad, String nota) {
  if (cantidad <= 0) return 'La cantidad debe ser mayor que cero.';
  if (!entrada && cantidad > p.cantidad) {
    return 'Solo hay ${fmtNum(p.cantidad)} ${p.unidad} disponibles.';
  }
  if (entrada) {
    p.cantidad += cantidad;
  } else {
    p.cantidad -= cantidad;
  }
  movimientos.add(Movimiento(
    dueno: p.dueno,
    productoNombre: p.nombre,
    unidad: p.unidad,
    esEntrada: entrada,
    cantidad: cantidad,
    nota: nota.trim(),
    fecha: DateTime.now(),
  ));
  return null;
}

// Cuando llega un pedido: suma al inventario lo que ya existe (mismo nombre)
// y crea los productos que no existían.
void recibirPedido(Pedido ped) {
  for (var item in ped.items) {
    Producto? existente;
    for (var p in misProductos()) {
      if (p.nombre.toLowerCase() == item.nombre.toLowerCase()) {
        existente = p;
      }
    }
    if (existente != null) {
      registrarMovimiento(existente, true, item.cantidad,
          'Pedido #${ped.numero} - ${nombreDe(ped.proveedor)}');
    } else {
      agregarProducto(
        nombre: item.nombre,
        categoria: item.categoria.isEmpty ? 'General' : item.categoria,
        unidad: item.unidad,
        cantidad: item.cantidad,
        stockMinimo: 0,
        proveedor: ped.proveedor,
      );
    }
  }
  ped.inventarioActualizado = true;
}

// ============================================================
//  PROVEEDORES Y CLIENTES (vínculos)
// ============================================================

// Los proveedores del negocio que inició sesión
List<Vinculo> vinculosDelNegocio() {
  return vinculos.where((v) => v.negocio == usuarioActual!.correo).toList();
}

// Los clientes del proveedor que inició sesión
List<Vinculo> vinculosDelProveedor() {
  return vinculos.where((v) => v.proveedor == usuarioActual!.correo).toList();
}

Vinculo? buscarVinculo(String proveedor, String negocio) {
  for (var v in vinculos) {
    if (v.proveedor == proveedor && v.negocio == negocio) return v;
  }
  return null;
}

// El negocio pide ser cliente de un proveedor
String? solicitarProveedor(Usuario prov) {
  Vinculo? v = buscarVinculo(prov.correo, usuarioActual!.correo);
  if (v != null) {
    if (v.estado == 'activo') return 'Ya trabajas con ${prov.titulo}.';
    if (v.estado == 'pendiente') {
      return 'Ya enviaste una solicitud. Espera la aprobación.';
    }
    return 'El proveedor no aceptó o desactivó tu relación.';
  }
  vinculos.add(Vinculo(
      proveedor: prov.correo,
      negocio: usuarioActual!.correo,
      estado: 'pendiente'));
  return null;
}

String? solicitarPorCodigo(String codigo) {
  codigo = codigo.trim().toUpperCase();
  for (var u in usuarios) {
    if (u.rol == 'proveedor' && u.codigo == codigo && u.activo) {
      return solicitarProveedor(u);
    }
  }
  return 'No existe ningún proveedor con ese código.';
}

// El proveedor registra un negocio por su correo
String? invitarNegocio({
  required String correo,
  required String nombre,
  String telefono = '',
  String direccion = '',
  String notas = '',
}) {
  correo = correo.trim().toLowerCase();
  String miCorreo = usuarioActual!.correo;
  if (buscarVinculo(miCorreo, correo) != null) {
    return 'Ese negocio ya está en tu lista de clientes.';
  }
  if (invitaciones.any((i) => i.proveedor == miCorreo && i.correo == correo)) {
    return 'Ya registraste ese correo. Espera a que cree su cuenta.';
  }
  Usuario? negocio = buscarUsuario(correo);
  if (negocio != null && negocio.rol == 'negocio') {
    // ya tiene cuenta: queda vinculado de inmediato
    vinculos.add(Vinculo(
        proveedor: miCorreo, negocio: correo, estado: 'activo', notas: notas));
  } else {
    invitaciones.add(Invitacion(
        proveedor: miCorreo,
        correo: correo,
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        direccion: direccion.trim(),
        notas: notas.trim()));
  }
  return null;
}

// ============================================================
//  CATÁLOGO (del proveedor)
// ============================================================

List<ItemCatalogo> miCatalogo() {
  List<ItemCatalogo> lista =
      catalogo.where((i) => i.proveedor == usuarioActual!.correo).toList();
  lista.sort((a, b) {
    int c = a.categoria.toLowerCase().compareTo(b.categoria.toLowerCase());
    if (c != 0) return c;
    return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
  });
  return lista;
}

// Catálogo de cualquier proveedor (lo usa el negocio al pedir)
List<ItemCatalogo> catalogoDe(String proveedor) {
  List<ItemCatalogo> lista =
      catalogo.where((i) => i.proveedor == proveedor).toList();
  lista.sort((a, b) {
    int c = a.categoria.toLowerCase().compareTo(b.categoria.toLowerCase());
    if (c != 0) return c;
    return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
  });
  return lista;
}

String? guardarItemCatalogo(
  ItemCatalogo? item, {
  required String nombre,
  required String descripcion,
  required String categoria,
  required String unidad,
  required double precio,
  required bool disponible,
}) {
  nombre = nombre.trim();
  if (nombre.isEmpty) return 'Escribe el nombre.';
  for (var i in miCatalogo()) {
    if (i != item && i.nombre.toLowerCase() == nombre.toLowerCase()) {
      return 'Ya tienes "$nombre" en tu catálogo.';
    }
  }
  if (item == null) {
    catalogo.add(ItemCatalogo(
      id: nuevoId(),
      proveedor: usuarioActual!.correo,
      nombre: nombre,
      descripcion: descripcion.trim(),
      categoria: categoria.trim(),
      unidad: unidad.trim(),
      precio: precio,
      disponible: disponible,
    ));
  } else {
    item.nombre = nombre;
    item.descripcion = descripcion.trim();
    item.categoria = categoria.trim();
    item.unidad = unidad.trim();
    item.precio = precio;
    item.disponible = disponible;
  }
  return null;
}

// ============================================================
//  PEDIDOS Y COBROS
// ============================================================

// Pedidos del usuario que inició sesión (más recientes primero)
List<Pedido> misPedidos() {
  String yo = usuarioActual!.correo;
  bool soyProveedor = usuarioActual!.rol == 'proveedor';
  List<Pedido> lista = pedidos
      .where((p) => soyProveedor ? p.proveedor == yo : p.negocio == yo)
      .toList();
  lista.sort((a, b) => b.fecha.compareTo(a.fecha));
  return lista;
}

void crearPedido(Vinculo v, List<ItemPedido> items, String direccion,
    String fechaDeseada, String notas) {
  double total = 0;
  for (var i in items) {
    total += i.subtotal;
  }
  _contadorPedido++;
  pedidos.add(Pedido(
    numero: _contadorPedido,
    proveedor: v.proveedor,
    negocio: v.negocio,
    items: items,
    total: total,
    direccion: direccion.trim(),
    fechaDeseada: fechaDeseada.trim(),
    notas: notas.trim(),
    fecha: DateTime.now(),
  ));
}

// Pedidos entre el usuario actual y otro usuario (proveedor o negocio)
List<Pedido> pedidosCon(String otro) {
  return misPedidos()
      .where((p) => p.proveedor == otro || p.negocio == otro)
      .toList();
}

List<Abono> abonosCon(String otro) {
  String yo = usuarioActual!.correo;
  List<Abono> lista = abonos
      .where((a) =>
          (a.proveedor == yo && a.negocio == otro) ||
          (a.negocio == yo && a.proveedor == otro))
      .toList();
  lista.sort((a, b) => b.fecha.compareTo(a.fecha));
  return lista;
}

// Lo que se debe con otra persona: pedidos entregados menos abonos
double saldoCon(String otro) {
  double entregado = 0;
  for (var p in pedidosCon(otro)) {
    if (p.estado == 'entregado') entregado += p.total;
  }
  double abonado = 0;
  for (var a in abonosCon(otro)) {
    abonado += a.monto;
  }
  return entregado - abonado;
}

// Saldo de todo: lo que me deben (proveedor) o lo que debo (negocio)
double saldoTotal() {
  String yo = usuarioActual!.correo;
  bool soyProveedor = usuarioActual!.rol == 'proveedor';
  double total = 0;
  for (var v in vinculos) {
    if (soyProveedor && v.proveedor == yo) total += saldoCon(v.negocio);
    if (!soyProveedor && v.negocio == yo) total += saldoCon(v.proveedor);
  }
  return total;
}

String? registrarAbono(String negocio, double monto, String nota) {
  if (monto <= 0) return 'El monto debe ser mayor que cero.';
  abonos.add(Abono(
    proveedor: usuarioActual!.correo,
    negocio: negocio,
    monto: monto,
    nota: nota.trim(),
    fecha: DateTime.now(),
  ));
  return null;
}
