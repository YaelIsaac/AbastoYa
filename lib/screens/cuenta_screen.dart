import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos.dart';
import '../theme.dart';
import 'login_screen.dart';

// Mi cuenta (la usan negocio y proveedor)
class CuentaScreen extends StatefulWidget {
  const CuentaScreen({super.key});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  final _form = GlobalKey<FormState>();
  final _empresa = TextEditingController();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _giro = TextEditingController();

  @override
  void initState() {
    super.initState();
    Usuario u = usuarioActual!;
    _empresa.text = u.empresa;
    _nombre.text = u.nombre;
    _telefono.text = u.telefono;
    _direccion.text = u.direccion;
    _giro.text = u.giro;
  }

  @override
  void dispose() {
    _empresa.dispose();
    _nombre.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _giro.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    Usuario u = usuarioActual!;
    u.empresa = _empresa.text.trim();
    u.nombre = _nombre.text.trim();
    u.telefono = _telefono.text.trim();
    u.direccion = _direccion.text.trim();
    u.giro = _giro.text.trim();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    Usuario u = usuarioActual!;
    bool esProveedor = u.rol == 'proveedor';
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: kRojo,
                  child: Icon(esProveedor ? Icons.local_shipping : Icons.store,
                      size: 34, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                  child: Text(u.correo,
                      style: const TextStyle(color: Colors.grey))),
              Center(
                child: Wrap(
                  spacing: 6,
                  children: [
                    Chip(
                        label: Text(u.etiquetaRol,
                            style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact),
                    if (esProveedor && u.verificado)
                      const Chip(
                          avatar:
                              Icon(Icons.verified, size: 16, color: Colors.blue),
                          label: Text('Verificado',
                              style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact),
                  ],
                ),
              ),
              if (esProveedor)
                Card(
                  color: Colors.amber[50],
                  child: ListTile(
                    title: const Text('Tu código de proveedor'),
                    subtitle:
                        const Text('Compártelo para que los negocios te encuentren'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(u.codigo,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: u.codigo));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Código copiado')));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _empresa,
                decoration: InputDecoration(
                    labelText:
                        esProveedor ? 'Nombre de la empresa' : 'Nombre del negocio',
                    prefixIcon: const Icon(Icons.business)),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(
                    labelText: 'Tu nombre', prefixIcon: Icon(Icons.person)),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Escribe tu nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                validator: (v) {
                  String digitos = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digitos.length == 10 ? null : 'Escribe 10 dígitos';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                maxLines: 2,
                decoration: InputDecoration(
                    labelText: esProveedor ? 'Dirección' : 'Dirección de entrega',
                    prefixIcon: const Icon(Icons.home)),
              ),
              if (esProveedor) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _giro,
                  maxLines: 2,
                  maxLength: 150,
                  decoration: const InputDecoration(
                      labelText: '¿Qué productos manejas?',
                      hintText: 'Ej. Lácteos, abarrotes, desechables y empaques',
                      prefixIcon: Icon(Icons.inventory_2)),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRojo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                  onPressed: _guardar,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  onPressed: () => cerrarSesion(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
