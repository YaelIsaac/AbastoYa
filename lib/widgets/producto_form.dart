import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

const List<String> categoriasBase = [
  'Ingredientes',
  'Empaques',
  'Bebidas',
  'Limpieza',
];
const List<String> unidadesBase = [
  'kg', 'g', 'L', 'ml', 'pzas', 'cajas', 'paquetes',
];

// Formulario para registrar un producto nuevo (o editar uno existente).
// Sirve para cualquier cosa: queso, cajas, fresas, vasitos...
class ProductoForm extends StatefulWidget {
  final Producto? producto; // null = producto nuevo
  final VoidCallback? alGuardar;

  const ProductoForm({super.key, this.producto, this.alGuardar});

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _categoria = TextEditingController();
  final _unidad = TextEditingController();
  final _cantidad = TextEditingController();
  final _minimo = TextEditingController();
  final _descripcion = TextEditingController();
  String _proveedor = ''; // correo del proveedor elegido

  bool get editando => widget.producto != null;

  @override
  void initState() {
    super.initState();
    Producto? p = widget.producto;
    if (p != null) {
      _nombre.text = p.nombre;
      _categoria.text = p.categoria;
      _unidad.text = p.unidad;
      _minimo.text = fmtNum(p.stockMinimo);
      _descripcion.text = p.descripcion;
      _proveedor = p.proveedor;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _categoria.dispose();
    _unidad.dispose();
    _cantidad.dispose();
    _minimo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  String? _validarNumero(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    double? n = parseNum(v);
    if (n == null) return 'Número no válido';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    String? error;
    if (editando) {
      error = actualizarProducto(
        widget.producto!,
        nombre: _nombre.text,
        categoria: _categoria.text,
        unidad: _unidad.text,
        stockMinimo: parseNum(_minimo.text) ?? 0,
        descripcion: _descripcion.text,
        proveedor: _proveedor,
      );
    } else {
      error = agregarProducto(
        nombre: _nombre.text,
        categoria: _categoria.text,
        unidad: _unidad.text,
        cantidad: parseNum(_cantidad.text) ?? 0,
        stockMinimo: parseNum(_minimo.text) ?? 0,
        descripcion: _descripcion.text,
        proveedor: _proveedor,
      );
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(editando
            ? 'Producto actualizado'
            : 'Producto "${_nombre.text.trim()}" registrado')));
    if (!editando) {
      // se deja el formulario limpio para seguir agregando productos
      _nombre.clear();
      _categoria.clear();
      _unidad.clear();
      _cantidad.clear();
      _minimo.clear();
      _descripcion.clear();
      _proveedor = '';
      _form.currentState!.reset();
      setState(() {});
    }
    if (widget.alGuardar != null) widget.alGuardar!();
  }

  // Botoncitos para elegir rápido una opción
  Widget _opciones(List<String> lista, TextEditingController destino) {
    return Wrap(
      spacing: 8,
      children: lista
          .map((o) => ActionChip(
                label: Text(o),
                onPressed: () => setState(() => destino.text = o),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // categorías base + las que ya usó el negocio
    List<String> categorias = [...categoriasBase];
    for (var c in categoriasDeInventario()) {
      if (!categorias.contains(c)) categorias.add(c);
    }
    // proveedores con los que ya trabaja
    List<Vinculo> misProveedores =
        vinculosDelNegocio().where((v) => v.estado == 'activo').toList();

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nombre del producto',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nombre,
            maxLength: 60,
            decoration:
                const InputDecoration(hintText: 'Ej. Queso, Fresas, Vasitos...'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 8),
          const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _categoria,
            maxLength: 30,
            decoration:
                const InputDecoration(hintText: 'Escribe una o elige abajo'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
          ),
          _opciones(categorias, _categoria),
          const SizedBox(height: 16),
          const Text('Unidad de medida',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _unidad,
            maxLength: 15,
            decoration: const InputDecoration(hintText: 'kg, pzas, cajas, L...'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
          ),
          _opciones(unidadesBase, _unidad),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!editando) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cantidad inicial',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cantidad,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'Ej. 10'),
                        validator: _validarNumero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stock mínimo',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _minimo,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Ej. 3'),
                      validator: _validarNumero,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Te avisaremos cuando baje de este mínimo.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          const Text('Proveedor (opcional)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey('prov$_proveedor${misProveedores.length}'),
            initialValue: _proveedor,
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('Sin proveedor')),
              ...misProveedores.map((v) => DropdownMenuItem(
                  value: v.proveedor, child: Text(nombreDe(v.proveedor)))),
            ],
            onChanged: (valor) => setState(() => _proveedor = valor ?? ''),
          ),
          const SizedBox(height: 16),
          const Text('Descripción (opcional)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descripcion,
            maxLines: 2,
            maxLength: 200,
            decoration:
                const InputDecoration(hintText: 'Presentación, notas...'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kRojo,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(editando ? 'Guardar cambios' : 'Registrar producto',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _guardar,
            ),
          ),
        ],
      ),
    );
  }
}
