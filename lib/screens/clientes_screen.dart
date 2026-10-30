import 'package:flutter/material.dart';

import '../datos.dart';
import '../theme.dart';
import 'cliente_detail_screen.dart';
import 'registrar_negocio_screen.dart';

// Clientes (negocios) del proveedor
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  Future<void> _registrar() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const RegistrarNegocioScreen()));
    setState(() {});
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(texto,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Vinculo> todos = vinculosDelProveedor();
    List<Vinculo> pendientes = todos.where((v) => v.estado == 'pendiente').toList();
    List<Vinculo> otros = todos.where((v) => v.estado != 'pendiente').toList();
    List<Invitacion> invitados =
        invitaciones.where((i) => i.proveedor == usuarioActual!.correo).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('AbastoYa - Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrar,
        icon: const Icon(Icons.person_add),
        label: const Text('Registrar negocio'),
      ),
      body: (todos.isEmpty && invitados.isEmpty)
          ? EmptyState(
              icono: Icons.groups_outlined,
              titulo: 'Aún no tienes clientes',
              subtitulo:
                  'Registra un negocio con su correo, o comparte tu código para que te agreguen.',
              textoBoton: 'Registrar negocio',
              onPressed: _registrar,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 90, top: 6),
              children: [
                if (pendientes.isNotEmpty) ...[
                  _titulo('Solicitudes pendientes'),
                  ...pendientes.map((v) {
                    Usuario? n = buscarUsuario(v.negocio);
                    return Card(
                      color: Colors.amber[50],
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombreDe(v.negocio),
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${n?.nombre ?? ''} • ${n?.telefono ?? ''}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () =>
                                        setState(() => v.estado = 'rechazado'),
                                    child: const Text('Rechazar',
                                        style: TextStyle(color: Colors.red))),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white),
                                    onPressed: () =>
                                        setState(() => v.estado = 'activo'),
                                    child: const Text('Aprobar')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                if (otros.isNotEmpty) ...[
                  _titulo('Mis clientes'),
                  ...otros.map((v) {
                    bool activo = v.estado == 'activo';
                    double saldo = saldoCon(v.negocio);
                    String subtitulo;
                    if (!activo) {
                      subtitulo = etiquetaEstado(v.estado);
                    } else if (saldo > 0.005) {
                      subtitulo = 'Te debe: ${fmtPrecio(saldo)}';
                    } else if (saldo < -0.005) {
                      subtitulo = 'Saldo a favor: ${fmtPrecio(-saldo)}';
                    } else {
                      subtitulo = 'Al corriente';
                    }
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              activo ? Colors.red[50] : Colors.grey[200],
                          child: Icon(Icons.store,
                              color: activo ? kRojo : Colors.grey),
                        ),
                        title: Text(nombreDe(v.negocio),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(subtitulo),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ClienteDetailScreen(vinculo: v)));
                          setState(() {});
                        },
                      ),
                    );
                  }),
                ],
                if (invitados.isNotEmpty) ...[
                  _titulo('Registrados, aún sin cuenta'),
                  ...invitados.map((i) => Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.mark_email_unread,
                                  color: Colors.grey)),
                          title: Text(i.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${i.correo}\nSe vinculará solo al crear su cuenta'),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Quitar',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              invitaciones.remove(i);
                              setState(() {});
                            },
                          ),
                        ),
                      )),
                ],
              ],
            ),
    );
  }
}
