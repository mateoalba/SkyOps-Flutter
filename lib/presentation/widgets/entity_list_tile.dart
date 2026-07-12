import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// Tarjeta genérica usada en todas las pantallas de listado CRUD.
class EntityListTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const EntityListTile({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.trailing,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icono)),
        title: Text(titulo, style: AppTextStyles.subtitulo),
        subtitle: subtitulo != null ? Text(subtitulo!, style: AppTextStyles.etiqueta) : null,
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) trailing!,
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
