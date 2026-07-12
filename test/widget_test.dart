// Prueba de humo (smoke test) de SkyOps.
//
// Verifica que la pantalla de verificación del Módulo 1 (tema oscuro +
// acento dorado) se construye correctamente y muestra su contenido.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skyops/presentation/screens/verificacion/verificacion_screen.dart';
import 'package:skyops/theme/app_theme.dart';

void main() {
  testWidgets('La pantalla de verificación muestra el título y el checklist', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const VerificacionScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SkyOps'), findsOneWidget);
    expect(find.text('Módulo 1 · Setup + Estructura + Design System'), findsOneWidget);
    expect(find.text('Continuar al login'), findsOneWidget);
  });
}
