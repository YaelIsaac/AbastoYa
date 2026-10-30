import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// El proveedor registra a un negocio con su correo
class RegistrarNegocioScreen extends StatefulWidget {
  const RegistrarNegocioScreen({super.key});

  @override
  State<RegistrarNegocioScreen> createState() => _RegistrarNegocioScreenState();
}

class _RegistrarNegocioScreenState extends State<RegistrarNegocioScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _notas = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _nombre.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    String? error = invitarNegocio(
      correo: _correo.text,
      nombre: _nombre.text,
      telefono: _telefono.text,
      direccion: _direccion.text,
      notas: _notas.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Negocio registrado. Se vinculará con ese correo.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar negocio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Registra a tu cliente con el correo con el que usará la app. '
                  'Cuando cree su cuenta (o si ya la tiene) quedará vinculado '
                  'contigo y podrá pedirte desde tu catálogo.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Correo del negocio', prefixIcon: Icon(Icons.email)),
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                        ? null
                        : 'Correo no válido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(
                    labelText: 'Nombre del negocio', prefixIcon: Icon(Icons.store)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Dirección de entrega (opcional)',
                    prefixIcon: Icon(Icons.home)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Notas privadas (opcional)',
                    hintText: 'Ej. Paga a 15 días, recibe de 8 a 12'),
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
                  label: const Text('Registrar negocio'),
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
