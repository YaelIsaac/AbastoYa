import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// Catálogo del proveedor: todos los productos que puede surtir
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  Future<void> _abrirFormulario([ItemCatalogo? item]) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => CatalogoFormScreen(item: item)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<ItemCatalogo> lista = miCatalogo();

    // se arma la lista con un título por cada categoría
    List<Widget> filas = [];
    String? ultimaCategoria;
    for (var it in lista) {
      if (it.categoria != ultimaCategoria) {
        ultimaCategoria = it.categoria;
        filas.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(it.categoria,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ));
      }
      filas.add(Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          title: Text(it.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${fmtPrecio(it.precio)} / ${it.unidad}'
              '${it.descripcion.isEmpty ? '' : '\n${it.descripcion}'}'),
          isThreeLine: it.descripcion.isNotEmpty,
          trailing: Switch(
            value: it.disponible,
            activeThumbColor: Colors.green,
            onChanged: (valor) => setState(() => it.disponible = valor),
          ),
          onTap: () => _abrirFormulario(it),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Catálogo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar producto'),
      ),
      body: lista.isEmpty
          ? EmptyState(
              icono: Icons.inventory_2_outlined,
              titulo: 'Tu catálogo está vacío',
              subtitulo:
                  'Agrega todo lo que puedes surtir: lácteos, empaques, frutas, lo que manejes.',
              textoBoton: 'Agregar producto',
              onPressed: () => _abrirFormulario(),
            )
          : ListView(padding: const EdgeInsets.only(bottom: 90), children: filas),
    );
  }
}

const List<String> _categoriasCatalogo = [
  'Lácteos', 'Abarrotes', 'Empaques', 'Bebidas', 'Frutas y verduras', 'Limpieza',
];
const List<String> _unidadesCatalogo = [
  'kg', 'g', 'L', 'ml', 'pzas', 'cajas', 'paquetes',
];

// Formulario para agregar o editar un producto del catálogo
class CatalogoFormScreen extends StatefulWidget {
  final ItemCatalogo? item; // null = producto nuevo
  const CatalogoFormScreen({super.key, this.item});

  @override
  State<CatalogoFormScreen> createState() => _CatalogoFormScreenState();
}

class _CatalogoFormScreenState extends State<CatalogoFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _categoria = TextEditingController();
  final _unidad = TextEditingController();
  final _precio = TextEditingController();
  bool disponible = true;

  bool get editando => widget.item != null;

  @override
  void initState() {
    super.initState();
    ItemCatalogo? i = widget.item;
    if (i != null) {
      _nombre.text = i.nombre;
      _descripcion.text = i.descripcion;
      _categoria.text = i.categoria;
      _unidad.text = i.unidad;
      _precio.text = fmtNum(i.precio);
      disponible = i.disponible;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _categoria.dispose();
    _unidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    String? error = guardarItemCatalogo(
      widget.item,
      nombre: _nombre.text,
      descripcion: _descripcion.text,
      categoria: _categoria.text,
      unidad: _unidad.text,
      precio: parseNum(_precio.text) ?? 0,
      disponible: disponible,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editando ? 'Catálogo actualizado' : 'Producto agregado')));
    if (editando) {
      Navigator.pop(context);
    } else {
      // se deja limpio para seguir agregando productos
      _nombre.clear();
      _descripcion.clear();
      _precio.clear();
      _form.currentState!.reset();
    }
  }

  Future<void> _eliminar() async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar del catálogo'),
        content: Text('¿Eliminar "${widget.item!.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      catalogo.remove(widget.item);
      Navigator.pop(context);
    }
  }

  Widget _opciones(List<String> lista, TextEditingController destino) {
    return Wrap(
      spacing: 8,
      children: lista
          .map((o) => ActionChip(
              label: Text(o), onPressed: () => setState(() => destino.text = o)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // categorías base + las que ya usó el proveedor
    List<String> categorias = [..._categoriasCatalogo];
    for (var i in miCatalogo()) {
      if (!categorias.contains(i.categoria)) categorias.add(i.categoria);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar producto' : 'Nuevo producto'),
        actions: [
          if (editando)
            IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete),
                onPressed: _eliminar),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombre,
                maxLength: 60,
                decoration: const InputDecoration(
                    labelText: 'Nombre', hintText: 'Ej. Queso mozzarella'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcion,
                maxLines: 2,
                maxLength: 150,
                decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Presentación, marca...'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoria,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              _opciones(categorias, _categoria),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precio,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Precio', prefixText: '\$ '),
                      validator: (v) {
                        double? n = parseNum(v ?? '');
                        if (n == null) return 'Precio no válido';
                        if (n < 0) return 'No puede ser negativo';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unidad,
                      maxLength: 15,
                      decoration: const InputDecoration(
                          labelText: 'Por cada...',
                          hintText: 'kg, caja...',
                          counterText: ''),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                    ),
                  ),
                ],
              ),
              _opciones(_unidadesCatalogo, _unidad),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponible para pedir'),
                value: disponible,
                activeThumbColor: Colors.green,
                onChanged: (v) => setState(() => disponible = v),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRojo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.save),
                  label: Text(editando ? 'Guardar cambios' : 'Agregar al catálogo'),
                  onPressed: _guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
