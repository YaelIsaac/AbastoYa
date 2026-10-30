import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'admin_navigation.dart';
import 'negocio_navigation.dart';
import 'proveedor_navigation.dart';

// Manda al usuario a su pantalla principal según su tipo
void irAlInicio(BuildContext context) {
  Widget destino;
  if (usuarioActual!.rol == 'admin') {
    destino = const AdminNavigation();
  } else if (usuarioActual!.rol == 'proveedor') {
    destino = const ProveedorNavigation();
  } else {
    destino = const NegocioNavigation();
  }
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => destino));
}

// Cierra la sesión y regresa al login
void cerrarSesion(BuildContext context) {
  usuarioActual = null;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (ruta) => false,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _empresa = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();

  bool _crearCuenta = false;
  String _rol = 'negocio';
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _empresa.dispose();
    _telefono.dispose();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_form.currentState!.validate()) return;
    String? error;
    if (_crearCuenta) {
      error = registrarUsuario(
        rol: _rol,
        nombre: _nombre.text,
        empresa: _empresa.text,
        telefono: _telefono.text,
        correo: _correo.text,
        password: _password.text,
      );
    } else {
      error = iniciarSesion(_correo.text, _password.text);
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    irAlInicio(context);
  }

  @override
  Widget build(BuildContext context) {
    bool esProveedor = _rol == 'proveedor';
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera roja
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
              decoration: const BoxDecoration(
                color: kRojo,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.storefront, size: 72, color: Colors.white),
                  SizedBox(height: 8),
                  Text('AbastoYa',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Inventario para negocios y pedidos a proveedores',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Iniciar sesión'),
                          selected: !_crearCuenta,
                          selectedColor: kRojo,
                          labelStyle: TextStyle(
                              color: !_crearCuenta ? Colors.white : Colors.black),
                          onSelected: (_) => setState(() {
                            _crearCuenta = false;
                            _error = null;
                          }),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Crear cuenta'),
                          selected: _crearCuenta,
                          selectedColor: kRojo,
                          labelStyle: TextStyle(
                              color: _crearCuenta ? Colors.white : Colors.black),
                          onSelected: (_) => setState(() {
                            _crearCuenta = true;
                            _error = null;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_crearCuenta) ...[
                      const Text('Soy...',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Un negocio'),
                            selected: !esProveedor,
                            selectedColor: kRojo,
                            labelStyle: TextStyle(
                                color: !esProveedor ? Colors.white : Colors.black),
                            onSelected: (_) => setState(() => _rol = 'negocio'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Un proveedor'),
                            selected: esProveedor,
                            selectedColor: kRojo,
                            labelStyle: TextStyle(
                                color: esProveedor ? Colors.white : Colors.black),
                            onSelected: (_) => setState(() => _rol = 'proveedor'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 14),
                        child: Text(
                            esProveedor
                                ? 'Surtes productos a negocios: lleva tu catálogo, clientes, pedidos y cobros.'
                                : 'Tienes un negocio: lleva tu inventario y pídele a tus proveedores.',
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      TextFormField(
                        controller: _empresa,
                        decoration: InputDecoration(
                            labelText: esProveedor
                                ? 'Nombre de tu empresa'
                                : 'Nombre de tu negocio',
                            prefixIcon: const Icon(Icons.business)),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Campo obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nombre,
                        decoration: const InputDecoration(
                            labelText: 'Tu nombre', prefixIcon: Icon(Icons.person)),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Escribe tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telefono,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Teléfono (10 dígitos)',
                            prefixIcon: Icon(Icons.phone)),
                        validator: (v) {
                          String digitos = (v ?? '').replaceAll(RegExp(r'\D'), '');
                          return digitos.length == 10 ? null : 'Escribe 10 dígitos';
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _correo,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email)),
                      validator: (v) {
                        String t = (v ?? '').trim();
                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                            ? null
                            : 'Correo no válido';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRojo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _enviar,
                        child: Text(_crearCuenta ? 'Crear cuenta' : 'Entrar',
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    if (!_crearCuenta) ...[
                      const SizedBox(height: 20),
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Usuarios de ejemplo (contraseña 123456)',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Administrador: admin@abasto.com'),
                              Text('Proveedor: proveedor@abasto.com'),
                              Text('Negocio: negocio@abasto.com'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
