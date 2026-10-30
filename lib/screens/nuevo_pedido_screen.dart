import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// El negocio arma un pedido con el catálogo de UN proveedor
class NuevoPedidoScreen extends StatefulWidget {
  final Vinculo vinculo;
  const NuevoPedidoScreen({super.key, required this.vinculo});

  @override
  State<NuevoPedidoScreen> createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  // cantidad que se lleva de cada producto (clave = id del producto)
  final Map<String, double> cantidades = {};
  String busqueda = '';

  List<ItemCatalogo> get disponibles =>
      catalogoDe(widget.vinculo.proveedor).where((i) => i.disponible).toList();

  double get total {
    double t = 0;
    for (var i in disponibles) {
      t += i.precio * (cantidades[i.id] ?? 0);
    }
    return t;
  }

  int get lineas => cantidades.values.where((c) => c > 0).length;

  void _cambiar(ItemCatalogo i, double cambio) {
    setState(() {
      double nueva = (cantidades[i.id] ?? 0) + cambio;
      if (nueva <= 0) {
        cantidades.remove(i.id);
      } else {
        cantidades[i.id] = nueva;
      }
    });
  }

  Future<void> _escribirCantidad(ItemCatalogo i) async {
    final c = TextEditingController(text: fmtNum(cantidades[i.id] ?? 0));
    double? r = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i.nombre),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Cantidad (${i.unidad})'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, parseNum(c.text)),
              child: const Text('Aceptar')),
        ],
      ),
    );
    c.dispose();
    if (r != null && r >= 0) {
      setState(() {
        if (r == 0) {
          cantidades.remove(i.id);
        } else {
          cantidades[i.id] = r;
        }
      });
    }
  }

  // Ventana final: dirección, fecha y notas, y se envía el pedido
  void _revisar() {
    List<ItemPedido> items = [];
    for (var i in disponibles) {
      double c = cantidades[i.id] ?? 0;
      if (c > 0) {
        items.add(ItemPedido(
            nombre: i.nombre,
            unidad: i.unidad,
            categoria: i.categoria,
            precio: i.precio,
            cantidad: c));
      }
    }
    if (items.isEmpty) return;

    final direccion = TextEditingController(text: usuarioActual!.direccion);
    final fecha = TextEditingController();
    final notas = TextEditingController();
    double totalPedido = 0;
    for (var i in items) {
      totalPedido += i.subtotal;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pedido para ${nombreDe(widget.vinculo.proveedor)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Expanded(
                          child: Text(
                              '${fmtNum(i.cantidad)} ${i.unidad} × ${i.nombre}')),
                      Text(fmtPrecio(i.subtotal)),
                    ]),
                  )),
              const Divider(),
              Row(children: [
                const Expanded(
                    child: Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Text(fmtPrecio(totalPedido),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: direccion,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Dirección de entrega'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fecha,
                decoration: const InputDecoration(
                    labelText: '¿Para cuándo lo necesitas? (opcional)',
                    hintText: 'Ej. Jueves por la mañana'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notas,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRojo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.send),
                  label: Text('Enviar pedido • ${fmtPrecio(totalPedido)}'),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    crearPedido(widget.vinculo, items, direccion.text,
                        fecha.text, notas.text);
                    Navigator.pop(ctx); // cierra la ventana
                    Navigator.pop(context); // regresa a la pantalla anterior
                    messenger.showSnackBar(const SnackBar(
                        content: Text('¡Pedido enviado al proveedor!')));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      direccion.dispose();
      fecha.dispose();
      notas.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    Vinculo v = widget.vinculo;
    // productos del inventario que se están acabando
    Set<String> faltantes =
        productosBajos().map((p) => p.nombre.toLowerCase()).toSet();

    List<ItemCatalogo> lista = disponibles
        .where((i) => i.nombre.toLowerCase().contains(busqueda.toLowerCase()))
        .toList();

    // se arma la lista con un título por cada categoría
    List<Widget> filas = [];
    String? ultimaCategoria;
    for (var i in lista) {
      if (i.categoria != ultimaCategoria) {
        ultimaCategoria = i.categoria;
        filas.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(i.categoria,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ));
      }
      double c = cantidades[i.id] ?? 0;
      filas.add(Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          title: Row(
            children: [
              Flexible(
                  child: Text(i.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              if (faltantes.contains(i.nombre.toLowerCase()))
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Chip(
                    label: Text('Te hace falta',
                        style: TextStyle(fontSize: 9, color: Colors.white)),
                    backgroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          subtitle: Text('${fmtPrecio(i.precio)} / ${i.unidad}'
              '${i.descripcion.isEmpty ? '' : '\n${i.descripcion}'}'),
          trailing: c == 0
              ? IconButton(
                  icon: const Icon(Icons.add_circle, color: kRojo, size: 30),
                  onPressed: () => _cambiar(i, 1),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _cambiar(i, -1)),
                    GestureDetector(
                      onTap: () => _escribirCantidad(i),
                      child: Text(fmtNum(c),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline)),
                    ),
                    IconButton(
                        icon: const Icon(Icons.add_circle, color: kRojo),
                        onPressed: () => _cambiar(i, 1)),
                  ],
                ),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Pedir a ${nombreDe(v.proveedor)}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (texto) => setState(() => busqueda = texto),
              decoration: InputDecoration(
                hintText: 'Buscar en su catálogo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: disponibles.isEmpty
                ? const EmptyState(
                    icono: Icons.inventory_2_outlined,
                    titulo: 'Catálogo vacío',
                    subtitulo: 'Este proveedor aún no publica productos.')
                : lista.isEmpty
                    ? const EmptyState(
                        icono: Icons.search_off,
                        titulo: 'Sin resultados',
                        subtitulo: 'Prueba con otra búsqueda.')
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 20),
                        children: filas),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(blurRadius: 4, color: Colors.black12)
            ]),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$lineas producto(s)',
                            style: const TextStyle(color: Colors.grey)),
                        Text(fmtPrecio(total),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRojo,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: lineas == 0 ? null : _revisar,
                    child: const Text('Revisar pedido'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
