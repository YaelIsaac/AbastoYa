import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// El proveedor escribe su cuenta para transferencias (solo texto)
class CobroScreen extends StatefulWidget {
  const CobroScreen({super.key});

  @override
  State<CobroScreen> createState() => _CobroScreenState();
}

class _CobroScreenState extends State<CobroScreen> {
  final _form = GlobalKey<FormState>();
  final _titular = TextEditingController();
  final _banco = TextEditingController();
  final _cuenta = TextEditingController();
  final _instrucciones = TextEditingController();

  @override
  void initState() {
    super.initState();
    Usuario u = usuarioActual!;
    _titular.text = u.titular;
    _banco.text = u.banco;
    _cuenta.text = u.cuenta;
    _instrucciones.text = u.instrucciones;
  }

  @override
  void dispose() {
    _titular.dispose();
    _banco.dispose();
    _cuenta.dispose();
    _instrucciones.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    Usuario u = usuarioActual!;
    u.titular = _titular.text.trim();
    u.banco = _banco.text.trim();
    u.cuenta = _cuenta.text.trim();
    u.instrucciones = _instrucciones.text.trim();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Datos guardados')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta para transferencias')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Tus clientes verán estos datos al pagar sus pedidos.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titular,
                decoration: const InputDecoration(labelText: 'Titular de la cuenta'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _banco,
                decoration: const InputDecoration(labelText: 'Banco'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cuenta,
                decoration: const InputDecoration(
                    labelText: 'Número de cuenta / CLABE / tarjeta'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el número de cuenta'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instrucciones,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Instrucciones (opcional)',
                    hintText: 'Ej. Pon el nombre de tu negocio en el concepto'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRojo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
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
