import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import 'public_home_screen.dart';

/// Detalle público de un módulo de SkyOps (accesible sin sesión).
class PublicModuleDetailScreen extends StatelessWidget {
  final String moduloId;
  const PublicModuleDetailScreen({super.key, required this.moduloId});

  @override
  Widget build(BuildContext context) {
    final modulo = PublicModulos.porId(moduloId);
    if (modulo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Módulo')),
        body: const Center(child: Text('Módulo no encontrado')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(modulo.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(modulo.icono, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 20),
            Text(modulo.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(modulo.descripcion, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'La gestión completa de este módulo (crear, editar, eliminar) requiere '
                      'iniciar sesión y depende de tu rol en el sistema.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Iniciar sesión para gestionar'),
            ),
          ],
        ),
      ),
    );
  }
}
