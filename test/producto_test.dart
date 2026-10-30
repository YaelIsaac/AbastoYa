import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/datos.dart';
import 'package:inventario/theme.dart';

void main() {
  Producto crear(double cantidad, double minimo) => Producto(
        id: '1',
        dueno: 'negocio@abasto.com',
        nombre: 'Queso',
        categoria: 'Ingredientes',
        unidad: 'kg',
        cantidad: cantidad,
        stockMinimo: minimo,
      );

  test('estado del producto', () {
    expect(crear(10, 5).estado, 'En stock');
    expect(crear(5, 5).estado, 'Stock bajo');
    expect(crear(0, 5).estado, 'Agotado');
  });

  test('formato y lectura de números', () {
    expect(fmtNum(2), '2');
    expect(fmtNum(1.5), '1.5');
    expect(parseNum('1,5'), 1.5);
    expect(parseNum('abc'), isNull);
  });

  test('inicio de sesión con usuario de ejemplo', () {
    expect(iniciarSesion('negocio@abasto.com', '123456'), isNull);
    expect(iniciarSesion('negocio@abasto.com', 'mal'), isNotNull);
  });
}
