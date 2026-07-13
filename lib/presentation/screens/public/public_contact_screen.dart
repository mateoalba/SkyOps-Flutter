import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Pantalla pública de contacto (accesible sin sesión).
class PublicContactScreen extends StatelessWidget {
  const PublicContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Proyecto académico',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'SkyOps es una aplicación Flutter desarrollada como proyecto de curso, '
            'que consume una API REST propia construida con Django REST Framework.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _tarjeta(
            icono: Icons.groups,
            titulo: 'Equipo de desarrollo',
            contenido: 'Mateo Alba · Marcelo · Heymi',
          ),
          const SizedBox(height: 12),
          _tarjeta(
            icono: Icons.email_outlined,
            titulo: 'Correo de contacto',
            contenido: 'mateoalba1234@gmail.com',
          ),
          const SizedBox(height: 12),
          _tarjeta(
            icono: Icons.dns_outlined,
            titulo: 'API backend',
            contenido: 'Django REST Framework · http://147.182.179.6/api/',
          ),
          const SizedBox(height: 12),
          _tarjeta(
            icono: Icons.info_outline,
            titulo: 'Sobre SkyOps',
            contenido:
                'Sistema de control de vuelos de un aeropuerto: gestión de vuelos, flota, '
                'pasajeros, tripulaciones e infraestructura.',
          ),
        ],
      ),
    );
  }

  Widget _tarjeta({required IconData icono, required String titulo, required String contenido}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(contenido, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
