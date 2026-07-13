import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Pantalla de verificación del Módulo 1: setup + estructura + design system.
///
/// Al correr `flutter run` esta es la primera pantalla que se ve. Sirve para
/// comprobar visualmente que el tema oscuro Material 3 con acento dorado está
/// aplicado correctamente y que la estructura del proyecto (Clean Architecture)
/// está lista para los siguientes módulos.
class VerificacionScreen extends StatelessWidget {
  const VerificacionScreen({super.key});

  static const List<String> _checklist = [
    'Proyecto Flutter configurado (SDK, pubspec, lints)',
    'Estructura Clean Architecture: data / domain / presentation / core / theme',
    'Design System Material 3 — tema oscuro + acento dorado',
    '25 modelos de dominio (uno por entidad del backend SkyOps)',
    'Cliente Dio + interceptor de autenticación JWT listos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flight_takeoff, color: AppColors.gold, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SkyOps', style: AppTextStyles.titulo),
                      Text('Módulo 1 · Setup + Estructura + Design System', style: AppTextStyles.etiqueta),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text('Checklist del módulo', style: AppTextStyles.subtitulo),
              const SizedBox(height: 10),
              ..._checklist.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.gold, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: AppTextStyles.cuerpo)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Text('Paleta de colores', style: AppTextStyles.subtitulo),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _ColorSwatch('background', AppColors.background),
                  _ColorSwatch('surface', AppColors.surface),
                  _ColorSwatch('gold', AppColors.gold),
                  _ColorSwatch('secondary', AppColors.secondary),
                  _ColorSwatch('success', AppColors.success),
                  _ColorSwatch('error', AppColors.error),
                ],
              ),

              const SizedBox(height: 28),
              Text('Tipografía', style: AppTextStyles.subtitulo),
              const SizedBox(height: 10),
              Text('Título', style: AppTextStyles.titulo),
              Text('Subtítulo', style: AppTextStyles.subtitulo),
              Text('Cuerpo de texto', style: AppTextStyles.cuerpo),
              Text('Etiqueta secundaria', style: AppTextStyles.etiqueta),
              Text('Acento dorado', style: AppTextStyles.acentoDorado),

              const SizedBox(height: 28),
              Text('Componentes', style: AppTextStyles.subtitulo),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text('Botón primario')),
                  OutlinedButton(onPressed: () {}, child: const Text('Botón secundario')),
                  TextButton(onPressed: () {}, child: const Text('Botón de texto')),
                ],
              ),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Continuar al login'),
                  onPressed: () => context.go('/login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String nombre;
  final Color color;

  const _ColorSwatch(this.nombre, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
        ),
        const SizedBox(height: 4),
        Text(nombre, style: AppTextStyles.etiqueta),
      ],
    );
  }
}
