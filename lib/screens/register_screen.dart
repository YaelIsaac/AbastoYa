import 'package:flutter/material.dart';

import '../datos.dart';
import '../navegacion.dart';
import '../theme.dart';
import '../widgets/producto_form.dart';

// Pestaña "Registrar": movimiento de un producto o producto nuevo
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int modo = registroModo.value; // 0 = movimiento, 1 = nuevo producto

  bool esEntrada = true;
  Producto? seleccionado;
  final cantidadController = TextEditingController();
  final notaController = TextEditingController();
  String? errorCantidad;

  @override
  void dispose() {
    cantidadController.dispose();
    notaController.dispose();
    super.dispose();
  }

  void _registrar(Producto p) {
    double? cant = parseNum(cantidadController.text);
    if (cant == null) {
      setState(() => errorCantidad = 'Escribe un número válido.');
      return;
    }
    String? error = registrarMovimiento(p, esEntrada, cant, notaController.text);
    if (error != null) {
      setState(() => errorCantidad = error);
      return;
    }
    cantidadController.clear();
    notaController.clear();
    setState(() => errorCantidad = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Movimiento registrado con éxito para ${p.nombre}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(modo == 0
            ? 'AbastoYa - Registrar movimiento'
            : 'AbastoYa - Nuevo producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Movimiento'),
                  selected: modo == 0,
                  selectedColor: kRojo,
                  labelStyle:
                      TextStyle(color: modo == 0 ? Colors.white : Colors.black),
                  onSelected: (_) => setState(() => modo = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Nuevo producto'),
                  selected: modo == 1,
                  selectedColor: kRojo,
                  labelStyle:
                      TextStyle(color: modo == 1 ? Colors.white : Colors.black),
                  onSelected: (_) => setState(() => modo = 1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (modo == 0) _formularioMovimiento() else const ProductoForm(),
          ],
        ),
      ),
    );
  }

  Widget _formularioMovimiento() {
    List<Producto> lista = misProductos();
    if (lista.isEmpty) {
      return SizedBox(
        height: 320,
        child: EmptyState(
          icono: Icons.inventory_2_outlined,
          titulo: 'Primero registra un producto',
          subtitulo: 'Necesitas al menos un producto para mover su stock.',
          textoBoton: 'Nuevo producto',
          onPressed: () => setState(() => modo = 1),
        ),
      );
    }
    // si el producto elegido ya no existe, se usa el primero
    if (seleccionado == null || !lista.contains(seleccionado)) {
      seleccionado = lista.first;
    }
    Producto p = seleccionado!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de movimiento',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Entrada (Compra)'),
                selected: esEntrada,
                selectedColor: Colors.green,
                onSelected: (_) => setState(() {
                  esEntrada = true;
                  errorCantidad = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Salida (Merma/Uso)'),
                selected: !esEntrada,
                selectedColor: Colors.redAccent,
                onSelected: (_) => setState(() {
                  esEntrada = false;
                  errorCantidad = null;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Seleccionar Producto',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<Producto>(
          key: ValueKey(p.id),
          initialValue: p,
          isExpanded: true,
          items: lista
              .map((x) => DropdownMenuItem(
                  value: x, child: Text(x.nombre, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (valor) => setState(() {
            seleccionado = valor;
            errorCantidad = null;
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Disponible: ${fmtNum(p.cantidad)} ${p.unidad}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const SizedBox(height: 20),
        const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: cantidadController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              hintText: 'Ej. 2', suffixText: p.unidad, errorText: errorCantidad),
        ),
        const SizedBox(height: 20),
        const Text('Nota (opcional)',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: notaController,
          decoration: const InputDecoration(hintText: 'Ej. Factura #1234'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRojo,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Registrar movimiento',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: () => _registrar(p),
          ),
        ),
      ],
    );
  }
}
