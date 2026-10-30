import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';

// El administrador ve todas las cuentas y las administra
class AdminCuentasScreen extends StatefulWidget {
  const AdminCuentasScreen({super.key});

  @override
  State<AdminCuentasScreen> createState() => _AdminCuentasScreenState();
}

class _AdminCuentasScreenState extends State<AdminCuentasScreen> {
  String busqueda = '';
  String filtro = 'todos';

  bool _pasaFiltro(Usuario u) {
    if (filtro == 'proveedor') return u.rol == 'proveedor';
    if (filtro == 'negocio') return u.rol == 'negocio';
    if (filtro == 'admin') return u.rol == 'admin';
    if (filtro == 'verificar') return u.rol == 'proveedor' && !u.verificado;
    if (filtro == 'suspendidas') return !u.activo;
    return true;
  }

  Widget _chip(String valor, String texto) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: filtro == valor,
        selectedColor: kRojo,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: filtro == valor ? Colors.white : Colors.black),
        onSelected: (_) => setState(() => filtro = valor),
      ),
    );
  }

  Widget _boton(String texto, IconData icono, Color color, VoidCallback alPulsar) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12)),
          icon: Icon(icono),
          label: Text(texto),
          onPressed: alPulsar,
        ),
      ),
    );
  }

  // Ventana de abajo con los datos de la cuenta y sus acciones
  void _detalle(Usuario u) {
    bool soyYo = u == usuarioActual;
    int admins = usuarios.where((x) => x.rol == 'admin').length;
    bool ultimoAdmin = u.rol == 'admin' && admins <= 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(u.titulo,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rol: ${u.etiquetaRol}'),
              Text('Contacto: ${u.nombre}'),
              Text('Correo: ${u.correo}'),
              Text('Teléfono: ${u.telefono.isEmpty ? '—' : u.telefono}'),
              if (u.rol == 'proveedor' && u.giro.isNotEmpty)
                Text('Maneja: ${u.giro}'),
              if (u.rol == 'proveedor') Text('Código: ${u.codigo}'),
              Text('Estado: ${u.activo ? 'Activa' : 'Suspendida'}'
                  '${u.rol == 'proveedor' ? (u.verificado ? ' • Verificado' : ' • Sin verificar') : ''}'),
              const SizedBox(height: 16),
              if (u.rol == 'proveedor')
                _boton(
                  u.verificado ? 'Quitar verificación' : 'Verificar proveedor',
                  Icons.verified,
                  u.verificado ? Colors.grey : Colors.blue,
                  () {
                    setState(() => u.verificado = !u.verificado);
                    Navigator.pop(ctx);
                  },
                ),
              if (soyYo)
                const Text('No puedes modificar tu propia cuenta.',
                    style: TextStyle(color: Colors.grey))
              else ...[
                _boton(
                  u.activo ? 'Suspender cuenta' : 'Reactivar cuenta',
                  u.activo ? Icons.block : Icons.check_circle,
                  u.activo ? Colors.red : Colors.green,
                  () {
                    setState(() => u.activo = !u.activo);
                    Navigator.pop(ctx);
                  },
                ),
                if (ultimoAdmin)
                  const Text('Es el único administrador; no se puede descender.',
                      style: TextStyle(color: Colors.grey))
                else if (u.rol == 'admin')
                  _boton('Quitar administrador (pasa a negocio)',
                      Icons.arrow_downward, Colors.orange, () {
                    setState(() => u.rol = 'negocio');
                    Navigator.pop(ctx);
                  })
                else
                  _boton('Ascender a administrador', Icons.arrow_upward, kRojo, () {
                    setState(() => u.rol = 'admin');
                    Navigator.pop(ctx);
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String q = busqueda.toLowerCase();
    List<Usuario> lista = usuarios
        .where((u) =>
            _pasaFiltro(u) &&
            (u.titulo.toLowerCase().contains(q) ||
                u.nombre.toLowerCase().contains(q) ||
                u.correo.toLowerCase().contains(q)))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas registradas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: (texto) => setState(() => busqueda = texto),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip('todos', 'Todas'),
                _chip('proveedor', 'Proveedores'),
                _chip('negocio', 'Negocios'),
                _chip('admin', 'Administradores'),
                _chip('verificar', 'Por verificar'),
                _chip('suspendidas', 'Suspendidas'),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const EmptyState(
                    icono: Icons.group_off,
                    titulo: 'Sin resultados',
                    subtitulo: 'No hay cuentas con ese filtro.')
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      Usuario u = lista[i];
                      IconData icono = u.rol == 'admin'
                          ? Icons.admin_panel_settings
                          : (u.rol == 'proveedor' ? Icons.local_shipping : Icons.store);
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: !u.activo
                                ? Colors.grey
                                : (u.rol == 'admin' ? kRojo : Colors.red[50]),
                            child: Icon(icono,
                                color: (u.rol == 'admin' || !u.activo)
                                    ? Colors.white
                                    : kRojo),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                  child: Text(u.titulo,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              if (u.rol == 'proveedor' && u.verificado)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.verified,
                                      size: 16, color: Colors.blue),
                                ),
                            ],
                          ),
                          subtitle: Text(
                              '${u.correo}\n${u.etiquetaRol}${u.activo ? '' : ' • Suspendida'}'),
                          isThreeLine: true,
                          onTap: () => _detalle(u),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
