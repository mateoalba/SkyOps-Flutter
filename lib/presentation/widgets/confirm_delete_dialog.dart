import 'package:flutter/material.dart';

/// Diálogo de confirmación reutilizado por todas las pantallas de listado.
Future<bool> confirmarEliminacion(BuildContext context, {String? nombre}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text('¿Seguro que deseas eliminar ${nombre ?? 'este registro'}? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
