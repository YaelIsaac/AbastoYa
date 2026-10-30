import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// Ventanita para registrar una entrada o salida de un producto.
// Devuelve cuando se cierra; quien la llama hace setState para refrescar.
Future<void> mostrarMovimiento(
    BuildContext context, Producto producto, bool entrada) async {
  final cantidadCtrl = TextEditingController();
  final notaCtrl = TextEditingController();
  String? error;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      // StatefulBuilder permite usar setState dentro del diálogo
      return StatefulBuilder(builder: (ctx, setDialog) {
        return AlertDialog(
          title: Text('${entrada ? 'Entrada' : 'Salida'}: ${producto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Actual: ${fmtNum(producto.cantidad)} ${producto.unidad}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: cantidadCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: 'Cantidad (${producto.unidad})',
                    errorText: error),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nota (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                double? cant = parseNum(cantidadCtrl.text);
                if (cant == null) {
                  setDialog(() => error = 'Escribe un número válido.');
                  return;
                }
                String? err =
                    registrarMovimiento(producto, entrada, cant, notaCtrl.text);
                if (err != null) {
                  setDialog(() => error = err);
                  return;
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      });
    },
  );
  cantidadCtrl.dispose();
  notaCtrl.dispose();
}
